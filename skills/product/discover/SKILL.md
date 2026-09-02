---
name: discover
description: "Cadrage produit en amont : creuse le problème, les acteurs, les exigences non fonctionnelles, le périmètre et les métriques de succès, avant qu'aucune solution ne soit décidée. Deux modes — cadrage projet (long, une fois) et cadrage feature (court, à chaque nouvelle capacité)."
disable-model-invocation: true
argument-hint: "projet | feature <slug> — par défaut, déduit du contexte"
---

# Discover

Le cadrage produit : établir **quoi**, **pourquoi** et **jusqu'où**, avant qu'aucune solution technique ne soit sur la table.

Ce skill ne réinvente pas l'entretien. Il fournit un **agenda** et un **artefact de sortie** ; le moteur d'interrogation est `grilling`. Appeler l'outil Skill avec « grilling » et mener l'agenda ci-dessous comme arbre de décision : questions par rounds, frontière recalculée à chaque réponse, une recommandation proposée pour chaque question.

## Choisir le mode

- **Mode projet** — le cadrage initial, une fois par projet. Couvre l'agenda complet. Sa sortie alimente `/to-prd`.
- **Mode feature** — au début de chaque nouvelle capacité, une fois le PRD gelé. Version courte : quatre questions maximum, et le PRD sert de contexte plutôt que de le rejouer.

Si l'utilisateur n'a pas précisé, déduire : un `docs/prd.md` existant signifie mode feature ; son absence, mode projet. En cas de doute, demander en une ligne.

## Ce que ce skill ne fait pas

- **Aucune solution.** Dès qu'une réponse décrit *comment* on construit, la noter à part et revenir au problème. Le comment appartient à `/to-spec` puis à l'implémentation.
- **Aucune stack.** Les choix techniques ne sont pas discutés ici. Seules les **contraintes données** sont recueillies (une stack imposée, un existant, un budget) — ce sont des faits, pas des décisions.
- **Aucun critère d'acceptation.** Ils naissent au découpage, dans `/to-tickets`.

## Agenda — mode projet

Travailler ces sept branches dans l'ordre. Chacune est une racine de l'arbre de décision : les réponses ouvrent des sous-questions, à poser dans les rounds suivants.

1. **Le problème.** Qui le rencontre, dans quelle situation, et **ce qu'il coûte aujourd'hui**. Faire décrire le contournement actuel : sans contournement identifiable, il n'y a probablement pas de problème.
2. **Les acteurs.** Assez concrets pour qu'on puisse en nommer trois. S'il y en a plusieurs, les ordonner par gravité de la douleur, et dire lequel ce projet sert en premier.
3. **Les exigences fonctionnelles.** Ce que le système doit permettre de faire. Rester au niveau des **capacités** (« exporter ses données »), pas des comportements (« un bouton CSV qui produit un fichier UTF-8 »). Le détail comportemental appartient aux specs.
4. **Les exigences non fonctionnelles.** Performance, volumétrie, sécurité, confidentialité, disponibilité, coût d'exploitation, accessibilité, plateformes cibles, contraintes légales. Pour chacune, demander un **chiffre ou un seuil** : « rapide » n'est pas une exigence.
5. **Le périmètre.** Ce qui est dedans, et surtout ce qui est **dehors avec sa raison**. Le hors-périmètre n'est pas une liste de souhaits : ce sont les choses qu'un lecteur supposerait raisonnablement incluses.
6. **Les métriques de succès.** La branche que tout le monde saute, et la seule qui rend le projet falsifiable. Une métrique n'est utilisable que si les trois conditions tiennent : **observable** (tu pourrais aller la mesurer aujourd'hui, avec un outil que tu as), **directionnelle** (à la hausse ou à la baisse, depuis un point de départ énoncé), et **falsifiable** (il existe un monde plausible où le projet est livré et où elle ne bouge pas). Une métrique qui ne passe que les deux premières est un indicateur de tableau de bord ; une qui échoue à la troisième est un argument de vente. Si l'utilisateur ne peut vraiment pas mesurer, ne pas fabriquer un chiffre : recueillir à la place le jugement porté et le **regret observable** qui dirait qu'on avait tort.
7. **Les contraintes données.** Échéance, budget, stack imposée, système existant à respecter, compétences disponibles. Ce sont des entrées, pas des arbitrages.

## Agenda — mode feature

Le PRD porte déjà le problème, les acteurs, les exigences non fonctionnelles et les métriques. Ne pas les rejouer : les lire dans `docs/prd.md` et poser seulement ce qui est propre à cette capacité.

1. **Quelle capacité du PRD** cette feature réalise-t-elle, et l'énoncé qu'en donne le PRD tient-il encore ?
2. **Le comportement attendu**, du point de vue de l'acteur.
3. **Les limites de cette feature** : ce qu'elle ne fait pas, et ce qui est repoussé à plus tard.
4. **Comment on saura qu'elle marche** : la contribution de cette feature aux métriques du PRD.

Quatre questions est un plafond, pas un objectif. Si une seule suffit, s'arrêter là.

## Écrire la sortie

Quand la frontière est vide — chaque branche visitée, rien laissé en supposition silencieuse — écrire :

- **Mode projet** → `.scratch/discovery.md`
- **Mode feature** → `.scratch/<feature-slug>/discovery.md`

Une section par branche de l'agenda, dans l'ordre, avec les réponses telles qu'elles ont été données. Consigner les questions restées ouvertes sous `## Questions ouvertes`, avec qui peut les trancher — une liste vide est honnête, une réponse inventée ne l'est pas.

**Cet artefact est de transit.** Il n'a qu'un seul lecteur, `/to-prd` (ou `/to-spec` en mode feature), et il devient inutile une fois celui-ci écrit. Il existe pour que le cadrage survive à une fin de session, pas pour être maintenu. Le dire à l'utilisateur, et lui proposer d'enchaîner tout de suite si la session est encore vivante.

## Ensuite

- **Mode projet** → `/to-prd`
- **Mode feature** → `/to-spec`

Ne pas les lancer soi-même : c'est à l'utilisateur de décider quand le cadrage est stable.
