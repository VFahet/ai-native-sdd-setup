# Issue tracker : GitHub

Les issues de ce dépôt vivent comme issues GitHub. Utiliser la CLI `gh` pour toutes les opérations.

## Les trois niveaux, et ce qui les distingue

Une issue GitHub n'est pas un niveau : c'est le contenant de plusieurs objets qui se ressemblent dans un `gh issue list`. La correspondance avec le monde Confluence + Jira est directe, et c'est ce qui rend la convention transposable.

| Niveau | Ici | Équivalent Jira | Marque |
|---|---|---|---|
| **document** | `docs/specs/<feature-slug>.md` | page Confluence / Notion | un fichier versionné, avec un `**Statut :**` en tête |
| **epic** | une issue titrée `spec: <feature-slug> — <titre>` | epic | le préfixe de titre |
| **ticket** | une issue enfant de l'epic | story / task | `Parent : #<epic>` en tête du corps |
| carte `/wayfinder` | une issue | — | label `wayfinder:map` |
| ticket de décision | une issue enfant de la carte | — | label `wayfinder:<type>` |

Le label `ready-for-agent` ne distingue **rien** : l'epic et ses tickets le portent tous les deux. Ce sont le préfixe de titre et la ligne `Parent` qui discriminent.

**Le corps de l'epic reste mince** — un lien vers le fichier de spec, les critères au niveau de la fonctionnalité, la liste des tickets. La spec ne s'y recopie jamais : deux corps finissent par diverger, et plus rien ne dit lequel fait foi. Le fichier fait foi.

**Un `#42` nu n'est pas un lien dans un fichier `.md` du dépôt** — l'autolinking de GitHub ne vaut que dans les corps d'issues, de PR et les messages de commit. Depuis `docs/specs/`, écrire l'URL complète.

## Conventions

- **Créer une issue** : `gh issue create --title "..." --body "..."`. Utiliser un heredoc pour les corps multi-lignes.
- **Lire une issue** : `gh issue view <numéro> --comments`, en filtrant les commentaires avec `jq` et en récupérant aussi les labels.
- **Lister les issues** : `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'` avec les filtres `--label` et `--state` appropriés.
- **Commenter une issue** : `gh issue comment <numéro> --body "..."`
- **Appliquer / retirer des labels** : `gh issue edit <numéro> --add-label "..."` / `--remove-label "..."`
- **Fermer** : `gh issue close <numéro> --comment "..."`

Déduire le dépôt de `git remote -v` ; `gh` le fait automatiquement quand il tourne dans un clone.

## Les pull requests comme surface de triage

**PR comme surface de demande : non.** _(Passer à `oui` si ce dépôt traite les PR externes comme des demandes de fonctionnalité ; le drapeau dit si la file de triage inclut les PR ou seulement les issues.)_

Quand le drapeau vaut `oui`, les PR passent par les mêmes labels et les mêmes états que les issues, avec les équivalents `gh pr` :

- **Lire une PR** : `gh pr view <numéro> --comments`, et `gh pr diff <numéro>` pour le diff.
- **Lister les PR externes à trier** : `gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments` puis ne garder que les `authorAssociation` valant `CONTRIBUTOR`, `FIRST_TIME_CONTRIBUTOR` ou `NONE` (écarter `OWNER`/`MEMBER`/`COLLABORATOR`).
- **Commenter / labelliser / fermer** : `gh pr comment`, `gh pr edit --add-label`/`--remove-label`, `gh pr close`.

GitHub partage un même espace de numérotation entre issues et PR : un `#42` nu peut donc être l'un ou l'autre. Trancher avec `gh pr view 42`, et se rabattre sur `gh issue view 42`.

## Quand un skill dit « publier dans l'issue tracker »

Créer une issue GitHub.

## Quand un skill dit « récupérer le ticket concerné »

Lancer `gh issue view <numéro> --comments`.

## Opérations de wayfinding

Utilisées par `/wayfinder`. La **carte** est une issue unique, avec des issues **enfants** comme tickets.

- **Carte** : une issue unique labellisée `wayfinder:map`, portant le corps en cinq sections que décrit `/wayfinder` — Destination, Notes, Décisions à ce jour, Pas encore spécifié, Hors périmètre. `gh issue create --label wayfinder:map`.
- **Ticket enfant** : une issue rattachée à la carte comme sous-issue GitHub (`gh api` sur l'endpoint sub-issues). Là où les sous-issues ne sont pas activées, ajouter l'enfant à une liste de tâches dans le corps de la carte et placer `Part of #<carte>` en haut du corps de l'enfant. Labels : `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Une fois réservé, le ticket est assigné au dev qui le porte.
- **Blocage** : les **dépendances natives d'issues** de GitHub, la représentation canonique et visible dans l'UI. Ajouter une arête avec `gh api --method POST repos/<owner>/<repo>/issues/<enfant>/dependencies/blocked_by -F issue_id=<id-bdd-du-bloqueur>`, où `<id-bdd-du-bloqueur>` est l'**identifiant numérique de base de données** du bloqueur (`gh api repos/<owner>/<repo>/issues/<n> --jq .id`, et _non_ le `#numéro` ni le `node_id`). GitHub renvoie `issue_dependencies_summary.blocked_by` (bloqueurs ouverts uniquement, la porte vivante). Là où les dépendances ne sont pas disponibles, se rabattre sur une ligne `Blocked by: #<n>, #<n>` en haut du corps de l'enfant. Un ticket est débloqué quand tous ses bloqueurs sont fermés.
- **Requête de frontière** : lister les enfants ouverts de la carte (`gh issue list --state open`, restreint aux sous-issues / à la liste de tâches de la carte), écarter ceux qui ont un bloqueur ouvert (`issue_dependencies_summary.blocked_by > 0`, ou une issue ouverte dans la ligne `Blocked by`) ou un assigné ; le premier dans l'ordre de la carte l'emporte.
- **Réserver** : `gh issue edit <n> --add-assignee @me`, la première écriture de la session.
- **Résoudre** : `gh issue comment <n> --body "<réponse>"`, puis `gh issue close <n>`, puis ajouter un pointeur de contexte (résumé + lien) aux Décisions à ce jour de la carte.
