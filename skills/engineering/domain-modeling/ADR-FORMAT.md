# Format des ADR

Un ADR vit dans le `docs/adr/` de sa portée et porte un numéro séquentiel : `0001-slug.md`, `0002-slug.md`, etc. Dans un dépôt mono-contexte, il n'y a qu'un `docs/adr/`, à la racine. Dans un dépôt multi-contexte (voir « Structure des fichiers » dans [SKILL.md](./SKILL.md)), une décision propre à un contexte va dans le `src/<contexte>/docs/adr/` de ce contexte, une décision à l'échelle du système dans le `docs/adr/` de la racine.

Créer le `docs/adr/` concerné paresseusement : seulement quand le premier ADR est nécessaire.

## Gabarit

```md
# {Titre court de la décision}

{1 à 3 phrases : quel est le contexte, qu'a-t-on décidé, et pourquoi.}
```

C'est tout. Un ADR peut tenir en un seul paragraphe. La valeur est de consigner *qu'une* décision a été prise et *pourquoi*, pas de remplir des sections.

## Sections optionnelles

Ne les inclure que lorsqu'elles apportent une vraie valeur. La plupart des ADR n'en auront pas besoin.

- Frontmatter **Status** (`proposed | accepted | deprecated | superseded by ADR-NNNN`) : utile quand les décisions sont réexaminées
- **Options envisagées** : seulement quand les alternatives écartées méritent d'être retenues
- **Conséquences** : seulement quand des effets en aval non évidents doivent être signalés

## Numérotation

La séquence est unique pour tout le dépôt, quelle que soit la disposition : parcourir **tous** les `docs/adr/` — celui de la racine et ceux des contextes — pour trouver le numéro existant le plus élevé, et l'incrémenter de un. Un numéro ne sert donc qu'une fois, et une référence « ADR-0007 » désigne un seul fichier, où qu'il vive.

## Quand proposer un ADR

Les trois conditions sont énoncées dans la section « Proposer des ADR avec parcimonie » de [SKILL.md](./SKILL.md) ; elles doivent toutes être vraies.

Si une décision est facilement réversible, passer : tu reviendras en arrière, voilà tout. Si elle n'est pas surprenante, personne ne se demandera pourquoi. S'il n'y avait pas de véritable alternative, il n'y a rien à consigner de plus que « on a fait la chose évidente ».

### Ce qui mérite un ADR

- **La forme architecturale.** « On utilise un monorepo. » « Le modèle d'écriture est event-sourcé, le modèle de lecture est projeté dans Postgres. »
- **Les patterns d'intégration entre contextes.** « Commandes et Facturation communiquent par événements de domaine, pas en HTTP synchrone. »
- **Les choix technologiques qui enferment.** Base de données, bus de messages, fournisseur d'authentification, cible de déploiement. Pas chaque bibliothèque : seulement celles qu'il faudrait un trimestre pour remplacer.
- **Les décisions de frontière et de périmètre.** « Les données Client appartiennent au contexte Client ; les autres contextes ne les référencent que par ID. » Les « non » explicites valent autant que les « oui ».
- **Les écarts délibérés par rapport au chemin évident.** « On écrit du SQL à la main plutôt que d'utiliser un ORM parce que X. » Tout cas où un lecteur raisonnable supposerait le contraire. Ces ADR empêchent le prochain ingénieur de « corriger » quelque chose qui était voulu.
- **Les contraintes invisibles dans le code.** « On ne peut pas utiliser AWS pour des raisons de conformité. » « Les temps de réponse doivent rester sous 200 ms à cause du contrat de l'API partenaire. »
- **Les alternatives écartées quand le rejet n'est pas évident.** Si tu as envisagé GraphQL et choisi REST pour des raisons subtiles, le consigner ; sinon quelqu'un reproposera GraphQL dans six mois.
