---
name: setup-sdlc
description: "Configure ce dépôt pour les skills d'ingénierie : son issue tracker, le vocabulaire des labels de triage, l'emplacement des docs de domaine, et le workflow git — branche par fonctionnalité, et merge réservé à l'accord de l'utilisateur. À lancer une fois avant le premier usage des autres skills."
disable-model-invocation: true
---

# Setup SDLC

Poser la configuration propre au dépôt que les skills d'ingénierie présupposent :

- **Issue tracker** : où vivent les issues (GitHub par défaut ; le markdown local est également supporté nativement)
- **Labels de triage** : les chaînes utilisées pour les cinq rôles canoniques de triage
- **Docs de domaine** : où vivent `CONTEXT.md` et les ADR, et les règles de lecture associées
- **Workflow git** : le modèle de branche, et les gestes que l'agent réserve à l'accord explicite de l'utilisateur

C'est un skill piloté par le dialogue, pas un script déterministe. Explorer, présenter ce qui a été trouvé, confirmer avec l'utilisateur, puis écrire.

Les quatre points produisent de la prose sous `docs/agents/`, que l'agent lit. La limite du quatrième est du **consentement**, pas de l'empêchement : l'agent sait merger, et le fait quand l'utilisateur le lui demande — jamais de lui-même. Un dépôt qui veut en plus un refus mécanique peut demander les garde-fous de la Section D ; ils ne sont pas le défaut.

## Process

### 1. Explorer

Regarder le dépôt courant pour comprendre son état de départ. Lire ce qui existe ; ne rien supposer :

- `git remote -v` et `.git/config` : est-ce un dépôt GitHub ? Lequel ?
- `AGENTS.md` et `CLAUDE.md` à la racine : l'un des deux existe-t-il ? Contient-il déjà une section `## Agent skills` ?
- `CONTEXT.md` et `CONTEXT-MAP.md` à la racine
- `docs/adr/` et les éventuels répertoires `src/*/docs/adr/`
- `docs/agents/` : la sortie d'un précédent passage de ce skill existe-t-elle déjà ?
- `.scratch/` : signe qu'une convention d'issue tracker en markdown local est déjà en place
- Le **trunk**, la branche d'intégration du dépôt : `git symbolic-ref --short refs/remotes/origin/HEAD`, à défaut `git branch --list main master`. C'est lui que le workflow de la Section D protège — ne pas supposer `main`.
- `.claude/settings.json` et `.claude/hooks/` : des `permissions.deny` ou un hook `PreToolUse` refusent-ils déjà des commandes git ? Deux raisons de regarder — les fusionner si l'utilisateur demande les garde-fous, et savoir dire pourquoi une commande sera refusée s'ils sont déjà là.
- Signaux de monorepo : plusieurs manifestes de paquet sous un même dépôt — selon l'écosystème, un `pnpm-workspace.yaml` ou un champ `workspaces` dans `package.json`, un `[tool.uv.workspace]` ou plusieurs `pyproject.toml`, un `[workspace]` Cargo, plusieurs `go.mod` — ou un répertoire de paquets (`packages/*`, `libs/*`) peuplé avec son propre `src/`. Ces signaux ne sont présents que dans un vrai dépôt multi-paquets ; leur absence signifie mono-contexte, ce qui est le cas de presque tous les dépôts.

### 2. Présenter les constats et demander

Résumer ce qui est présent et ce qui manque. Puis prendre les sections dans l'ordre. Une section, une réponse, puis la suivante.

Ouvrir chaque section par la réponse recommandée, pour que l'utilisateur puisse l'accepter d'un mot. Ne donner une ligne d'explication que lorsque le choix bifurque réellement ; sauter entièrement la section quand l'exploration a déjà tranché (Section C quand il n'y a pas de monorepo).

**Section A : issue tracker.**

> Explication : l'« issue tracker » est l'endroit où vivent les **tickets** de ce dépôt. Des skills comme `to-tickets` et `to-spec` y lisent et y écrivent. Ils ont besoin de savoir s'ils doivent appeler `gh issue create`, écrire un fichier markdown sous `.scratch/`, ou suivre un autre workflow que tu décris. Choisis l'endroit où tu suis réellement le travail sur ce dépôt.
>
> Ce choix ne concerne **pas** la spec : elle est toujours un fichier versionné à `docs/specs/<feature-slug>.md`, quel que soit le tracker. Ce que le tracker porte, ce sont les tickets — et, sur un vrai tracker, l'epic mince qui suit leur avancement.

