---
name: setup-sdlc
description: "Configure ce dépôt pour les skills d'ingénierie : son issue tracker, le vocabulaire des labels de triage, et l'emplacement des docs de domaine. À lancer une fois avant le premier usage des autres skills."
disable-model-invocation: true
---

# Setup SDLC

Poser la configuration propre au dépôt que les skills d'ingénierie présupposent :

- **Issue tracker** : où vivent les issues (GitHub par défaut ; le markdown local est également supporté nativement)
- **Labels de triage** : les chaînes utilisées pour les cinq rôles canoniques de triage
- **Docs de domaine** : où vivent `CONTEXT.md` et les ADR, et les règles de lecture associées

C'est un skill piloté par le dialogue, pas un script déterministe. Explorer, présenter ce qui a été trouvé, confirmer avec l'utilisateur, puis écrire.

## Process

### 1. Explorer

Regarder le dépôt courant pour comprendre son état de départ. Lire ce qui existe ; ne rien supposer :

- `git remote -v` et `.git/config` : est-ce un dépôt GitHub ? Lequel ?
- `AGENTS.md` et `CLAUDE.md` à la racine : l'un des deux existe-t-il ? Contient-il déjà une section `## Agent skills` ?
- `CONTEXT.md` et `CONTEXT-MAP.md` à la racine
- `docs/adr/` et les éventuels répertoires `src/*/docs/adr/`
- `docs/agents/` : la sortie d'un précédent passage de ce skill existe-t-elle déjà ?
- `.scratch/` : signe qu'une convention d'issue tracker en markdown local est déjà en place
- Le skill `triage` est-il installé ? (un dossier `triage` à côté de celui-ci, ou `triage` dans les skills disponibles.) C'est ce qui décide si la Section B tourne ou non.
- Signaux de monorepo : un `pnpm-workspace.yaml`, un champ `workspaces` dans `package.json`, ou un `packages/*` peuplé avec son propre `src/`. Ces signaux ne sont présents que dans un vrai dépôt multi-paquets ; leur absence signifie mono-contexte, ce qui est le cas de presque tous les dépôts.

### 2. Présenter les constats et demander

Résumer ce qui est présent et ce qui manque. Puis prendre les sections dans l'ordre. Une section, une réponse, puis la suivante.

Ouvrir chaque section par la réponse recommandée, pour que l'utilisateur puisse l'accepter d'un mot. Ne donner une ligne d'explication que lorsque le choix bifurque réellement ; sauter entièrement la section quand l'exploration a déjà tranché (Section B quand `triage` n'est pas installé, Section C quand il n'y a pas de monorepo).

**Section A : issue tracker.**

> Explication : l'« issue tracker » est l'endroit où vivent les issues de ce dépôt. Des skills comme `to-tickets`, `triage` et `to-spec` y lisent et y écrivent. Ils ont besoin de savoir s'ils doivent appeler `gh issue create`, écrire un fichier markdown sous `.scratch/`, ou suivre un autre workflow que tu décris. Choisis l'endroit où tu suis réellement le travail sur ce dépôt.

Posture par défaut : ces skills ont été conçus pour GitHub. Si un `git remote` pointe vers GitHub, proposer GitHub. S'il pointe vers GitLab (`gitlab.com` ou une instance auto-hébergée), proposer GitLab. Sinon (ou si l'utilisateur préfère), proposer :

- **GitHub** : les issues vivent dans les GitHub Issues du dépôt (utilise la CLI `gh`)
- **GitLab** : les issues vivent dans les GitLab Issues du dépôt (utilise la CLI [`glab`](https://gitlab.com/gitlab-org/cli))
- **Markdown local** : les issues vivent comme fichiers sous `.scratch/<feature>/` dans ce dépôt (bon pour les projets solo ou les dépôts sans remote)
- **Autre** (Jira, Linear, etc.) : demander à l'utilisateur de décrire le workflow en un paragraphe ; le skill le consignera tel quel en prose libre

Consigner le choix dans `docs/agents/issue-tracker.md`. Les gabarits GitHub et GitLab portent un drapeau « PR comme surface de demande », **désactivé** par défaut. Le laisser désactivé et ne pas soulever la question : un utilisateur qui veut voir les PR externes dans la file de triage pourra basculer le drapeau dans le fichier plus tard.

**Section B : vocabulaire des labels de triage.** Sauter entièrement cette section si le skill `triage` n'est pas installé (l'exploration l'a dit), puisqu'un skill non installé n'a besoin d'aucun label.

S'il est installé, poser exactement une question :

> Veux-tu garder les labels de triage par défaut ? (recommandé : **oui**)

Les valeurs par défaut sont les cinq rôles canoniques, chaque label étant égal à son nom : `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. Sur **oui**, les écrire tels quels. Seulement si l'utilisateur dit non — en général parce que son tracker utilise déjà d'autres noms (par exemple `bug:triage` pour `needs-triage`) — collecter les correspondances, pour que `triage` applique les labels existants au lieu d'en créer des doublons.

**Section C : docs de domaine.** Par défaut, **mono-contexte** (un `CONTEXT.md` + `docs/adr/` à la racine du dépôt). Cela convient à presque tous les dépôts ; l'écrire sans demander.

Ne proposer le **multi-contexte** (un `CONTEXT-MAP.md` racine pointant vers un `CONTEXT.md` par contexte) que si l'exploration a trouvé des signaux de monorepo. Confirmer alors la disposition voulue.

### 3. Confirmer et laisser éditer

Montrer à l'utilisateur un brouillon de :

- Le bloc `## Agent skills` à ajouter dans celui des deux fichiers `CLAUDE.md` / `AGENTS.md` qui sera édité (règles de sélection à l'étape 4)
- Le contenu de `docs/agents/issue-tracker.md`, `docs/agents/domain.md` et `docs/agents/triage-labels.md` (ce dernier seulement si `triage` est installé)

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
```

N'inclure le sous-bloc `### Labels de triage`, et n'écrire `docs/agents/triage-labels.md`, que si `triage` est installé et que la Section B a tourné. Sinon, omettre les deux.

Écrire ensuite les fichiers de docs en partant des gabarits présents dans ce dossier de skill :

- [issue-tracker-github.md](./issue-tracker-github.md) : issue tracker GitHub
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md) : issue tracker GitLab
- [issue-tracker-local.md](./issue-tracker-local.md) : issue tracker en markdown local
- [triage-labels.md](./triage-labels.md) : correspondance des labels (seulement si `triage` est installé)
- [domain.md](./domain.md) : règles de lecture des docs de domaine + disposition

Pour un issue tracker « autre », rédiger `docs/agents/issue-tracker.md` de zéro à partir de la description de l'utilisateur.

### 5. Terminé

Dire à l'utilisateur que la configuration est faite et quels skills d'ingénierie liront désormais ces fichiers. Mentionner qu'il peut éditer `docs/agents/*.md` directement plus tard ; relancer ce skill n'est nécessaire que pour changer d'issue tracker ou repartir de zéro.
