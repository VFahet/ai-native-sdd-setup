---
name: research
description: Enquêter sur une question en s'appuyant sur des sources primaires de confiance et consigner les conclusions dans un fichier Markdown du dépôt. À utiliser quand l'utilisateur veut faire rechercher un sujet, rassembler des faits sur une doc ou une API, ou déléguer le travail de lecture à un agent en arrière-plan.
---

Lance un **agent en arrière-plan** pour mener la recherche, afin de continuer à travailler pendant qu'il lit.

Sa mission :

1. Enquêter sur la question à partir de **sources primaires** (docs officielles, code source, specs, API first-party), et non d'un compte rendu secondaire de celles-ci. Remonter chaque affirmation jusqu'à la source qui en est propriétaire.
2. Écrire les conclusions dans un unique fichier Markdown, en citant la source de chaque affirmation.
3. L'enregistrer dans `docs/research/<sujet-slug>.md`, où `/discover` et `/grill-with-docs` savent le lire. Si le dépôt range déjà ce genre de notes ailleurs, sa convention prime : s'y conformer et indiquer le chemin retenu.
