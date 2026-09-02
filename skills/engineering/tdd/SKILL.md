---
name: tdd
description: Développement piloté par les tests. À utiliser quand l'utilisateur veut construire une fonctionnalité ou corriger un bug en commençant par les tests, mentionne « red-green-refactor », ou veut des tests d'intégration.
---

# Test-Driven Development

Le TDD, c'est la boucle red → green. Ce skill est la référence qui fait que cette boucle produit des tests qui méritent d'être gardés : ce qu'est un bon test, où vont les tests, les anti-patterns, et les règles de la boucle. Chaque section s'applique à chaque cycle : les consulter avant et pendant la boucle, pas après.

En explorant le code, lire `CONTEXT.md` (s'il existe) pour que les noms de tests et le vocabulaire des interfaces collent à la langue du domaine du projet, et respecter les ADR qui couvrent la zone concernée.

## Ce qu'est un bon test

Un test vérifie un comportement à travers des interfaces publiques, pas des détails d'implémentation. Le code peut changer entièrement ; les tests, non. Un bon test se lit comme une spécification : « l'utilisateur peut valider sa commande avec un panier valide » dit exactement quelle capacité existe, et il survit aux refactors parce qu'il se moque de la structure interne.

Voir [tests.md](tests.md) pour des exemples et [mocking.md](mocking.md) pour les règles de mocking.

## Seams : où vont les tests

Un **seam** est la frontière publique à laquelle tu testes : l'interface où tu observes un comportement sans atteindre l'intérieur. Les tests vivent aux seams, jamais contre les internes.

**Ne tester qu'à des seams convenus à l'avance.** Avant d'écrire le moindre test, noter les seams sous test et les confirmer avec l'utilisateur. Aucun test n'est écrit à un seam non confirmé. On ne peut pas tout tester : se mettre d'accord sur les seams en amont, c'est ce qui fait atterrir l'effort de test sur les chemins critiques et la logique complexe plutôt que sur chaque cas limite.

Demander : « Quelle est l'interface publique, et quels seams devrait-on tester ? »

Quand la forme même de cette interface est en question (quelle est la profondeur du module, où placer le seam, ce que l'interface devrait exposer), appeler l'outil Skill avec « codebase-design » pour le vocabulaire. C'est la source partagée des termes *module*, *interface*, *profondeur*, *seam*, *adaptateur*, *levier* et *localité* — une référence à consulter, pas une session à dérouler.

## Anti-patterns

- **Couplé à l'implémentation** : mocke des collaborateurs internes, teste des méthodes privées, ou vérifie par un canal détourné (interroger la base de données au lieu de passer par l'interface). Le signe : le test casse quand tu refactores alors que le comportement n'a pas changé.
- **Tautologique** : l'assertion recalcule la valeur attendue de la même façon que le code (`expect(add(a, b)).toBe(a + b)`, un snapshot dérivé à la main de la même manière, une constante comparée à elle-même) ; il passe donc par construction et ne peut jamais contredire le code. Les valeurs attendues doivent venir d'une source de vérité indépendante : un littéral connu comme bon, un exemple déroulé à la main, la spec.
- **Découpage horizontal** : écrire tous les tests d'abord, puis toute l'implémentation. Des tests écrits en bloc vérifient un comportement _imaginé_ : tu testes la _forme_ des choses plutôt que le comportement visible par l'utilisateur, les tests deviennent insensibles aux vrais changements, et tu t'engages sur une structure de tests avant d'avoir compris l'implémentation. Travailler en **tranches verticales** à la place : un test → une implémentation → on recommence, chaque test étant un **tracer bullet** qui répond à ce que le cycle précédent a appris.

## Règles de la boucle

- **Rouge avant vert.** Écrire d'abord le test qui échoue, puis juste assez de code pour le faire passer. Ne pas anticiper les tests suivants ni ajouter de fonctionnalités spéculatives.
- **Une tranche à la fois.** Un seam, un test, une implémentation minimale par cycle.
- **Le refactoring ne fait pas partie de la boucle.** Il appartient à l'étape de revue de `/implement`, pas au cycle d'implémentation rouge → vert. Quand ce skill tourne seul, hors de cette chaîne, le refactor a lieu après la boucle, sur le même critère : les tests restent verts.
