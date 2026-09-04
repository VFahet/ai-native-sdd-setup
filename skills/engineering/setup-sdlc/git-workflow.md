# Workflow git

Comment les skills d'ingénierie manipulent git dans ce dépôt. Lu par `/implement`.

## Modèle de branche

**Trunk-based, une branche par fonctionnalité.**

- Le trunk est `main`. Il est toujours livrable.
- Une **fonctionnalité** — une ligne du PRD, une spec, l'unité que `/to-tickets` découpe — vit sur une branche `feature/<feature-slug>` partant d'un `main` à jour.
- Un **ticket** est un commit sur cette branche, pas une branche à lui.
- La branche vit le temps de la fonctionnalité. Au-delà de deux ou trois jours, ce n'est pas le modèle de branche qui est en cause : la fonctionnalité est trop grosse. Chaque ticket étant un *tracer bullet* qui atterrit au vert, la sortie de secours est de merger par ticket plutôt que par fonctionnalité.

## Ce que l'agent fait

- **Créer la branche** au premier ticket d'une fonctionnalité, depuis un `main` à jour.
- **Commiter** sur cette branche, un commit par ticket, en référençant le ticket.
- **Pousser la branche** : `git push -u origin feature/<slug>`.
- **Ouvrir la PR** quand tous les tickets de la fonctionnalité sont clos : `gh pr create --base main`. Avant de l'ouvrir, `/implement` relit la fonctionnalité entière contre `main` et contre sa spec — la revue par ticket ne peut pas voir une exigence tombée entre deux tickets.
- **Se synchroniser** avec le trunk quand la branche a divergé : `git merge main` ou `git rebase main` **depuis la branche de fonctionnalité**. C'est de l'hygiène, pas une livraison.

## Ce qui attend l'accord de l'utilisateur

Quatre gestes font atterrir du code sur le trunk, ou réécrivent l'historique qui y mène. L'agent en est capable, et les exécute quand l'utilisateur les lui demande — sur sa demande seule, jamais de sa propre initiative :

- **Merger vers le trunk** : `gh pr merge`, `git merge feature/...` depuis `main`, toute variante. La PR est le livrable de l'agent ; la fusionner appartient à l'utilisateur.
- **Pousser sur `main`**, directement ou via `HEAD:main`.
- **Merger ou rebaser alors que `HEAD` est sur `main`.**
- **Force-pusher**, où que ce soit.

Quand l'un de ces gestes devient nécessaire, le proposer, dire en une phrase ce qu'il changerait, et attendre la réponse. L'accord donné vaut pour le geste demandé, pas pour les suivants.

## Ce qui applique ces règles

Le document, et rien d'autre : l'agent les suit parce qu'il le lit. C'est délibéré — un blocage mécanique refuserait aussi le merge que l'utilisateur demande lui-même, et le desserrer coûterait plus cher que la protection ne rapporte.

Pour un dépôt où cet arbitrage penche dans l'autre sens — plusieurs mains, un trunk protégé par contrat — `/setup-sdlc` sait poser sur demande des garde-fous dans `.claude/` qui refusent ces commandes. Ils valent alors dans tous les cas, y compris pour un merge explicitement demandé.
