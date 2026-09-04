---
name: discover
description: "Cadrage produit initial d'un projet : creuse le problème, les acteurs, les exigences non fonctionnelles, le périmètre, les métriques de succès et le lot MVP, avant qu'aucune solution ne soit décidée. Une seule fois par projet ; sa sortie alimente /to-prd."
disable-model-invocation: true
---

# Discover

Le cadrage produit : établir **quoi**, **pourquoi** et **jusqu'où**, avant qu'aucune solution technique ne soit sur la table.

**Une seule fois par projet.** Le cadrage d'une fonctionnalité prise isolément n'a pas sa place ici : il appartient au premier tour de `/grill-with-docs`, qui lit le PRD et enchaîne directement sur le *comment*. Si `docs/prd.md` existe déjà, ce skill n'est pas celui qu'il te faut — sauf pour une refonte du cadrage, qui passe alors par une révision datée du PRD.

Ce skill ne réinvente pas l'entretien. Il fournit un **agenda** et un **artefact de sortie** ; le moteur d'interrogation est `grilling`. Appeler l'outil Skill avec « grilling » et mener l'agenda ci-dessous comme arbre de décision : questions par rounds, frontière recalculée à chaque réponse, une recommandation proposée pour chaque question.

Avant d'ouvrir l'entretien, lire les notes présentes sous `docs/research/` : elles alimentent l'agenda — un fait déjà établi et sourcé ne se redemande pas — sans jamais le remplacer.

## Ce que ce skill ne fait pas

- **Aucune solution.** Dès qu'une réponse décrit *comment* on construit, la noter à part et revenir au problème. Le comment appartient à `/grill-with-docs` puis à `/to-spec`.
- **Aucune stack.** Les choix techniques ne sont pas discutés ici. Seules les **contraintes données** sont recueillies (une stack imposée, un existant, un budget) — ce sont des faits, pas des décisions.
- **Aucun critère d'acceptation.** Ils naissent au découpage, dans `/to-tickets`.

## Agenda

Travailler ces huit branches dans l'ordre. Chacune est une racine de l'arbre de décision : les réponses ouvrent des sous-questions, à poser dans les rounds suivants.

1. **Le problème.** Qui le rencontre, dans quelle situation, et **ce qu'il coûte aujourd'hui**. Faire décrire le contournement actuel : sans contournement identifiable, il n'y a probablement pas de problème.
2. **Les acteurs.** Assez concrets pour qu'on puisse en nommer trois. S'il y en a plusieurs, les ordonner par gravité de la douleur, et dire lequel ce projet sert en premier.
3. **Les exigences fonctionnelles.** Ce que le système doit permettre de faire. Rester au niveau des **fonctionnalités** (« exporter ses données »), pas des comportements (« un bouton CSV qui produit un fichier UTF-8 »). Le détail comportemental appartient aux specs.
4. **Les exigences non fonctionnelles.** Performance, volumétrie, sécurité, confidentialité, disponibilité, coût d'exploitation, accessibilité, plateformes cibles, contraintes légales. Pour chacune, demander un **chiffre ou un seuil** : « rapide » n'est pas une exigence.
5. **Le périmètre.** Ce qui est dedans, et surtout ce qui est **dehors avec sa raison**. Le hors-périmètre n'est pas une liste de souhaits : ce sont les choses qu'un lecteur supposerait raisonnablement incluses.
6. **Les métriques de succès.** La branche que tout le monde saute, et la seule qui rend le projet falsifiable. Une métrique n'est utilisable que si les trois conditions tiennent : **observable** (tu pourrais aller la mesurer aujourd'hui, avec un outil que tu as), **directionnelle** (à la hausse ou à la baisse, depuis un point de départ énoncé), et **falsifiable** (il existe un monde plausible où le projet est livré et où elle ne bouge pas). Une métrique qui ne passe que les deux premières est un indicateur de tableau de bord ; une qui échoue à la troisième est un argument de vente. Si l'utilisateur ne peut vraiment pas mesurer, ne pas fabriquer un chiffre : recueillir à la place le jugement porté et le **regret observable** qui dirait qu'on avait tort.
7. **Les contraintes données.** Échéance, budget, stack imposée, système existant à respecter, compétences disponibles. Ce sont des entrées, pas des arbitrages.
8. **Le lot MVP et l'ordre.** La dernière branche, parce qu'elle dépend de toutes les autres. Établir la plus petite combinaison de fonctionnalités (branche 3) qui fait bouger **au moins une métrique** (branche 6), compte tenu des contraintes (branche 7). Ne pas demander « quelles sont tes priorités » : c'est une question qui rend à l'utilisateur le travail qui t'incombe. Proposer une combinaison **dérivée**, en énonçant la métrique visée et pourquoi rien de plus petit n'y suffit, et la faire corriger. Recueillir aussi les dépendances évidentes entre fonctionnalités — celles qui se lisent dans le flux de données (« catégoriser suppose d'avoir importé »), pas celles qui demanderaient une décision de conception. Enfin, dire laquelle du lot traverse le plus de couches : c'est elle qui passera en premier.

## Écrire la sortie

Quand la frontière est vide — chaque branche visitée, rien laissé en supposition silencieuse — écrire `.scratch/discovery.md`.

Une section par branche de l'agenda, dans l'ordre, avec les réponses telles qu'elles ont été données. Consigner les questions restées ouvertes sous `## Questions ouvertes`, avec qui peut les trancher — une liste vide est honnête, une réponse inventée ne l'est pas.

**Cet artefact est de transit.** Il n'a qu'un seul lecteur, `/to-prd`, et il devient inutile une fois celui-ci écrit. Il existe pour que le cadrage survive à une fin de session, pas pour être maintenu. Le dire à l'utilisateur, et lui proposer d'enchaîner tout de suite si la session est encore vivante.

## Ensuite

`/to-prd`. Ne pas le lancer soi-même : c'est à l'utilisateur de décider quand le cadrage est stable.
