# Prototype d'UI

Générer **plusieurs variantes d'UI radicalement différentes** sur une seule route, permutables depuis une barre flottante en bas. L'utilisateur passe de l'une à l'autre dans le navigateur, en choisit une (ou pioche des morceaux dans chacune), puis jette le reste.

Si la question porte sur la logique / l'état plutôt que sur l'apparence, c'est la mauvaise branche. Utiliser [LOGIC.md](LOGIC.md).

## Quand c'est la bonne forme

- « À quoi devrait ressembler cette page ? »
- « Je veux voir quelques options pour ce tableau de bord avant de m'engager. »
- « Essaie une autre mise en page pour l'écran de réglages. »
- Chaque fois que l'utilisateur passerait sinon une journée à choisir entre trois maquettes floues dans sa tête.

## Deux sous-formes : préférer fortement la sous-forme A

Un prototype d'UI est bien plus facile à juger quand il **frotte contre le reste de l'application** : vrai en-tête, vraie barre latérale, vraies données, vraie densité. Une route jetable isolée est un vide : chaque variante a l'air correcte en isolation. Choisir par défaut la sous-forme A dès qu'il existe une page plausible pour héberger les variantes. Ne recourir à la sous-forme B que si le prototype n'a réellement nulle part où loger à proximité.

### Sous-forme A : ajustement d'une page existante (préférée)

La route existe déjà. Les variantes sont rendues **sur la même route**, conditionnées par un paramètre de recherche d'URL `?variant=`. Le fetching de données existant, les paramètres et l'auth restent en place. Seul le rendu change. C'est le choix par défaut : le prendre sauf raison précise de faire autrement.

Si le prototype concerne quelque chose qui n'a pas encore de page mais qui *vivrait naturellement à l'intérieur d'une page* (une nouvelle section du tableau de bord, une nouvelle carte sur l'écran de réglages, une nouvelle étape dans un flux existant), c'est quand même la sous-forme A. Monter les variantes à l'intérieur de la page hôte.

### Sous-forme B : une nouvelle page (dernier recours)

N'utiliser ceci que quand la chose prototypée n'a réellement aucune page existante où loger (p. ex. une surface de premier niveau entièrement nouvelle, ou un flux qui ne peut être embarqué nulle part de manière sensée).

Créer une **route jetable** en suivant la convention de routage déjà en place dans le projet. Ne pas inventer une nouvelle structure de premier niveau. La nommer de façon qu'on voie tout de suite que c'est un prototype (p. ex. inclure le mot `prototype` dans le chemin ou le nom de fichier). Même motif `?variant=`.

Avant de s'engager dans la sous-forme B, vérifier : n'y a-t-il vraiment aucune page existante où cela pourrait être embarqué ? Une route vide masque des problèmes de conception qu'une page peuplée exposerait.

Dans les deux sous-formes, la barre flottante en bas est identique.

## Procédure

### 1. Énoncer la question et choisir N

Par défaut, **3 variantes**. Au-delà de 5, elles cessent d'être radicalement différentes et deviennent du bruit : plafonner là.

Noter le plan en une ligne, à l'emplacement du prototype ou dans un commentaire en haut de fichier :

> « Trois variantes de la page de réglages, permutables via `?variant=`, sur la route `/settings` existante. »

Cela fonctionne que l'utilisateur soit là pour objecter ou non.

### 2. Générer des variantes radicalement différentes

Rédiger chaque variante. Chacune doit respecter :

- La finalité de la page et les données auxquelles elle a accès.
- La bibliothèque de composants / le système de style du projet (TailwindCSS, shadcn, MUI, CSS brut, peu importe).
- Un nom de composant exporté clair, p. ex. `VariantA`, `VariantB`, `VariantC`.

Les variantes doivent être **structurellement différentes** : mise en page différente, hiérarchie de l'information différente, affordance principale différente, pas seulement des couleurs différentes. Trois grilles de cartes légèrement retouchées, ce n'est pas un prototype d'UI, c'est du remplissage. Si deux brouillons sortent trop semblables, en refaire un avec une consigne explicite « ne pas utiliser de grille de cartes ».

