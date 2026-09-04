# Issue tracker : GitLab

Les issues de ce dépôt vivent comme issues GitLab. Utiliser la CLI [`glab`](https://gitlab.com/gitlab-org/cli) pour toutes les opérations.

## Les trois niveaux, et ce qui les distingue

Une issue GitLab est le contenant de plusieurs objets qui se ressemblent dans un `glab issue list` :

| Niveau | Ici | Marque |
|---|---|---|
| **document** | `docs/specs/<feature-slug>.md` | un fichier versionné, avec un `**Statut :**` en tête |
| **epic** | une issue titrée `spec: <feature-slug> — <titre>` | le préfixe de titre |
| **ticket** | une issue enfant de l'epic | `Parent : #<epic>` en tête du corps |
| carte `/wayfinder` | une issue | label `wayfinder:map` |

Le label `ready-for-agent` ne distingue rien : l'epic et ses tickets le portent tous les deux.

**Le corps de l'epic reste mince** — un lien vers le fichier de spec, les critères au niveau de la fonctionnalité, la liste des tickets. La spec ne s'y recopie jamais : le fichier fait foi.

## Conventions

- **Créer une issue** : `glab issue create --title "..." --description "..."`. Utiliser un heredoc pour les descriptions multi-lignes. Passer `--description -` pour ouvrir un éditeur.
- **Lire une issue** : `glab issue view <numéro> --comments`. Utiliser `-F json` pour une sortie exploitable par machine.
- **Lister les issues** : `glab issue list -F json` avec les filtres `--label` appropriés.
- **Commenter une issue** : `glab issue note <numéro> --message "..."`. GitLab appelle les commentaires des « notes ».
- **Appliquer / retirer des labels** : `glab issue update <numéro> --label "..."` / `--unlabel "..."`. Plusieurs labels peuvent être séparés par des virgules, ou passés en répétant le drapeau.
- **Fermer** : `glab issue close <numéro>`. `glab issue close` n'accepte pas de commentaire de clôture : poster l'explication d'abord avec `glab issue note <numéro> --message "..."`, puis fermer.
- **Merge requests** : GitLab appelle les PR des « merge requests ». Utiliser `glab mr create`, `glab mr view`, `glab mr note`, etc. — même forme que `gh pr ...`, avec `mr` à la place de `pr` et `note`/`--message` à la place de `comment`/`--body`.

Déduire le dépôt de `git remote -v` ; `glab` le fait automatiquement quand il tourne dans un clone.

## Les merge requests comme surface de triage

**MR comme surface de demande : non.** _(Passer à `oui` si ce dépôt traite les merge requests externes comme des demandes de fonctionnalité ; le drapeau dit si la file de triage inclut les merge requests ou seulement les issues.)_

Quand le drapeau vaut `oui`, les MR passent par les mêmes labels et les mêmes états que les issues, avec les équivalents `glab mr` :

- **Lire une MR** : `glab mr view <numéro> --comments`, et `glab mr diff <numéro>` pour le diff.
- **Lister les MR externes à trier** : `glab mr list -F json`, puis ne garder que les MR dont l'auteur n'est ni membre ni propriétaire du projet (la MR d'un contributeur, pas le travail en cours d'un mainteneur).
- **Commenter / labelliser / fermer** : `glab mr note`, `glab mr update --label`/`--unlabel`, `glab mr close`.

Contrairement à GitHub, GitLab numérote les issues et les MR séparément : `#42` est donc sans ambiguïté dès qu'on sait de quelle surface parle le mainteneur.

## Quand un skill dit « publier dans l'issue tracker »

Créer une issue GitLab.

## Quand un skill dit « récupérer le ticket concerné »

Lancer `glab issue view <numéro> --comments`.

## Opérations de wayfinding

Utilisées par `/wayfinder`. La **carte** est une issue unique, avec des issues **enfants** comme tickets.

- **Carte** : une issue unique labellisée `wayfinder:map`, portant le corps en cinq sections que décrit `/wayfinder` — Destination, Notes, Décisions à ce jour, Pas encore spécifié, Hors périmètre. `glab issue create --label wayfinder:map`. (Sur les offres GitLab disposant des epics natives, une epic peut porter la carte à la place ; une issue labellisée fonctionne partout.)
- **Ticket enfant** : une issue portant `Part of #<carte>` en haut de sa description, et les labels `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Une fois réservé, le ticket est assigné au dev qui le porte.
- **Blocage** : le **lien de blocage natif** de GitLab, la représentation canonique et visible dans l'UI. L'ajouter avec l'action rapide `/blocked_by #<n>`, postée comme note (`glab issue note <enfant> --message "/blocked_by #<bloqueur>"`). Les liens de blocage natifs sont une fonctionnalité Premium/Ultimate ; sur l'offre gratuite (ou là où ils sont indisponibles), se rabattre sur une ligne `Blocked by: #<n>, #<n>` en haut de la description. Un ticket est débloqué quand tous ses bloqueurs sont fermés.
- **Requête de frontière** : `glab issue list -F json` restreint aux enfants de la carte, en écartant ceux qui ont un bloqueur ouvert — un lien `blocked_by` natif vers une issue ouverte (`glab api projects/:id/issues/:iid/links`), ou une issue ouverte dans la ligne `Blocked by` — ou un assigné ; le premier dans l'ordre de la carte l'emporte.
- **Réserver** : `glab issue update <n> --assignee @me`, la première écriture de la session.
- **Résoudre** : `glab issue note <n> --message "<réponse>"`, puis `glab issue close <n>`, puis ajouter un pointeur de contexte (résumé + lien) aux Décisions à ce jour de la carte.
