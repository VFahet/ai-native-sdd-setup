# AI-native SDLC

Un environnement Claude Code qui structure le cycle de développement complet — cadrage, spec, découpage, exécution, revue — sous forme de skills réutilisables d'un projet à l'autre.

## Langue

Le corps des skills est en **français**. Trois catégories échappent à la traduction, et la règle est stricte.

### 1. Les `name:` du frontmatter

Ce sont des identifiants, pas de la prose : ils deviennent les commandes (`/tdd`, `/to-spec`) et servent aux références croisées entre skills. Ils restent en anglais, en kebab-case ASCII.

### 2. Les termes de l'art

Un terme reste en anglais quand le traduire ferait perdre le concept que le skill existe précisément pour enseigner. La prose autour est en français.

**seam**
La frontière publique observable où vivent les tests : on y observe un comportement sans atteindre l'intérieur. « Couture » ne veut rien dire pour un développeur ; « point de test » perd la notion de frontière d'observation.
_À ne pas traduire par_ : couture, jointure, point de test

**tracer bullet**
Une tranche verticale qui traverse toutes les couches (schéma, API, UI, tests) de façon étroite mais complète, et qui est démontrable seule. Le terme vient de _The Pragmatic Programmer_ et porte l'image du tir traçant : on voit où la balle part avant de tirer la rafale.
_À ne pas traduire par_ : balle traçante, tranche verticale (qui n'est que la moitié du concept)

**deep module**
Un module dont l'interface est petite au regard de ce qu'il implémente. Concept d'Ousterhout, référencé tel quel dans toute la littérature.
_À ne pas traduire par_ : module profond

**expand–contract**
La séquence de migration d'un refactor large : ajouter la nouvelle forme à côté de l'ancienne, migrer les appelants par lots, puis supprimer l'ancienne.

**blast radius**
L'étendue du code cassé par un seul changement mécanique. C'est ce qui dimensionne les lots d'un `expand–contract`.

**red-green-refactor**
La boucle TDD. Traduire briserait la reconnaissance du terme et les recherches documentaires.

**grilling**
L'interview qui met une idée sous pression jusqu'à ce qu'elle tienne ou casse. Le skill s'appelle `/grilling`, le verbe reste anglais dans la prose (« griller une idée » prête à confusion).

**prefactoring**
Réarranger le code _avant_ d'ajouter la fonctionnalité, pour que l'ajout devienne simple. « Make the change easy, then make the easy change. »

**ADR** — _Architecture Decision Record_. Sigle usuel, non traduit.

**spec**
Le document technique produit par `/to-spec`. « Spécification » est correct mais lourd en usage répété ; « spec » est l'usage courant en français technique.

### 3. Les identifiants techniques

Chemins, noms de fichiers, labels de triage, commandes shell, clés de configuration : jamais traduits. `.scratch/<feature-slug>/spec.md` reste tel quel.

## Vocabulaire du domaine

**Issue tracker** (ou **tracker**)
L'endroit où vivent les issues d'un dépôt : GitHub Issues, GitLab, ou une convention markdown locale sous `.scratch/`. Les skills `to-tickets` et `to-spec` y lisent et y écrivent. Configuré par `/setup-sdlc`.
_À éviter_ : gestionnaire de tickets, backlog, outil de suivi

**Ticket**
Une unité de travail suivie dans le tracker : bug, tâche, ou tranche produite par `/to-tickets`.

**Skill promu**
Un skill des buckets `engineering/` ou `productivity/`, traduit et livré dans le plugin. Par opposition à `backlog/`, qui contient les skills conservés mais non traduits et non livrés.
