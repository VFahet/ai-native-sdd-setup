---
name: prototype
description: Construire un prototype jetable pour répondre à une question de conception. À utiliser quand l'utilisateur veut vérifier qu'un modèle d'état ou une logique tient la route, ou explorer à quoi devrait ressembler une UI.
---

# Prototype

Un prototype, c'est **du code jetable qui répond à une question**. La question décide de la forme.

## Choisir une branche

Identifier à quelle question on répond, à partir de la demande de l'utilisateur, du code environnant, ou en demandant à l'utilisateur s'il est disponible :

- **« Est-ce que cette logique / ce modèle d'état tient la route ? »** → [LOGIC.md](LOGIC.md). Construire un fichier HTML unique et partageable (boutons en libre exploration, plus des parcours guidés en onglets) qui pousse la machine à états dans des cas difficiles à raisonner sur papier, et qu'un non-développeur peut piloter.
- **« À quoi est-ce que ça devrait ressembler ? »** → [UI.md](UI.md). Générer plusieurs variantes d'UI radicalement différentes sur une seule route, permutables via un paramètre de recherche d'URL et une barre flottante en bas.

Ces deux branches sont les deux formes connues, pas une taxonomie exhaustive. Une question qui ne rentre franchement dans aucune des deux se prototype dans la forme la plus courte qui y répond — souvent un script et un tableau de résultats — en gardant les règles communes ci-dessous. Quand la question relève bien de l'une des deux, en revanche, les artefacts produits sont très différents : se tromper de branche gâche tout le prototype. Si la question est réellement ambiguë et que l'utilisateur est injoignable, choisir par défaut la branche qui colle le mieux au code environnant (un module backend → logique ; une page ou un composant → UI) et énoncer l'hypothèse en haut du prototype.

## Règles communes aux deux branches

1. **Jetable dès le premier jour, et clairement signalé comme tel.** Placer le code du prototype près de l'endroit où il sera réellement utilisé (à côté du module ou de la page qu'il prototype) pour que le contexte soit évident, mais le nommer de façon qu'un lecteur de passage voie qu'il s'agit d'un prototype, pas de production. Pour les routes d'UI jetables, respecter la convention de routage déjà en place dans le projet ; ne pas inventer une nouvelle structure de premier niveau.
2. **Trivial à lancer.** Un prototype d'UI démarre par une seule commande dans le lanceur de tâches du projet : `pnpm <name>`, `python <path>`, `bun <path>`, etc. Une démo de logique est un fichier HTML unique que l'utilisateur ouvre d'un double-clic. Dans les deux cas, aucune réflexion nécessaire pour démarrer.
3. **Pas de persistance par défaut.** L'état vit en mémoire. La persistance est ce que le prototype _vérifie_, pas ce dont il devrait dépendre. Si la question porte explicitement sur une base de données, taper dans une DB de brouillon ou un fichier local portant un nom sans ambiguïté du type "PROTOTYPE, wipe me".
4. **Pas de fioritures.** Pas de tests, pas de gestion d'erreur au-delà de ce qui rend le prototype _exécutable_, pas d'abstractions. Le but est d'apprendre quelque chose vite.
5. **Exposer l'état.** Après chaque action (logique) ou à chaque changement de variante (UI), afficher ou rendre tout l'état pertinent pour que l'utilisateur voie ce qui a changé.
6. **Le capturer une fois terminé.** Intégrer toute décision validée dans le vrai code, puis capturer le prototype lui-même comme **source primaire** : le committer sur une branche jetable, hors de main, et laisser un pointeur de contexte vers cette branche sur l'issue d'implémentation. Capturer aussi la réponse (le verdict et la question qu'il a tranchée) dans l'issue ou dans un commit. La branche main ne garde que la décision validée.
