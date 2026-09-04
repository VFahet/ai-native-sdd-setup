# Standards de code

Ce que ce dépôt attend d'un changement, au-delà de ce que l'outillage applique déjà. `/code-review` lit ce fichier comme source de son axe **Standards**, et ce qui est écrit ici l'emporte sur sa base de smells par défaut.

**Ne pas y écrire ce qu'un linter, un formateur ou un typechecker applique.** Une règle appliquée mécaniquement n'a rien à faire dans un document que quelqu'un doit lire : elle produit du bruit dans les rapports de revue, sur des points déjà réglés avant la revue.

## Outillage en place

<!-- Ce que la CI ou les hooks appliquent déjà, et donc ce que la revue ne doit pas rapporter. -->

- Formatage : [outil, ou « aucun »]
- Lint : [outil et jeu de règles, ou « aucun »]
- Types : [outil et niveau de strictesse, ou « aucun »]
- Tests : [commande qui fait foi]

## Nommage

[Ce qui distingue un bon nom d'un mauvais dans ce dépôt. Renvoyer au glossaire de `CONTEXT.md` : un concept du domaine porte le nom que le glossaire lui donne, pas un synonyme.]

## Structure

[Où va quoi. Ce qui n'a pas le droit de dépendre de quoi. Les frontières que le dépôt tient et qu'aucun outil ne vérifie.]

## Tests

[Ce qui fait un test qui mérite d'être gardé ici : ce qu'il observe, ce qu'il n'a pas le droit de connaître. Les **seams** par lesquels les tests entrent. Ce que l'on substitue et ce que l'on ne substitue jamais.]

## Gestion des erreurs

[Ce qui est levé, ce qui est retourné, ce qui est journalisé. Ce qui ne doit jamais être avalé en silence.]

## Ce que ce dépôt refuse

<!-- La section la plus utile, et la plus souvent vide. -->

[Les motifs qui ont déjà coûté cher ici et qu'on ne veut plus voir. Chacun avec la raison — une interdiction sans motif se fait contourner à la première urgence.]
