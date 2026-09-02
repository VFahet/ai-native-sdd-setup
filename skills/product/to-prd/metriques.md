# Métriques de succès

Une métrique de succès est ce qui transforme un PRD en affirmation dont on peut avoir tort.

## Le test

Une métrique est utilisable quand les trois conditions tiennent :

1. **Observable** — tu pourrais aller la mesurer aujourd'hui, avec un outil que tu as.
2. **Directionnelle** — elle dit à la hausse ou à la baisse, depuis un point de départ énoncé.
3. **Falsifiable** — il existe un monde plausible où le projet est livré et où la métrique ne bouge pas.

Une métrique qui ne passe que les deux premières est un indicateur de tableau de bord. Une qui échoue à la troisième est un argument de vente.

## Exemples

| Pas une métrique | Pourquoi | Une métrique |
|---|---|---|
| « Améliorer l'expérience développeur » | Non observable | « Le temps entre `git clone` et une suite de tests verte passe sous 5 minutes » |
| « Les utilisateurs adorent le nouveau parcours » | Non falsifiable — on trouvera toujours quelqu'un | « Les tickets de support étiquetés `onboarding` baissent de moitié en deux mois » |
| « Livrer la fonctionnalité d'export » | C'est le travail, pas son effet | « 60 % des comptes qui ouvrent la fenêtre d'export vont au bout » |
| « Réduire la latence » | Ni direction ni point de départ | « La latence p95 de la recherche passe de 800 ms à moins de 300 ms » |

## Avance et retard

Quand le travail dépasse quelques semaines, en prendre une de chaque.

Une métrique **retardée** est le résultat que tu veux vraiment (rétention, coût, chiffre d'affaires). C'est l'honnête, et elle arrive trop tard pour piloter.

Une métrique **avancée** est le comportement qui devrait bouger en premier si la théorie est juste (activation, taux de complétion, temps jusqu'au premier succès). Elle arrive à temps pour agir, et elle n'a de valeur que si tu as dit **à l'avance** quelle métrique retardée elle est censée prédire.

Écrire l'appariement. « Le taux de complétion monte, ce dont on attend qu'il se traduise par moins d'abandons en semaine deux » est une théorie que la livraison peut réfuter. Deux nombres sans lien ne le sont pas.

## Quand on ne peut vraiment pas mesurer

Certains travaux sont réels et non mesurables à court terme : un outil interne à trois utilisateurs, un refactor qui achète de l'optionalité. Ne pas fabriquer un chiffre. Écrire à la place :

> **Pas de métrique.** On construit ceci parce que <le jugement porté>. On saura qu'on avait tort si <le regret observable>.

La clause de regret est la moitié falsifiable. Elle n'est pas optionnelle.
