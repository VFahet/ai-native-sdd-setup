# Design It Twice

Quand l'utilisateur veut explorer des interfaces alternatives pour un candidat à l'approfondissement retenu, utiliser ce patron de sous-agents parallèles. D'après « Design It Twice » (Ousterhout) : ta première idée a peu de chances d'être la meilleure.

Utilise le vocabulaire de [SKILL.md](SKILL.md) : **module**, **interface**, **seam**, **adaptateur**, **levier**.

## Processus

### 1. Cadrer l'espace du problème

Avant de lancer les sous-agents, rédiger à destination de l'utilisateur une explication de l'espace du problème pour le candidat retenu :

- Les contraintes que toute nouvelle interface devrait satisfaire
- Les dépendances sur lesquelles elle s'appuierait, et la catégorie dont elles relèvent (voir [DEEPENING.md](DEEPENING.md))
- Une esquisse de code grossière et illustrative pour ancrer les contraintes — pas une proposition, juste un moyen de rendre les contraintes concrètes

Montrer ça à l'utilisateur, puis passer immédiatement à l'étape 2. L'utilisateur lit et réfléchit pendant que les sous-agents travaillent en parallèle.

### 2. Lancer les sous-agents

Lancer 3 sous-agents ou plus en parallèle. Chacun doit produire une interface **radicalement différente** pour le module approfondi.

Donner à chaque sous-agent un brief technique distinct (chemins de fichiers, détails de couplage, catégorie de dépendance issue de [DEEPENING.md](DEEPENING.md), ce qui se trouve derrière le seam). Ce brief est indépendant de l'explication de l'espace du problème destinée à l'utilisateur à l'étape 1. Donner à chaque agent une contrainte de conception différente :

- Agent 1 : « Minimiser l'interface : viser 1 à 3 points d'entrée maximum. Maximiser le levier par point d'entrée. »
- Agent 2 : « Maximiser la flexibilité : supporter de nombreux cas d'usage et l'extension. »
- Agent 3 : « Optimiser pour l'appelant le plus courant : rendre le cas par défaut trivial. »
- Agent 4 (le cas échéant) : « Concevoir autour des Ports & Adapters pour les dépendances qui traversent le seam. »

Inclure dans le brief à la fois le vocabulaire de [SKILL.md](SKILL.md) et celui de CONTEXT.md, pour que chaque sous-agent nomme les choses de façon cohérente avec le langage de l'architecture et le langage du domaine du projet.

Chaque sous-agent produit :

1. L'interface (types, méthodes, params, plus les invariants, l'ordre d'appel, les modes d'erreur)
2. Un exemple d'usage montrant comment les appelants s'en servent
3. Ce que l'implémentation cache derrière le seam
4. La stratégie de dépendances et les adaptateurs (voir [DEEPENING.md](DEEPENING.md))
5. Les compromis : où le levier est fort, où il est faible

### 3. Présenter et comparer

Présenter les conceptions l'une après l'autre pour que l'utilisateur puisse absorber chacune, puis les comparer en prose. Les contraster par **profondeur** (le levier à l'interface), **localité** (où se concentre le changement) et **placement du seam**.

Après la comparaison, donner ta propre recommandation : quelle conception te paraît la plus solide, et pourquoi. Si des éléments de plusieurs conceptions se combinent bien, proposer un hybride. Avoir un avis tranché : l'utilisateur veut une position ferme, pas un menu.
