# Issue tracker : markdown local

Les issues et les specs de ce dépôt vivent comme fichiers markdown dans `.scratch/`.

## Conventions

- Une feature par répertoire : `.scratch/<feature-slug>/`
- La spec est `.scratch/<feature-slug>/spec.md`
- Les issues d'implémentation sont un fichier par ticket, à `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numérotés à partir de `01` — jamais un fichier unique regroupant tous les tickets
- L'état de triage est consigné sur une ligne `Status:` en haut de chaque fichier d'issue (voir `triage-labels.md` pour les chaînes de rôle)
- Les commentaires et l'historique de conversation s'ajoutent en bas du fichier, sous un titre `## Comments`

## Quand un skill dit « publier dans l'issue tracker »

Créer un nouveau fichier sous `.scratch/<feature-slug>/` (en créant le répertoire si besoin).

## Quand un skill dit « récupérer le ticket concerné »

Lire le fichier au chemin indiqué. L'utilisateur passe normalement le chemin ou le numéro d'issue directement.

## Opérations de wayfinding

Utilisées par `/wayfinder`. La **carte** est un fichier, avec un fichier **enfant** par ticket.

- **Carte** : `.scratch/<chantier>/map.md`, avec le corps en cinq sections que décrit `/wayfinder` — Destination, Notes, Décisions à ce jour, Pas encore spécifié, Hors périmètre.
- **Ticket enfant** : `.scratch/<chantier>/decisions/<NN>-<slug>.md`, numéroté à partir de `01`, avec la question dans le corps — le chemin dit ce que le ticket *est*, une décision et non une tranche à construire, ce qui laisse `.scratch/*/issues/` non ambigu pour `/implement`. Une ligne `Type:` consigne le type de ticket (`research`/`prototype`/`grilling`/`task`) ; une ligne `Status:` consigne `claimed`/`resolved`.
- **Blocage** : une ligne `Blocked by: NN, NN` en haut du fichier. Un ticket est débloqué quand tous les fichiers qu'il liste sont `resolved`.
- **Frontière** : parcourir `.scratch/<chantier>/decisions/` à la recherche des fichiers ouverts, débloqués et non réservés ; le plus petit numéro l'emporte.
- **Réserver** : passer `Status: claimed` et enregistrer avant tout travail.
- **Résoudre** : ajouter la réponse sous un titre `## Answer`, passer `Status: resolved`, puis ajouter un pointeur de contexte (résumé + lien) aux Décisions à ce jour dans `map.md`.