Posture par défaut : ces skills ont été conçus pour GitHub. Si un `git remote` pointe vers GitHub, proposer GitHub. S'il pointe vers GitLab (`gitlab.com` ou une instance auto-hébergée), proposer GitLab. Sinon (ou si l'utilisateur préfère), proposer :

- **GitHub** : les issues vivent dans les GitHub Issues du dépôt (utilise la CLI `gh`)
- **GitLab** : les issues vivent dans les GitLab Issues du dépôt (utilise la CLI [`glab`](https://gitlab.com/gitlab-org/cli))
- **Markdown local** : les issues vivent comme fichiers sous `.scratch/<feature-slug>/` dans ce dépôt (bon pour les projets solo ou les dépôts sans remote)
- **Autre** (Jira, Linear, etc.) : demander à l'utilisateur de décrire le workflow en un paragraphe ; le skill le consignera tel quel en prose libre

Consigner le choix dans `docs/agents/issue-tracker.md`. Les gabarits GitHub et GitLab portent un drapeau « PR comme surface de demande », **désactivé** par défaut. Le laisser désactivé et ne pas soulever la question : un utilisateur qui veut voir les PR externes dans la file de triage pourra basculer le drapeau dans le fichier plus tard.

**Section B : vocabulaire des labels de triage.** Cette section tourne toujours. Des cinq rôles, la chaîne livrée n'en pose aujourd'hui qu'un seul : `ready-for-agent`, appliqué par `to-spec` et `to-tickets` à ce qu'ils publient. Les quatre autres sont le vocabulaire canonique de la file de triage, fixé d'avance.

Poser exactement une question :

> Veux-tu garder les labels de triage par défaut ? (recommandé : **oui**)

Les valeurs par défaut sont les cinq rôles canoniques, chaque label étant égal à son nom : `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. Sur **oui**, les écrire tels quels. Seulement si l'utilisateur dit non — en général parce que son tracker utilise déjà d'autres noms (par exemple `bug:triage` pour `needs-triage`) — collecter les correspondances, pour que les skills appliquent les labels existants au lieu d'en créer des doublons.

Consigner la correspondance dans `docs/agents/triage-labels.md`. Cette table ne crée rien par elle-même : sur un tracker où un label doit préexister pour être appliqué, créer en plus les cinq labels retenus — `gh label create <label> --force` sur GitHub, `glab label create --name <label>` sur GitLab, le `--force` rendant le passage rejouable sur un dépôt qui les a déjà. Sans eux, le `--add-label` de `to-spec` échoue au premier ticket d'un dépôt neuf. Sur un tracker markdown local, il n'y a rien à créer.

**Section C : docs de domaine.** Par défaut, **mono-contexte** (un `CONTEXT.md` + `docs/adr/` à la racine du dépôt). Cela convient à presque tous les dépôts ; l'écrire sans demander.

Ne proposer le **multi-contexte** (un `CONTEXT-MAP.md` racine pointant vers un `CONTEXT.md` par contexte) que si l'exploration a trouvé des signaux de monorepo. Confirmer alors la disposition voulue.

**Section D : workflow git.** Cette section tourne toujours.

> Explication : ce que l'agent fait de git. Deux choses s'y décident — sur quelle branche il travaille, et à partir de quel moment il te repasse la main. Un agent qui merge de sa propre initiative livre sans que personne ne regarde.

Défaut recommandé, à confirmer d'un mot :

> **Trunk-based, une branche par fonctionnalité.** `/implement` crée `feature/<feature-slug>` au premier ticket d'une fonctionnalité et commite dessus, un commit par ticket. L'agent pousse la branche et ouvre la PR, puis s'arrête là : **merger vers le trunk, y pousser directement ou force-pusher, il le propose et attend ton accord**. Ces règles vivent dans `docs/agents/git-workflow.md`, que l'agent lit ; rien ne les bloque mécaniquement, pour qu'un merge que tu demandes reste faisable. (recommandé : **oui**)

Confirmer au passage le trunk détecté à l'étape 1 — c'est lui que le workflow protège.

Deux réponses écartent le défaut :

- **Durcir avec des garde-fous** : en plus du document, poser dans `.claude/` des `permissions.deny` et un hook `PreToolUse` qui refusent ces commandes (gabarit : [garde-fous.md](./garde-fous.md), installation à l'étape 4). À proposer seulement si l'utilisateur demande un blocage, ou décrit un contexte qui l'appelle — plusieurs mains sur le dépôt, un trunk protégé par contrat. Le dire alors franchement : le refus vaut aussi quand c'est lui qui demande le merge, et il faudra desserrer `.claude/` à la main. Le blocage reste **directionnel** : `git merge` dans une branche de fonctionnalité et `git push` vers elle restent permis, sans quoi `/resolving-merge-conflicts` et l'ouverture de PR cassent.
- **Un autre modèle** (commits directs sur le trunk, une branche par ticket, git-flow…) : demander à l'utilisateur de le décrire, et rédiger `docs/agents/git-workflow.md` d'après sa description. N'y réserver à son accord que les gestes qu'il a lui-même nommés.


**Section E : standards de code.** Cette section tourne toujours, et se règle en une question.

> Explication : `/code-review` relit chaque changement sur deux axes, dont un **Standards**. Sans fichier de standards, cet axe tourne uniquement sur une base de code smells générique — un bon filet, mais rien qui porte les conventions de *ce* dépôt : nommage, structure, forme des tests, gestion des erreurs.

> Veux-tu un `docs/agents/coding-standards.md` de départ, à compléter ? (recommandé : **oui**)

Sur **oui**, écrire le gabarit [coding-standards.md](./coding-standards.md) avec ses sections vides, en pré-remplissant la seule qui se constate sans rien demander : **Outillage en place**, déduite de l'exploration de l'étape 1 — formateur, linter, typechecker, commande de test réellement présents. Dire à l'utilisateur que le reste est à lui, et que le fichier vaut mieux incomplet qu'absent : `/code-review` lit ce qui est rempli et ignore le reste.

Ne rien inventer dans les autres sections. Des standards devinés à partir du code existant décrivent les accidents du dépôt, pas ses intentions, et une revue qui les applique reproduit ses défauts.

Sur **non**, ne pas écrire le fichier et ne pas insister : l'axe Standards fonctionne sans, sur sa base de smells.

### 3. Confirmer et laisser éditer

Montrer à l'utilisateur un brouillon de :

- Le bloc `## Agent skills` à ajouter dans celui des deux fichiers `CLAUDE.md` / `AGENTS.md` qui sera édité (règles de sélection à l'étape 4)
- Le contenu de `docs/agents/issue-tracker.md`, `docs/agents/domain.md`, `docs/agents/git-workflow.md` et `docs/agents/triage-labels.md`
- **Seulement si l'utilisateur a accepté les standards de code** en Section E : `docs/agents/coding-standards.md`, sections vides comprises
- **Seulement si l'utilisateur a demandé les garde-fous** en Section D : le hook `.claude/hooks/block-trunk-writes.sh` et les entrées ajoutées à `.claude/settings.json` (gabarit : [garde-fous.md](./garde-fous.md))

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

[résumé en une ligne du modèle de branche, et des gestes que l'agent réserve à l'accord de l'utilisateur]. Voir `docs/agents/git-workflow.md`.
```

Toujours inclure le sous-bloc `### Labels de triage`, et toujours écrire `docs/agents/triage-labels.md`.

Écrire ensuite les fichiers de docs en partant des gabarits présents dans ce dossier de skill :

- [issue-tracker-github.md](./issue-tracker-github.md) : issue tracker GitHub
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md) : issue tracker GitLab
- [issue-tracker-local.md](./issue-tracker-local.md) : issue tracker en markdown local
- [triage-labels.md](./triage-labels.md) : correspondance des labels
- [domain.md](./domain.md) : règles de lecture des docs de domaine + disposition
- [coding-standards.md](./coding-standards.md) : standards de code — seulement si l'utilisateur les a acceptés en Section E, et avec la seule section « Outillage en place » pré-remplie
- [git-workflow.md](./git-workflow.md) : modèle de branche + les gestes réservés à l'accord de l'utilisateur. Le gabarit est écrit pour un trunk nommé `main` : y substituer le trunk réel. Il suppose aussi un **remote** ; si `git remote` est muet, retirer les lignes « pousser la branche » et « ouvrir la PR » et dire à leur place que le travail s'arrête au commit local — un document qui prescrit un geste impossible se fait ignorer en entier. Si l'utilisateur a demandé les garde-fous en Section D, réécrire la section « Ce qui applique ces règles » pour dire que `.claude/settings.json` et `.claude/hooks/block-trunk-writes.sh` refusent ces commandes — un document doit dire ce qui est réellement en place, ni plus ni moins.

Pour un issue tracker « autre », rédiger `docs/agents/issue-tracker.md` de zéro à partir de la description de l'utilisateur.

**Provisionner les labels sur le tracker.** La correspondance écrite ne suffit pas : `gh` refuse un `--label` qu'il ne trouve pas au lieu de le créer, et la première publication de `to-spec` échoue sur un dépôt neuf — les labels GitHub par défaut comptent bien `wontfix`, mais pas `ready-for-agent`. Créer les cinq chaînes de la colonne de droite du fichier, une fois, en absorbant l'échec sur celles qui existent déjà :

```bash
# GitHub
for l in needs-triage needs-info ready-for-agent ready-for-human wontfix; do gh label create "$l" || true; done
# GitLab
for l in needs-triage needs-info ready-for-agent ready-for-human wontfix; do glab label create --name "$l" || true; done
```

Vérifier ensuite avec `gh label list` / `glab label list` que les cinq y sont : le `|| true` absorbe aussi bien un label déjà présent qu'un échec d'authentification. Substituer les chaînes retenues en Section B si l'utilisateur a donné les siennes — elles existent déjà sur son tracker, la boucle est alors sans effet. En markdown local, rien à créer : l'état de triage est une ligne `Status:` dans le fichier. Sur un tracker « autre », dire à l'utilisateur de poser les cinq lui-même.

**Poser les garde-fous** — seulement si l'utilisateur les a demandés en Section D. Sans cette demande, sauter les trois pas : le workflow tient dans `docs/agents/git-workflow.md` et `.claude/` reste intact.

Vérifier d'abord que `jq` ou `python3`/`python` est sur le `PATH` : le hook s'en sert pour lire la commande interceptée, et sans eux il retombe sur une analyse approximative, plus prompte aux faux positifs. Le dire à l'utilisateur avant de poser le hook.

1. Copier [scripts/block-trunk-writes.sh](./scripts/block-trunk-writes.sh) vers `.claude/hooks/block-trunk-writes.sh`, puis `chmod +x`. Si le trunk n'est pas `main`, corriger la valeur de `TRUNK` en tête du script — le script ne la devine pas.

2. **Fusionner** les entrées `permissions.deny` et le hook `PreToolUse` de [garde-fous.md](./garde-fous.md) dans `.claude/settings.json` : créer le fichier s'il n'existe pas ; s'il existe, ajouter aux tableaux présents, ne jamais remplacer un `permissions` ou un `hooks` déjà là.

3. **Vérifier que ça refuse vraiment**, avec les deux tests de [garde-fous.md](./garde-fous.md). Un garde-fou qu'on n'a pas vu bloquer n'est pas un garde-fou : si l'un des deux ne rend pas le code attendu, le dire à l'utilisateur et **ne pas** annoncer que la protection est en place.


### 5. Terminé

Dire à l'utilisateur que la configuration est faite et quels skills d'ingénierie liront désormais ces fichiers. Mentionner qu'il peut éditer `docs/agents/*.md` directement plus tard ; relancer ce skill n'est nécessaire que pour changer d'issue tracker ou repartir de zéro.

Dire aussi, en une phrase, ce que l'agent **rapportera désormais à l'utilisateur au lieu de le faire seul** — merger, pousser sur le trunk, force-pusher — et où cette règle est écrite : `docs/agents/git-workflow.md`, qu'il peut éditer.

Si les garde-fous ont été posés, ajouter que ces commandes sont en plus **refusées** par `.claude/settings.json` et `.claude/hooks/block-trunk-writes.sh` — y compris quand c'est lui qui les demande — et que ces fichiers se commitent : la limite vaut pour toute l'équipe, pas seulement pour la machine où ce skill a tourné.
