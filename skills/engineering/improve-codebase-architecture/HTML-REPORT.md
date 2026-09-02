# Format du rapport HTML

La revue d'architecture est rendue dans un unique fichier HTML autoportant, déposé dans le répertoire temporaire du système. Tailwind et Mermaid viennent tous deux de CDN. Mermaid traite les diagrammes en forme de graphe de façon fiable ; des `div` faits main et du SVG en ligne traitent les visuels plus éditoriaux (diagrammes de masse, coupes). Mélanger les deux : ne pas tout confier à Mermaid, l'ensemble finirait par avoir l'air générique.

## Structure

```html
<!doctype html>
<html lang="fr">
  <head>
    <meta charset="utf-8" />
    <title>Revue d'architecture — {{nom du dépôt}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      /* petite couche maison pour ce que Tailwind ne couvre pas proprement :
         seams en tirets, pointes de flèche à l'air dessiné, etc. */
      .seam { stroke-dasharray: 4 4; }
      .leak { stroke: #dc2626; }
      .deep { background: linear-gradient(135deg, #0f172a, #1e293b); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## En-tête

Nom du dépôt, date, et une légende compacte : cadre plein = module, ligne en tirets = seam, flèche rouge = fuite, cadre épais et sombre = deep module. Pas de paragraphe d'introduction. On entre directement dans les candidats.

## Carte de candidat

Ce sont les diagrammes qui portent le poids. La prose est rare, simple, et emploie les termes du glossaire (du skill `/codebase-design`) sans cérémonie.

Chaque candidat est un `<article>` :

- **Titre** : court, il nomme l'approfondissement (par exemple « Effondrer le pipeline d'admission des Commandes »).
- **Ligne de badges** : la force de la recommandation (`Ferme` = émeraude, `À explorer` = ambre, `Spéculatif` = ardoise), plus une étiquette pour la catégorie de dépendance (`intra-processus`, `substituable en local`, `ports & adapters`, `mock`).
- **Fichiers** : liste en chasse fixe, `font-mono text-sm`.
- **Diagramme avant / après** : la pièce maîtresse. Deux colonnes, côte à côte. Voir les motifs ci-dessous.
- **Problème** : une phrase. Ce qui fait mal.
- **Solution** : une phrase. Ce qui change.
- **Gains** : en puces, six mots maximum chacune. Par exemple : « les tests tapent une seule interface », « la logique de prix cesse de fuir », « quatre wrappers shallow supprimés ».
- **Encadré ADR** (le cas échéant) : une ligne dans un cadre teinté d'ambre.

Pas de paragraphes d'explication. Si le diagramme a besoin d'un paragraphe pour être compris, redessiner le diagramme.

## Motifs de diagramme

Choisir le motif qui convient au candidat. Les mélanger. Ne pas donner la même allure à tous les diagrammes. La variété fait partie du propos.

### Graphe Mermaid (le cheval de trait des dépendances et des flux d'appel)

Utiliser un `flowchart` ou un `graph` Mermaid quand le propos est « X appelle Y qui appelle Z, et regarde ce désordre ». L'envelopper dans une carte stylée Tailwind pour qu'il n'ait pas l'air parachuté. Styler avec `classDef` pour colorer les arêtes de fuite en rouge et le deep module en sombre. Les diagrammes de séquence marchent bien pour « avant : six allers-retours ; après : un ».

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
  <pre class="mermaid">
    flowchart LR
      A[OrderHandler] --> B[OrderValidator]
      B --> C[OrderRepo]
      C -.leak.-> D[PricingClient]
      classDef leak stroke:#dc2626,stroke-width:2px;
      class C,D leak
  </pre>
</div>
```

### Cadres et flèches faits main (quand la mise en page de Mermaid résiste)

Les modules sont des `<div>` avec bordures et étiquettes. Les flèches sont des `<line>` ou des `<path>` SVG en ligne, positionnés en absolu au-dessus d'un conteneur relatif. Y recourir quand on veut que le diagramme « après » donne l'impression d'un seul deep module à bordure épaisse, avec ses entrailles grisées : Mermaid ne rendra pas cela avec le bon poids.

### Coupe (bonne pour la shallowness en couches)

Empiler des bandes horizontales (`h-12 border-l-4`) pour montrer les couches qu'un appel traverse. Avant : six couches minces qui ne font rien. Après : une bande épaisse, étiquetée de la responsabilité consolidée.

### Diagramme de masse (bon pour « interface aussi large que l'implémentation »)

Deux rectangles par module : un pour la surface de l'interface, un pour l'implémentation. Avant : le rectangle d'interface est presque aussi haut que celui de l'implémentation (shallow). Après : le rectangle d'interface est court, celui de l'implémentation est haut (deep).

### Effondrement du graphe d'appel

Avant : un arbre d'appels de fonctions rendu en cadres imbriqués. Après : le même arbre effondré en un seul cadre, les appels devenus internes affichés en estompé à l'intérieur.

## Consignes de style

- Tirer vers l'éditorial, pas vers le tableau de bord d'entreprise. Blancs généreux. Serif possible pour les titres (`font-serif` va bien avec stone/slate).
- Peu de couleur : un accent (émeraude ou indigo), plus du rouge pour les fuites et de l'ambre pour les avertissements.
- Garder les diagrammes autour de 320 px de haut, pour que l'avant/après tienne côte à côte sans défilement.
- Utiliser `text-xs uppercase tracking-wider` pour les étiquettes de module dans les diagrammes, pour qu'elles se lisent comme un schéma et non comme de l'UI.
- Les seuls scripts sont le CDN Tailwind et l'import ESM de Mermaid. Le rapport est statique par ailleurs : pas de code applicatif, aucune interactivité au-delà du rendu de Mermaid.

## Section Recommandation principale

Une carte plus grande. Nom du candidat, une phrase sur le pourquoi, un lien d'ancre vers sa carte. Rien de plus.

## Ton

Français clair, concis, mais les noms et les verbes d'architecture viennent directement du skill `/codebase-design`. La concision n'excuse pas la dérive.

**Employer exactement :** module, interface, implémentation, profondeur, deep, shallow, seam, adaptateur, levier, localité.

**Ne jamais substituer :** composant, service, unité (pour module) · API, signature (pour interface) · boundary (pour seam) · couche, wrapper (pour module, quand on veut dire module).

**Des formulations qui collent au style :**

- « Le module d'admission des Commandes est shallow : son interface égale presque son implémentation. »
- « Le calcul de prix fuit à travers le seam. »
- « Approfondir : une interface, un seul endroit à tester. »
- « Deux adaptateurs justifient le seam : HTTP en production, en mémoire dans les tests. »

**Les puces de gains** nomment le bénéfice dans les termes du glossaire : _« localité : les bugs se concentrent dans un module »_, _« levier : une interface, N sites d'appel »_, _« l'interface rétrécit, l'implémentation absorbe les wrappers »_. Ne pas écrire _« plus facile à maintenir »_ ni _« du code plus propre »_ : ces termes ne sont pas dans le glossaire et ne gagnent pas leur place.

Pas de précautions oratoires, pas de raclements de gorge, pas de « il est à noter que… ». Si une phrase pourrait être une puce, en faire une puce. Si une puce peut sauter, la supprimer. Si un terme n'est pas dans le glossaire de `/codebase-design`, en chercher un qui y est avant d'en inventer un.
