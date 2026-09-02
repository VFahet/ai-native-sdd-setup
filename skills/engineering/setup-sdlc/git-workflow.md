# Workflow git

Comment les skills d'ingénierie manipulent git dans ce dépôt. Lu par `/implement`.

## Modèle de branche

**Trunk-based, une branche par fonctionnalité.**

- La branche de référence est `main`. Elle est toujours livrable.
- Une **fonctionnalité** — une ligne du PRD, une spec, l'unité que `/to-tickets` découpe — vit sur une branche `feature/<feature-slug>` partant d'un `main` à jour.
- Un **ticket** est un commit sur cette branche, pas une branche à lui.
- La branche vit le temps de la fonctionnalité. Au-delà de deux ou trois jours, ce n'est pas le modèle de branche qui est en cause : la fonctionnalité est trop grosse. Chaque ticket étant un *tracer bullet* qui atterrit au vert, la sortie de secours est de merger par ticket plutôt que par fonctionnalité.

## Ce que l'agent fait

- **Créer la branche** au premier ticket d'une fonctionnalité, depuis un `main` à jour.
- **Commiter** sur cette branche, un commit par ticket, en référençant le ticket.
- **Pousser la branche** : `git push -u origin feature/<slug>`.
- **Ouvrir la PR** quand tous les tickets de la fonctionnalité sont clos : `gh pr create --base main`. Avant de l'ouvrir, `/implement` relit la fonctionnalité entière contre `main` et contre sa spec — la revue par ticket ne peut pas voir une exigence tombée entre deux tickets.
- **Se synchroniser** avec le trunk quand la branche a divergé : `git merge main` ou `git rebase main` **depuis la branche de fonctionnalité**. C'est de l'hygiène, pas une livraison.

## Ce que l'agent ne fait pas

- **Merger vers le trunk.** Ni `gh pr merge`, ni `git merge feature/... ` depuis `main`, ni aucune variante. La PR est le livrable de l'agent ; la fusionner est une décision humaine.
- **Pousser sur `main`**, directement ou via `HEAD:main`.
- **Merger ou rebaser alors que `HEAD` est sur `main`.**
- **Force-pusher**, où que ce soit.

Si l'une de ces opérations est nécessaire, la proposer à l'utilisateur et s'arrêter. Ne pas contourner un garde-fou qui refuse une commande — le refus est le mécanisme, pas un obstacle.

## Garde-fous

Ces règles sont **appliquées**, pas seulement écrites :

- `.claude/settings.json` → `permissions.deny` refuse les formes catégoriques (`gh pr merge`, force-push).
- `.claude/hooks/block-trunk-writes.sh` est un hook `PreToolUse` sur `Bash` qui refuse les formes **directionnelles** — celles qui ne sont interdites qu'en fonction de leur cible ou de la branche courante.

La distinction est volontaire : `git merge` n'est pas interdit en soi, il l'est *vers le trunk*. Un blocage catégorique casserait `/resolving-merge-conflicts` et la synchronisation de branche.
