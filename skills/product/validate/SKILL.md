---
name: validate
description: "Confronte les métriques de succès de `docs/prd.md` à la réalité, une fois un lot livré, et conclut : passer au lot suivant, ou rouvrir le PRD par révision datée. La branche montante du V — la seule que ne couvre aucun test automatique. À utiliser quand un lot est livré, ou quand l'utilisateur demande si le projet marche."
disable-model-invocation: true
---

Le PRD énonce des **métriques de succès** : observables, orientées, et capables de revenir négatives. Toute la chaîne descend de ce document sans jamais y revenir. Ce skill est le retour.

Il ne mesure pas la qualité du code — `/code-review` et la suite de tests s'en chargent. Il mesure si **ce qui a été construit a produit l'effet annoncé**. Un projet peut être vert de bout en bout et n'avoir bougé aucune métrique.

**Ce skill peut modifier `docs/prd.md`.** Il est le seul, et seulement à l'étape 5. Le gel du PRD n'est pas une interdiction d'écrire : c'est l'interdiction d'y toucher **sans révision datée**, précisément pour que « corriger une erreur » et « changer d'avis » restent distinguables. Ce skill est le geste que le gel prévoit.

## Process

### 1. Vérifier qu'il y a quelque chose à mesurer

Sans livraison, il n'y a rien à confronter. **Ne pas inventer de mesure, ne pas extrapoler, ne pas rapporter une intention comme un résultat.**

L'utilisateur passe un numéro de lot, ou rien — sans argument, prendre le plus petit lot dont au moins une fonctionnalité est livrée.

Reprendre dans `docs/prd.md` la liste des fonctionnalités de ce lot, avec leur slug. Pour chacune, lire l'en-tête de `docs/specs/<feature-slug>.md` :

- toutes à `Implemented` → le lot est livré, continuer ;
- certaines à `Draft` ou `Approved` → **s'arrêter** et dire lesquelles manquent. Un lot à moitié construit ne fait pas bouger une métrique de lot, et le mesurer produirait un faux négatif qui condamnerait une conception encore valable ;
- pas de fichier de spec → le dire : cette fonctionnalité n'est pas passée par la chaîne, son état ne se constate pas ici.

`Superseded by …` compte comme livré si la spec qui l'a remplacée est `Implemented`. Sinon c'est un trou, à signaler.

### 2. Relire les métriques

Reprendre `## Métriques de succès` du PRD, **telles qu'elles sont écrites**. Ne pas les reformuler, ne pas les assouplir, ne pas en ajouter. Une métrique reformulée après coup ne peut plus revenir négative, et c'est tout l'intérêt qu'elle avait.

Relever aussi les **exigences non fonctionnelles chiffrées** du PRD : ce sont des seuils, mesurables au même titre.

### 3. Établir comment chacune se mesure

Pour chaque métrique, dire d'où vient le chiffre **avant** de le chercher :

- ce que le produit journalise déjà ;
- ce qu'un script ou une requête peut extraire ;
- ce qui demande une observation manuelle, et laquelle ;
- ce qui n'est **pas mesurable en l'état** — et c'est un constat de plein droit, pas un échec de ce skill. Une métrique que rien n'observe est une métrique morte : le rapport doit la nommer comme telle, et l'étape 5 décide si on l'instrumente ou si on l'abandonne.

Ne rien mesurer dont la source n'a pas été énoncée d'abord. Un chiffre sans provenance nommable n'est pas une mesure.

### 4. Mesurer, et rapporter par métrique

Une entrée par métrique, dans l'ordre du PRD :

- **La métrique**, citée du PRD.
- **La source** retenue à l'étape 3.
- **Le chiffre observé**, ou l'absence de mesure.
- **Le verdict** : atteinte, non atteinte, ou non mesurable.

Puis, séparément, ce que la livraison a appris et que le PRD n'avait pas prévu : un usage inattendu, une hypothèse démentie, un coût qui n'était pas au budget. C'est souvent ce qui compte le plus, et aucune métrique ne le porte.

**Ne pas moyenner, ne pas donner de note globale.** Trois métriques dont une échoue ne font pas « deux tiers de réussite » : elles font une métrique qui échoue, et c'est elle qui décide de la suite.

### 5. Conclure, et n'écrire qu'ensuite

Trois issues, à proposer à l'utilisateur — **la décision lui appartient, ce skill ne tranche pas** :

- **Les métriques du lot sont atteintes** → passer au lot suivant. Rien à écrire dans le PRD ; annoncer la première fonctionnalité du lot suivant, avec son slug.
- **Une métrique n'est pas atteinte** → la question est *pourquoi*, et elle a deux réponses très différentes : le produit ne fait pas ce qu'il fallait, ou la métrique était mal choisie. La première appelle une fonctionnalité de plus ; la seconde appelle une **révision datée** du PRD. Les confondre, c'est réécrire l'objectif pour qu'il colle au résultat.
- **Une métrique n'est pas mesurable** → décider si on l'instrumente ou si on la remplace. La remplacer est une révision datée.

Sur révision retenue, et seulement alors, écrire dans `docs/prd.md` : ajouter la ligne datée sous la section touchée, en gardant le texte d'origine visible. On ne remplace jamais en silence — le PRD doit continuer de porter ce qu'on croyait au départ, sinon on perd la seule trace de ce qu'on a appris.

```markdown
> **Révision du <AAAA-MM-JJ>** — <ce qui change, et le fait mesuré qui l'impose>.
> Texte d'origine conservé ci-dessus.
```

## Ensuite

Lot suivant : `/grill-with-docs` sur sa première fonctionnalité — annoncer son nom et son slug, pas seulement la commande.

Révision du PRD : la ligne datée écrite, dire à l'utilisateur quelles specs existantes elle rend potentiellement `Superseded by …`. Ce skill ne les modifie pas ; il les nomme.
