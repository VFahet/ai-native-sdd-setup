# Format des learning records

Les learning records vivent dans `./learning-records/` et utilisent une numérotation séquentielle : `0001-slug.md`, `0002-slug.md`, etc. Créer le répertoire paresseusement : seulement au moment où le premier enregistrement est écrit.

Ils sont l'équivalent pédagogique des ADR : ils capturent les leçons non évidentes, les idées clés et les connaissances préalables déclarées qui orienteront les sessions futures. Ils servent à calculer la zone proximale de développement.

## Gabarit

```md
# {Titre court de ce qui a été appris ou établi}

{1 à 3 phrases : ce qui a été appris (ou quelle connaissance préalable a été établie), et pourquoi cela compte pour les sessions futures.}
```

C'est tout le format. Un learning record peut tenir en un seul paragraphe. La valeur est d'enregistrer _que_ ceci est désormais su et _pourquoi_ cela change ce qu'il faut enseigner ensuite, pas de remplir des sections.

## Sections optionnelles

Ne les inclure que lorsqu'elles apportent une vraie valeur. La plupart des enregistrements n'en auront pas besoin.

- Le frontmatter **Status** (`active | superseded by LR-NNNN`) : utile quand une compréhension antérieure se révèle fausse et est remplacée.
- **Preuves** : comment l'utilisateur a démontré sa compréhension (une question à laquelle il a répondu, un exercice terminé, une expérience antérieure citée). Utile quand l'affirmation pourrait être réexaminée.
- **Implications** : ce que cela débloque ou exclut pour les sessions futures. Vaut la peine d'être noté quand ce n'est pas évident.

## Numérotation

Parcourir `./learning-records/` pour trouver le numéro existant le plus élevé et l'incrémenter de un.

## Quand écrire un learning record

En écrire un dès que l'une de ces conditions est vraie :

1. **L'utilisateur a démontré une compréhension réelle de quelque chose de non trivial** : pas une simple exposition, mais la preuve qu'il sait employer le concept correctement. Cela relève le plancher de ce qu'il faut enseigner ensuite.
2. **L'utilisateur a révélé une connaissance préalable** : « Je connais déjà X. » L'enregistrer pour que les sessions futures ne la réenseignent pas. Noter aussi la _profondeur_ revendiquée.
3. **Une idée fausse a été corrigée** : l'utilisateur croyait auparavant quelque chose de faux et voit maintenant pourquoi. Ces enregistrements ont une grande valeur : ils annoncent les futurs points de blocage sur les sujets voisins.
4. **La mission a bougé en réaction à l'apprentissage** : l'utilisateur a découvert qu'il tenait à autre chose que ce qu'il croyait. Faire un lien croisé vers [[MISSION.md]] et le mettre à jour.

### Ce qui ne compte _pas_

- Un contenu simplement survolé. Couvrir n'est pas apprendre. Attendre une preuve.
- Tout ce qui est déjà capturé de façon concise dans [[GLOSSARY.md]] sous forme de définition de terme. Ne pas dupliquer.
- Les journaux d'activité session par session. Les learning records ne sont pas un journal : ce sont des constats qui pèsent sur les décisions.

## Remplacement

Quand un enregistrement postérieur en contredit un antérieur (la compréhension de l'utilisateur s'est approfondie ou corrigée), marquer l'ancien enregistrement `Status: superseded by LR-NNNN` plutôt que de le supprimer. L'histoire de l'évolution de la compréhension est elle-même un signal utile.
