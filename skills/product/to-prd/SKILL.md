---
name: to-prd
description: "Synthétise le cadrage produit en un PRD : le problème, les acteurs, les métriques de succès, le périmètre et la décomposition du projet en fonctionnalités. Pas d'interview — juste la mise en forme de ce qui a déjà été établi. Écrit docs/prd.md, l'invariant contre lequel toute la suite itère."
disable-model-invocation: true
---

# To PRD

Le PRD répond à **pourquoi**, **pour qui** et **jusqu'où**. Il ne dit pas *comment*, et il ne décrit pas le comportement du système — c'est le rôle des specs.

Sa fonction n'est pas de communiquer. Elle est structurelle : **le PRD est le point fixe qui rend l'itération falsifiable.** Sans invariant, changer une spec et changer d'avis deviennent indiscernables, et on ne peut plus dire si le projet converge.

Ne PAS interviewer l'utilisateur. Ce skill synthétise `.scratch/discovery.md` et le contexte de la conversation — l'un des deux suffit : un cadrage mené dans la fenêtre courante n'a pas besoin d'avoir laissé de fichier. C'est l'absence de matière — ni fichier, ni cadrage tenu en conversation — qui renvoie à `/discover` d'abord.

## Où va quoi

Deux tests décident de la place de chaque phrase. Les appliquer avant d'écrire une ligne.

**Test de portée.** Une exigence qui contraint **tout le projet** appartient au PRD. Une exigence qui décrit le comportement d'**une seule fonctionnalité** appartient à sa spec.

> « Toute donnée personnelle est chiffrée au repos » → PRD : aucune feature ne la possède, toutes la subissent.
> « L'export CSV encode en UTF-8 avec BOM » → spec : une seule fonctionnalité est concernée.

**Test de stabilité.** Une phrase appartient au PRD si elle resterait vraie en construisant une solution complètement différente.

> « Les utilisateurs perdent 20 minutes par jour à ressaisir leurs relevés » → vrai quelle que soit la solution. PRD.
> « L'import accepte les fichiers OFX » → une solution parmi d'autres. Spec.

Corollaire à vérifier en relecture : **le PRD ne contient aucune phrase commençant par « le système affiche », « l'utilisateur clique » ou « le bouton »**. Si tu en écris une, elle est dans le mauvais fichier.

## Le plafond

**Deux pages maximum.** Ce n'est pas une indication de style, c'est un mécanisme.

La phase de cadrage est séquentielle, ce qui crée une pression mécanique : « on est en train de cadrer, autant tout écrire ». Un PRD qui dépasse deux pages a commencé à contenir de la spec, et il retire à la phase itérative la latitude qui la justifie.

Si le contenu déborde, ce n'est pas le PRD qu'il faut allonger : c'est une fonctionnalité qu'il faut sortir vers sa propre spec.

## Process

1. Lire `.scratch/discovery.md` s'il existe, plus le contexte de la conversation. Lire `CONTEXT.md` si le projet en a un, pour employer son vocabulaire de domaine.

2. Si un `docs/prd.md` existe déjà, **ne pas le réécrire de zéro**. Le lire, proposer un diff des sections qui changent, et ajouter une entrée dans `## Révisions` (voir *Le gel*).

3. Rédiger avec le gabarit ci-dessous et écrire dans `docs/prd.md` — hors de `.scratch/`, qui annonce le jetable. Le PRD est le seul artefact de la chaîne qui survive au projet.

4. Montrer à l'utilisateur **les métriques de succès, le hors-périmètre et le lot 1, isolément**, et demander s'ils tiennent. Ces trois sections portent tout le document : les autres se corrigent, celles-là s'écroulent. Pour le lot 1, énoncer la dérivation — quelle métrique il fait bouger, et pourquoi rien de plus petit n'y suffit.

5. Rappeler que le PRD est désormais gelé, puis **proposer nommément la première fonctionnalité du lot 1** — son nom, le slug en kebab-case que porte sa ligne dans le PRD, et sa justification : ce dont elle ne dépend pas, la métrique qu'elle porte, les couches qu'elle traverse. Ne pas se contenter de nommer la commande à lancer : sans proposition concrète, personne ne choisit et le projet s'arrête là. L'utilisateur ratifie ou corrige.

<prd-template>

# PRD — <nom du projet>

## Problème

Le problème du point de vue de l'acteur, dans son vocabulaire. Ce qu'il essaie de faire, ce qui l'en empêche, et ce que ça lui coûte aujourd'hui — avec le contournement actuel. Aucun mot de solution.

## Acteurs

Assez concret pour qu'on puisse en nommer trois. S'il y en a plusieurs, les ordonner par gravité de la douleur et dire lequel ce projet sert en premier.

## Métriques de succès

Une courte liste numérotée. Chaque métrique est observable, a une direction, et peut revenir négative. Voir [metriques.md](metriques.md).

