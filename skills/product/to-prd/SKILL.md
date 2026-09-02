---
name: to-prd
description: "Synthétise le cadrage produit en un PRD : le problème, les acteurs, les métriques de succès, le périmètre et la décomposition du projet en capacités. Pas d'interview — juste la mise en forme de ce qui a déjà été établi. Écrit docs/prd.md, l'invariant contre lequel toute la suite itère."
disable-model-invocation: true
---

# To PRD

Le PRD répond à **pourquoi**, **pour qui** et **jusqu'où**. Il ne dit pas *comment*, et il ne décrit pas le comportement du système — c'est le rôle des specs.

Sa fonction n'est pas de communiquer. Elle est structurelle : **le PRD est le point fixe qui rend l'itération falsifiable.** Sans invariant, changer une spec et changer d'avis deviennent indiscernables, et on ne peut plus dire si le projet converge.

Ne PAS interviewer l'utilisateur. Ce skill synthétise `.scratch/discovery.md` et le contexte de la conversation. Si aucun cadrage n'a eu lieu, dire à l'utilisateur de lancer `/discover` d'abord.

## Où va quoi

Deux tests décident de la place de chaque phrase. Les appliquer avant d'écrire une ligne.

**Test de portée.** Une exigence qui contraint **tout le projet** appartient au PRD. Une exigence qui décrit le comportement d'**une seule capacité** appartient à sa spec.

> « Toute donnée personnelle est chiffrée au repos » → PRD : aucune feature ne la possède, toutes la subissent.
> « L'export CSV encode en UTF-8 avec BOM » → spec : une seule capacité est concernée.

**Test de stabilité.** Une phrase appartient au PRD si elle resterait vraie en construisant une solution complètement différente.

> « Les utilisateurs perdent 20 minutes par jour à ressaisir leurs relevés » → vrai quelle que soit la solution. PRD.
> « L'import accepte les fichiers OFX » → une solution parmi d'autres. Spec.

Corollaire à vérifier en relecture : **le PRD ne contient aucune phrase commençant par « le système affiche », « l'utilisateur clique » ou « le bouton »**. Si tu en écris une, elle est dans le mauvais fichier.

## Le plafond

**Deux pages maximum.** Ce n'est pas une indication de style, c'est un mécanisme.

La phase de cadrage est séquentielle, ce qui crée une pression mécanique : « on est en train de cadrer, autant tout écrire ». Un PRD qui dépasse deux pages a commencé à contenir de la spec, et il retire à la phase itérative la latitude qui la justifie.

Si le contenu déborde, ce n'est pas le PRD qu'il faut allonger : c'est une capacité qu'il faut sortir vers sa propre spec.

## Process

1. Lire `.scratch/discovery.md` s'il existe, plus le contexte de la conversation. Lire `CONTEXT.md` si le projet en a un, pour employer son vocabulaire de domaine.

2. Si un `docs/prd.md` existe déjà, **ne pas le réécrire de zéro**. Le lire, proposer un diff des sections qui changent, et ajouter une entrée dans `## Révisions` (voir *Le gel*).

3. Rédiger avec le gabarit ci-dessous et écrire dans `docs/prd.md` — hors de `.scratch/`, qui annonce le jetable. Le PRD est le seul artefact de la chaîne qui survive au projet.

4. Montrer à l'utilisateur **les métriques de succès et le hors-périmètre, isolément**, et demander si elles tiennent. Ces deux sections portent tout le document : les autres se corrigent, celles-là s'écroulent.

5. Rappeler que le PRD est désormais gelé, et par quoi enchaîner.

<prd-template>

# PRD — <nom du projet>

## Problème

Le problème du point de vue de l'acteur, dans son vocabulaire. Ce qu'il essaie de faire, ce qui l'en empêche, et ce que ça lui coûte aujourd'hui — avec le contournement actuel. Aucun mot de solution.

## Acteurs

Assez concret pour qu'on puisse en nommer trois. S'il y en a plusieurs, les ordonner par gravité de la douleur et dire lequel ce projet sert en premier.

## Métriques de succès

Une courte liste numérotée. Chaque métrique est observable, a une direction, et peut revenir négative. Voir [metriques.md](metriques.md).

## Périmètre

Les capacités que ce projet couvre, en une ligne chacune. Pas de comportement, pas d'interface.

## Hors-périmètre

Ce que le projet ne fait délibérément pas, chacun avec sa raison en une ligne. Cette section n'est pas une liste de souhaits : ce sont les choses qu'un lecteur supposerait raisonnablement incluses. C'est elle qui évite le plus de retouches.

## Exigences non fonctionnelles

Les contraintes transverses, chacune avec un chiffre ou un seuil : performance, volumétrie, sécurité, confidentialité, disponibilité, coût, accessibilité, plateformes, obligations légales. « Rapide » n'est pas une exigence. Ne garder que celles qui contraignent réellement une décision de conception.

## Contraintes données

Échéance, budget, stack imposée, existant à respecter, compétences disponibles. Ce sont des entrées subies, pas des arbitrages : les distinguer explicitement des décisions techniques, qui n'ont pas leur place ici.

## Capacités

La décomposition du projet, une ligne par capacité. **Chaque capacité devient une spec.** C'est le joint entre la phase de cadrage et la phase itérative : sans cette liste, personne ne sait combien de specs sont attendues ni quand le projet est fini.

1. **<nom de la capacité>** — ce qu'elle permet, en une phrase, du point de vue de l'acteur.

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

## Ensuite

`/discover feature <slug>` puis `/to-spec`, une capacité à la fois.

Le PRD sera rouvert une dernière fois après livraison, pour confronter ses métriques de succès à la réalité. C'est la seule branche de validation qu'aucun test automatique ne couvre.
