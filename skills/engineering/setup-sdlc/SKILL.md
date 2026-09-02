---
name: setup-sdlc
description: "Configure ce dépôt pour les skills d'ingénierie : son issue tracker, le vocabulaire des labels de triage, l'emplacement des docs de domaine, et le workflow git — branche par fonctionnalité, et garde-fous qui refusent à l'agent de merger. À lancer une fois avant le premier usage des autres skills."
disable-model-invocation: true
---

# Setup SDLC

Poser la configuration propre au dépôt que les skills d'ingénierie présupposent :

- **Issue tracker** : où vivent les issues (GitHub par défaut ; le markdown local est également supporté nativement)
- **Labels de triage** : les chaînes utilisées pour les cinq rôles canoniques de triage
- **Docs de domaine** : où vivent `CONTEXT.md` et les ADR, et les règles de lecture associées
- **Workflow git** : le modèle de branche, ce que l'agent n'a pas le droit de faire, et les garde-fous qui le lui refusent

C'est un skill piloté par le dialogue, pas un script déterministe. Explorer, présenter ce qui a été trouvé, confirmer avec l'utilisateur, puis écrire.

Les trois premiers points produisent de la prose sous `docs/agents/`, que l'agent lit. Le quatrième en produit aussi, mais **écrit en plus dans `.claude/`** : un document dit ce qui est interdit, un garde-fou le refuse. La différence compte — une interdiction seulement écrite est une préférence.

## Process

### 1. Explorer

Regarder le dépôt courant pour comprendre son état de départ. Lire ce qui existe ; ne rien supposer :

- `git remote -v` et `.git/config` : est-ce un dépôt GitHub ? Lequel ?
- `AGENTS.md` et `CLAUDE.md` à la racine : l'un des deux existe-t-il ? Contient-il déjà une section `## Agent skills` ?
- `CONTEXT.md` et `CONTEXT-MAP.md` à la racine
- `docs/adr/` et les éventuels répertoires `src/*/docs/adr/`
- `docs/agents/` : la sortie d'un précédent passage de ce skill existe-t-elle déjà ?
- `.scratch/` : signe qu'une convention d'issue tracker en markdown local est déjà en place
- La **branche de référence** : `git symbolic-ref --short refs/remotes/origin/HEAD`, à défaut `git branch --list main master`. C'est elle que les garde-fous de la Section D protègent — ne pas supposer `main`.
- `.claude/settings.json` et `.claude/hooks/` : des `permissions.deny` ou un hook `PreToolUse` existent-ils déjà ? Si oui, il faudra **fusionner** dans ce qui est là, jamais l'écraser.
- `jq` et `python3`/`python` sont-ils sur le `PATH` ? Le garde-fou s'en sert pour lire la commande interceptée ; sans eux il retombe sur une analyse approximative, plus prompte aux faux positifs.
- Signaux de monorepo : un `pnpm-workspace.yaml`, un champ `workspaces` dans `package.json`, ou un `packages/*` peuplé avec son propre `src/`. Ces signaux ne sont présents que dans un vrai dépôt multi-paquets ; leur absence signifie mono-contexte, ce qui est le cas de presque tous les dépôts.

### 2. Présenter les constats et demander

Résumer ce qui est présent et ce qui manque. Puis prendre les sections dans l'ordre. Une section, une réponse, puis la suivante.

Ouvrir chaque section par la réponse recommandée, pour que l'utilisateur puisse l'accepter d'un mot. Ne donner une ligne d'explication que lorsque le choix bifurque réellement ; sauter entièrement la section quand l'exploration a déjà tranché (Section C quand il n'y a pas de monorepo).

**Section A : issue tracker.**

> Explication : l'« issue tracker » est l'endroit où vivent les issues de ce dépôt. Des skills comme `to-tickets` et `to-spec` y lisent et y écrivent. Ils ont besoin de savoir s'ils doivent appeler `gh issue create`, écrire un fichier markdown sous `.scratch/`, ou suivre un autre workflow que tu décris. Choisis l'endroit où tu suis réellement le travail sur ce dépôt.

