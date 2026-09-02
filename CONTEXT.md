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

**smart zone**
La portion de la fenêtre de contexte (~150k tokens sur les modèles de pointe) à l'intérieur de laquelle le modèle raisonne encore finement. Au-delà, il répond toujours mais dégrade sans le signaler. C'est ce qui dimensionne les limites de phase.
_À ne pas traduire par_ : zone intelligente, zone de lucidité

**trunk**
La branche d'intégration du dépôt — `main` le plus souvent, mais le nom réel se lit dans le dépôt, jamais supposé. « Branche principale » désigne aussi bien la branche courante d'un développeur, donc ne tranche rien ; « tronc » perd le rattachement à _trunk-based development_, le modèle de branche d'où le terme vient. Le mot porte en plus la direction : on part du trunk, on y revient par une PR.
_À ne pas traduire par_ : tronc, branche principale

**wizard**
Le script bash que produit `/wizard` : il guide un humain, pas à pas, à travers une procédure manuelle. Le mot désigne l'artefact autant que la commande qui le fabrique ; « assistant » perdrait ce lien et se confondrait avec l'agent lui-même.
_À ne pas traduire par_ : assistant, magicien

**ADR** — _Architecture Decision Record_. Sigle usuel, non traduit.

**spec**
Le document technique produit par `/to-spec`. « Spécification » est correct mais lourd en usage répété ; « spec » est l'usage courant en français technique.

### 3. Les identifiants techniques

Chemins, noms de fichiers, labels de triage, commandes shell, clés de configuration : jamais traduits. `.scratch/<feature-slug>/spec.md` reste tel quel.

**Exception : les exemples illustratifs.** Quand un skill montre l'arborescence d'un projet imaginaire pour expliquer une convention, les noms de domaine de cet exemple sont francisés — `src/ordering/` devient `src/commandes/`, `0001-event-sourced-orders.md` devient `0001-commandes-event-sourcees.md`. Un lecteur francophone nomme ses dossiers en français ; un exemple qui ne le fait pas enseigne mal. Les liens markdown qui pointent vers ces chemins d'exemple suivent, pour que la cible corresponde au dossier montré.

La frontière est nette : ce qui est francisé, c'est le **domaine imaginaire** de l'exemple. Tout ce qui est une convention réelle de l'outillage reste intact, même à l'intérieur d'un exemple — `CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/`, `.scratch/`, `docs/agents/`, `package.json` — ainsi que les identifiants de code (`OrderPlaced`, `CustomerId`, `Money`).

## Vocabulaire du domaine

**Issue tracker** (ou **tracker**)
L'endroit où vivent les issues d'un dépôt : GitHub Issues, GitLab, ou une convention markdown locale sous `.scratch/`. Les skills `to-tickets` et `to-spec` y lisent et y écrivent. Configuré par `/setup-sdlc`.
_À éviter_ : gestionnaire de tickets, backlog, outil de suivi

**Ticket**
Une unité de travail suivie dans le tracker : bug, tâche, ou tranche produite par `/to-tickets`.

**Skill promu**
Un skill des buckets `product/`, `engineering/` ou `productivity/` : traduit ou écrit ici, déclaré dans `plugin.json`, livré. Par opposition à `backlog/`, qui contient les skills repris du dépôt d'origine mais non traduits et non livrés.

**Fonctionnalité**
Une ligne de la décomposition finale du PRD. Le `<feature-slug>` du tracker local désigne le même objet. Une fonctionnalité donne exactement une spec, et c'est ce rapport 1 → 1 qui fait le joint entre la phase de cadrage et la phase itérative. Un PRD qui ne produit qu'une fonctionnalité aurait dû être une spec.
_À éviter_ : epic, module, capacité

**Lot**
Un groupe ordonné de fonctionnalités dans le PRD. Le **lot 1** est le MVP : la plus petite combinaison qui fait bouger au moins une métrique de succès, et la seule partie de `## Fonctionnalités` que le gel couvre. Les lots suivants portent un ordre indicatif, librement révisable.
_À éviter_ : release, jalon, sprint, phase
_Ne pas confondre_ avec les lots de migration d'un refactor expand–contract (`to-tickets`), qui sont des groupes de tickets.