## Périmètre

Les fonctionnalités que ce projet couvre, en une ligne chacune. Pas de comportement, pas d'interface.

## Hors-périmètre

Ce que le projet ne fait délibérément pas, chacun avec sa raison en une ligne. Cette section n'est pas une liste de souhaits : ce sont les choses qu'un lecteur supposerait raisonnablement incluses. C'est elle qui évite le plus de retouches.

## Exigences non fonctionnelles

Les contraintes transverses, chacune avec un chiffre ou un seuil : performance, volumétrie, sécurité, confidentialité, disponibilité, coût, accessibilité, plateformes, obligations légales. « Rapide » n'est pas une exigence. Ne garder que celles qui contraignent réellement une décision de conception.

## Contraintes données

Échéance, budget, stack imposée, existant à respecter, compétences disponibles. Ce sont des entrées subies, pas des arbitrages : les distinguer explicitement des décisions techniques, qui n'ont pas leur place ici.

## Fonctionnalités

La décomposition du projet, une ligne par fonctionnalité. **Chaque fonctionnalité devient une spec.** Le slug que porte sa ligne nomme le `docs/specs/<feature-slug>.md` de cette spec, puis la branche `feature/<feature-slug>` qui la construira : la suite de la chaîne le lit ici plutôt que de le redériver. C'est le joint entre la phase de cadrage et la phase itérative : sans cette liste, personne ne sait combien de specs sont attendues ni quand le projet est fini.

L'ordre se **dérive**, il ne s'arbitre pas : les dépendances contraignent, les métriques départagent. Noter la dépendance sur la ligne quand elle existe.

### Lot 1 — MVP · gelé

La plus petite combinaison de fonctionnalités qui fait bouger **au moins une métrique de succès**. Ni la liste des envies, ni tout ce qui semble indispensable : la plus petite qui rend une métrique observable.

Mettre en tête celle qui **traverse le plus de couches**. C'est en la construisant que se prennent les décisions transverses — schéma, authentification, seams de test — dont toutes les suivantes hériteront. Les prendre face au cas le plus exigeant plutôt que face au plus facile.

1. **<nom de la fonctionnalité>** `<feature-slug>` — ce qu'elle permet, en une phrase, du point de vue de l'acteur.
2. **<nom de la fonctionnalité>** `<feature-slug>` — … · bloqué par 1

### Ensuite · ordre indicatif, non gelé

3. **<nom de la fonctionnalité>** `<feature-slug>` — …

### Plus tard · non ordonné

4. **<nom de la fonctionnalité>** `<feature-slug>` — …

## Questions ouvertes

Ce qui reste non tranché, avec qui peut trancher. Une liste vide est honnête ; une réponse inventée ne l'est pas.

## Révisions

| Date | Ce qui change | Pourquoi |
| ---- | ------------- | -------- |
| <AAAA-MM-JJ> | Création | — |

</prd-template>

## Le gel

Une fois écrit, **le PRD est gelé par défaut**. Il ne change que par décision explicite, et chaque changement ajoute une ligne à `## Révisions` avec sa raison.

Ce n'est pas de la rigidité administrative : c'est ce qui distingue « cadrer puis itérer » de « itérer en ayant renommé la première boucle ». Un PRD qu'on modifie librement n'est plus un invariant, et la phase itérative perd sa référence.

Le compteur de révisions est lui-même un signal. Trois révisions en un mois ne disent pas que le processus est mauvais : elles disent que le cadrage l'était, et c'est une information qu'on veut voir.

**Une exception, dans `## Fonctionnalités` :** seul le **lot 1** est gelé. Les sections *Ensuite* et *Plus tard* sont explicitement hors du gel — leur ordre bouge librement, sans révision datée.

Ce partage suit le test de stabilité. *Quelles fonctionnalités forment le premier incrément livrable* reste vrai en construisant une solution différente : c'est du produit, donc gelé. *Le séquençage de tout le reste* est un plan, révisé par ce qu'on apprend en construisant. Le geler ferait brûler une ligne de révision à chaque repriorisation, et le compteur cesserait de signaler ce qu'il est censé signaler.

## Ensuite

`/grill-with-docs` puis `/to-spec`, une fonctionnalité à la fois. Le premier tour de `/grill-with-docs` cadre la fonctionnalité contre ce PRD, puis l'entretien enchaîne sur le comment — il n'y a pas d'étape de cadrage séparée.

Une fois le lot 1 livré, rouvrir ce PRD et confronter ses métriques de succès à la réalité : c'est la seule branche de validation qu'aucun test automatique ne couvre. C'est `/validate` qui la porte, et il est le seul skill autorisé à modifier ce document — par **révision datée**, jamais en silence. Le dire à l'utilisateur : la chaîne ne le déclenchera pas toute seule, elle lui donne la commande.