Posture par défaut : ces skills ont été conçus pour GitHub. Si un `git remote` pointe vers GitHub, proposer GitHub. S'il pointe vers GitLab (`gitlab.com` ou une instance auto-hébergée), proposer GitLab. Sinon (ou si l'utilisateur préfère), proposer :

- **GitHub** : les issues vivent dans les GitHub Issues du dépôt (utilise la CLI `gh`)
- **GitLab** : les issues vivent dans les GitLab Issues du dépôt (utilise la CLI [`glab`](https://gitlab.com/gitlab-org/cli))
- **Markdown local** : les issues vivent comme fichiers sous `.scratch/<feature>/` dans ce dépôt (bon pour les projets solo ou les dépôts sans remote)
- **Autre** (Jira, Linear, etc.) : demander à l'utilisateur de décrire le workflow en un paragraphe ; le skill le consignera tel quel en prose libre

Consigner le choix dans `docs/agents/issue-tracker.md`. Les gabarits GitHub et GitLab portent un drapeau « PR comme surface de demande », **désactivé** par défaut. Le laisser désactivé et ne pas soulever la question : un utilisateur qui veut voir les PR externes dans la file de triage pourra basculer le drapeau dans le fichier plus tard.

**Section B : vocabulaire des labels de triage.** Cette section tourne toujours. Des cinq rôles, la chaîne livrée n'en pose aujourd'hui qu'un seul : `ready-for-agent`, appliqué par `to-spec` et `to-tickets` à ce qu'ils publient. Les quatre autres sont le vocabulaire canonique de la file de triage, fixé d'avance.

Poser exactement une question :

> Veux-tu garder les labels de triage par défaut ? (recommandé : **oui**)

Les valeurs par défaut sont les cinq rôles canoniques, chaque label étant égal à son nom : `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. Sur **oui**, les écrire tels quels. Seulement si l'utilisateur dit non — en général parce que son tracker utilise déjà d'autres noms (par exemple `bug:triage` pour `needs-triage`) — collecter les correspondances, pour que les skills appliquent les labels existants au lieu d'en créer des doublons.

Consigner la correspondance dans `docs/agents/triage-labels.md`. Cette table ne crée rien par elle-même : sur un tracker où un label doit préexister pour être appliqué, créer en plus les cinq labels retenus — `gh label create <label> --force` sur GitHub, `glab label create --name <label>` sur GitLab, le `--force` rendant le passage rejouable sur un dépôt qui les a déjà. Sans eux, le `--add-label ready-for-agent` de `to-spec` échoue au premier ticket d'un dépôt neuf. Sur un tracker markdown local, il n'y a rien à créer.

**Section C : docs de domaine.** Par défaut, **mono-contexte** (un `CONTEXT.md` + `docs/adr/` à la racine du dépôt). Cela convient à presque tous les dépôts ; l'écrire sans demander.

Ne proposer le **multi-contexte** (un `CONTEXT-MAP.md` racine pointant vers un `CONTEXT.md` par contexte) que si l'exploration a trouvé des signaux de monorepo. Confirmer alors la disposition voulue.

**Section D : workflow git.** Cette section tourne toujours.

> Explication : ce que l'agent a le droit de faire de git. Deux choses s'y décident — sur quelle branche il travaille, et jusqu'où va son autorité. Un agent qui peut merger vers le trunk peut livrer sans que personne ne regarde.

Défaut recommandé, à confirmer d'un mot :

> **Trunk-based, une branche par fonctionnalité.** `/implement` crée `feature/<feature-slug>` au premier ticket d'une fonctionnalité et commite dessus, un commit par ticket. L'agent pousse la branche et ouvre la PR ; **il ne merge jamais**. Des garde-fous posés dans `.claude/` refusent les commandes qui feraient atterrir du code sur la branche de référence. (recommandé : **oui**)

Confirmer au passage la branche de référence détectée à l'étape 1 — c'est elle que les garde-fous protègent.

Le blocage est **directionnel**, jamais catégorique. `git merge` reste permis *dans* une branche de fonctionnalité : c'est de la synchronisation, et `/resolving-merge-conflicts` en dépend. `git push` reste permis *vers* la branche de fonctionnalité, sans quoi l'agent ne pourrait pas ouvrir de PR. Ce qui est refusé, c'est la cible : le trunk. Un blocage catégorique du type « toute commande contenant `git push` » casserait les deux.

Deux réponses écartent le défaut :

- **Le modèle, sans les garde-fous** : écrire `docs/agents/git-workflow.md` et sauter l'installation dans `.claude/`. Le dire alors franchement : la règle devient indicative, l'agent peut en dériver, et personne ne le saura avant de lire l'historique.
- **Un autre modèle** (commits directs sur le trunk, une branche par ticket, git-flow…) : demander à l'utilisateur de le décrire, rédiger `docs/agents/git-workflow.md` d'après sa description, et ne poser de garde-fou que sur ce qu'il a lui-même déclaré interdit. Ne rien interdire qu'il n'ait nommé.


### 3. Confirmer et laisser éditer

Montrer à l'utilisateur un brouillon de :

- Le bloc `## Agent skills` à ajouter dans celui des deux fichiers `CLAUDE.md` / `AGENTS.md` qui sera édité (règles de sélection à l'étape 4)
- Le contenu de `docs/agents/issue-tracker.md`, `docs/agents/domain.md`, `docs/agents/git-workflow.md` et `docs/agents/triage-labels.md`
- Les garde-fous à poser : le hook `.claude/hooks/block-trunk-writes.sh` et les entrées ajoutées à `.claude/settings.json` (sauf refus en Section D)

Le laisser corriger avant d'écrire.

### 4. Écrire

**Choisir le fichier à éditer :**

- Si `CLAUDE.md` existe, l'éditer.
- Sinon, si `AGENTS.md` existe, l'éditer.
- Si aucun des deux n'existe, demander à l'utilisateur lequel créer ; ne pas choisir à sa place.

Ne jamais créer `AGENTS.md` quand `CLAUDE.md` existe déjà (ni l'inverse) ; toujours éditer celui qui est déjà là.

Si un bloc `## Agent skills` existe déjà dans le fichier retenu, mettre son contenu à jour sur place plutôt que d'ajouter un doublon. Ne pas écraser les modifications de l'utilisateur dans les sections voisines.

Le bloc :

```markdown
## Agent skills

### Issue tracker

[résumé en une ligne de l'endroit où les issues sont suivies]. Voir `docs/agents/issue-tracker.md`.

### Labels de triage

[résumé en une ligne du vocabulaire de labels]. Voir `docs/agents/triage-labels.md`.

### Docs de domaine

[résumé en une ligne de la disposition : « mono-contexte » ou « multi-contexte »]. Voir `docs/agents/domain.md`.

### Workflow git

[résumé en une ligne du modèle de branche, et de ce que l'agent n'a pas le droit de faire]. Voir `docs/agents/git-workflow.md`.
```

Toujours inclure le sous-bloc `### Labels de triage`, et toujours écrire `docs/agents/triage-labels.md`.

Écrire ensuite les fichiers de docs en partant des gabarits présents dans ce dossier de skill :

- [issue-tracker-github.md](./issue-tracker-github.md) : issue tracker GitHub
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md) : issue tracker GitLab
- [issue-tracker-local.md](./issue-tracker-local.md) : issue tracker en markdown local
- [triage-labels.md](./triage-labels.md) : correspondance des labels
- [domain.md](./domain.md) : règles de lecture des docs de domaine + disposition
- [git-workflow.md](./git-workflow.md) : modèle de branche + ce que l'agent ne fait pas. Le gabarit est écrit pour un trunk nommé `main` : y substituer la branche de référence réelle. Il suppose aussi un **remote** ; si `git remote` est muet, retirer les lignes « pousser la branche » et « ouvrir la PR » et dire à leur place que le travail s'arrête au commit local — un document qui prescrit un geste impossible se fait ignorer en entier. Si l'utilisateur a refusé les garde-fous en Section D, remplacer la section « Garde-fous » du gabarit par une ligne disant que ces règles ne sont **pas** appliquées — un document qui annonce une protection inexistante est pire que pas de document.

Pour un issue tracker « autre », rédiger `docs/agents/issue-tracker.md` de zéro à partir de la description de l'utilisateur.

**Provisionner les labels sur le tracker.** La correspondance écrite ne suffit pas : `gh` refuse un `--label` qu'il ne trouve pas au lieu de le créer, et la première publication de `to-spec` échoue sur un dépôt neuf — les labels GitHub par défaut comptent bien `wontfix`, mais pas `ready-for-agent`. Créer les cinq chaînes de la colonne de droite du fichier, une fois, en absorbant l'échec sur celles qui existent déjà :

```bash
# GitHub
for l in needs-triage needs-info ready-for-agent ready-for-human wontfix; do gh label create "$l" || true; done
# GitLab
for l in needs-triage needs-info ready-for-agent ready-for-human wontfix; do glab label create --name "$l" || true; done
```

Vérifier ensuite avec `gh label list` / `glab label list` que les cinq y sont : le `|| true` absorbe aussi bien un label déjà présent qu'un échec d'authentification. Substituer les chaînes retenues en Section B si l'utilisateur a donné les siennes — elles existent déjà sur son tracker, la boucle est alors sans effet. En markdown local, rien à créer : l'état de triage est une ligne `Status:` dans le fichier. Sur un tracker « autre », dire à l'utilisateur de poser les cinq lui-même.

**Poser les garde-fous** — sauf s'ils ont été refusés en Section D. Un document qui dit « l'agent ne merge pas » n'empêche rien ; ces trois pas, oui.

1. Copier [scripts/block-trunk-writes.sh](./scripts/block-trunk-writes.sh) vers `.claude/hooks/block-trunk-writes.sh`, puis `chmod +x`. Si la branche de référence n'est pas `main`, corriger la valeur de `TRUNK` en tête du script — le script ne la devine pas.

2. **Fusionner** dans `.claude/settings.json` (créer le fichier s'il n'existe pas ; s'il existe, ajouter aux tableaux présents, ne jamais remplacer un `permissions` ou un `hooks` déjà là) :

```json
{
  "permissions": {
    "deny": [
      "Bash(gh pr merge:*)",
      "Bash(git push --force:*)",
      "Bash(git push -f:*)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/block-trunk-writes.sh\""
          }
        ]
      }
    ]
  }
}
```

Les règles `deny` ne couvrent que les formes catégoriques, et par préfixe : `git push origin main --force` leur échappe. C'est le hook qui rattrape le reste, en regardant la cible réelle et la branche courante. Les deux couches sont volontaires ; ne pas en retirer une au motif que l'autre existe. Le préfixe `bash ` dans la commande du hook est délibéré lui aussi : il rend le script exécutable là où le bit `+x` ne veut rien dire.

3. **Vérifier que ça refuse vraiment.** Un garde-fou qu'on n'a pas vu bloquer n'est pas un garde-fou :

```bash
echo '{"tool_input":{"command":"gh pr merge 1"}}' | bash .claude/hooks/block-trunk-writes.sh; echo "code=$?"
echo '{"tool_input":{"command":"git status"}}'    | bash .claude/hooks/block-trunk-writes.sh; echo "code=$?"
```

Le premier doit sortir en `code=2` avec un message `BLOQUÉ`. Le second en `code=0`, sans rien afficher : c'est le test qui prouve que le hook laisse passer le travail ordinaire. Si l'un des deux ne fait pas ce qui est attendu, le dire à l'utilisateur et **ne pas** annoncer que la protection est en place.


### 5. Terminé

Dire à l'utilisateur que la configuration est faite et quels skills d'ingénierie liront désormais ces fichiers. Mentionner qu'il peut éditer `docs/agents/*.md` directement plus tard ; relancer ce skill n'est nécessaire que pour changer d'issue tracker ou repartir de zéro.

Dire aussi, en une phrase, ce qui vient d'être **refusé** à l'agent et par quel mécanisme — l'utilisateur doit savoir où aller le desserrer. Le hook et les règles `deny` vivent dans `.claude/`, qui se commite : la limite vaut pour toute l'équipe, pas seulement pour la machine où ce skill a tourné.