### 3. Les câbler ensemble

Créer un unique composant sélecteur sur la route :

```tsx
// pseudo-code, à adapter au framework du projet
const variant = searchParams.get('variant') ?? 'A';
return (
  <>
    {variant === 'A' && <VariantA {...data} />}
    {variant === 'B' && <VariantB {...data} />}
    {variant === 'C' && <VariantC {...data} />}
    <PrototypeSwitcher variants={['A','B','C']} current={variant} />
  </>
);
```

Pour la sous-forme A (page existante) : conserver tout le fetching de données existant au-dessus du sélecteur ; seul le sous-arbre rendu change d'une variante à l'autre.

Pour la sous-forme B (nouvelle page) : la route jetable sous `/prototype/<name>` monte le même sélecteur.

### 4. Construire la barre flottante de sélection

Une petite barre en position fixe, en bas au centre de l'écran, avec trois éléments :

- **Flèche gauche** : passe à la variante précédente (avec bouclage).
- **Libellé de variante** : affiche la clé de la variante courante et, si la variante exporte un nom, ce nom aussi. Ex. `B (Sidebar layout)`.
- **Flèche droite** : avance (avec bouclage).

Comportement :

- Cliquer sur une flèche met à jour le paramètre de recherche d'URL (utiliser le routeur du framework, p. ex. `router.replace` sur Next, `navigate` sur React Router, etc.) pour que la variante soit partageable et stable au rechargement.
- Clavier : les touches `←` et `→` font aussi défiler les variantes. Ne pas intercepter les flèches quand un `<input>`, un `<textarea>` ou un `[contenteditable]` a le focus.
- Visuellement distincte de la page (p. ex. pilule à fort contraste, ombre discrète) pour qu'on voie clairement qu'elle ne fait pas partie du design évalué.
- Masquée dans les builds de production : conditionner sur `process.env.NODE_ENV !== 'production'` ou une vérification équivalente, pour qu'un merge de prototype égaré ne puisse pas livrer la barre aux utilisateurs.

Mettre le sélecteur dans un unique composant partagé pour que les deux sous-formes puissent le réutiliser. Le placer là où vit l'UI partagée du projet.

### 5. Le transmettre

Communiquer l'URL (et les clés `?variant=`). L'utilisateur les parcourra quand il en aura le temps. Le retour intéressant est en général **« je veux l'en-tête de B avec la barre latérale de C »**, qui est le design qu'il veut vraiment.

### 6. Capturer la réponse et nettoyer

Une fois qu'une variante a gagné, capturer la réponse (quelle variante et pourquoi), puis capturer le prototype comme le décrit le [SKILL](SKILL.md). Intégrer la gagnante dans le vrai code et déplacer le reste sur la branche jetable, pas dans main :

- **Sous-forme A** : intégrer la gagnante dans la page existante ; retirer de main les variantes perdantes et le sélecteur.
- **Sous-forme B** : promouvoir la variante gagnante en vraie route ; retirer de main la route jetable et le sélecteur.

L'ensemble complet des variantes est la source primaire : il atterrit donc sur la branche jetable, pas à la poubelle, car les composants de variante et le sélecteur laissés dans la branche main pourrissent vite et embrouillent le lecteur suivant.

## Anti-patterns

- **Des variantes qui ne diffèrent que par la couleur ou les textes.** C'est un ajustement, pas un prototype. De vraies variantes sont en désaccord sur la structure.
- **Trop de code partagé entre les variantes.** Un `<Header>` partagé, très bien ; un `<Layout>` partagé anéantit l'intérêt. Chaque variante doit être libre de jeter la mise en page.
- **Brancher les variantes sur de vraies mutations.** Des prototypes en lecture seule, c'est très bien. Si une variante doit muter, la pointer vers un stub : la question est « à quoi est-ce que ça devrait ressembler », pas « est-ce que le backend fonctionne ».
- **Promouvoir le prototype directement en production.** Le code des variantes a été écrit sous contraintes de prototype (pas de tests, gestion d'erreur minimale). Le réécrire proprement au moment de l'intégrer.
