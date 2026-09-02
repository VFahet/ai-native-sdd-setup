---
name: improve-codebase-architecture
description: Balaie une base de code à la recherche d'occasions d'approfondissement, les présente dans un rapport HTML visuel, puis grille celle que l'utilisateur retient.
disable-model-invocation: true
---

# Improve Codebase Architecture

Faire remonter les frictions architecturales et proposer des **occasions d'approfondissement** : des refactors qui transforment des modules shallow en modules deep. Le but est la testabilité et la navigabilité par une IA.

Cette commande est **informée** par le modèle de domaine du projet, et bâtie sur un vocabulaire de conception partagé :

- Appeler l'outil Skill avec « codebase-design » pour le vocabulaire d'architecture (**module**, **interface**, **profondeur**, **seam**, **adaptateur**, **levier**, **localité**) et ses principes (le test de suppression, « l'interface est la surface de test », « un seul adaptateur, c'est un seam hypothétique ; deux adaptateurs, c'est un vrai seam »). Employer ces termes exactement dans chaque suggestion, sans dériver vers « composant », « service », « API » ou « boundary ».
- La langue du domaine dans `CONTEXT.md` donne leurs noms aux bons seams ; les ADR de `docs/adr/` consignent des décisions que cette commande ne doit pas rejuger.

## Process

### 1. Explorer

**Cadrer avant de balayer : YAGNI.** Approfondir un module se rentabilise en rendant ses changements futurs plus faciles ; donner donc un poids supplémentaire aux parties du code qui ont récemment bougé. Décider *où* regarder avant de regarder :

- Si l'utilisateur a donné une direction (un module, un sous-système, un point de douleur), la prendre, et sauter l'inférence ci-dessous.
- Sinon, remonter une bonne tranche de l'historique (`git log --oneline`) pour trouver les **points chauds** de la base — les fichiers et les zones qui reviennent sans cesse — et laisser ces chemins attirer l'attention en premier. Si les changements sont dispersés sans point chaud net, élargir le filet.

Lire d'abord le glossaire de domaine du projet (`CONTEXT.md`) et les ADR de la zone que tu t'apprêtes à toucher.

Lancer ensuite un sous-agent pour parcourir le code. Ne pas suivre d'heuristiques rigides ; explorer organiquement et noter où la friction se fait sentir :

- Où comprendre un seul concept oblige-t-il à rebondir entre de nombreux petits modules ?
- Où les modules sont-ils **shallow**, avec une interface presque aussi complexe que l'implémentation ?
- Où des fonctions pures ont-elles été extraites pour la seule testabilité, alors que les vrais bugs se cachent dans la façon dont elles sont appelées (aucune **localité**) ?
- Où des modules fortement couplés fuient-ils à travers leurs seams ?
- Quelles parties du code ne sont pas testées, ou sont difficiles à tester à travers leur interface actuelle ?

Appliquer le **test de suppression** à tout ce que tu soupçonnes d'être shallow : supprimer ce module concentrerait-il la complexité, ou ne ferait-il que la déplacer ? Un « oui, elle se concentre » est le signal recherché.

### 2. Présenter les candidats dans un rapport HTML

Écrire un fichier HTML autoportant dans le répertoire temporaire du système, pour que rien n'atterrisse dans le dépôt. Résoudre le répertoire temporaire depuis `$TMPDIR`, en se rabattant sur `/tmp` (ou `%TEMP%` sous Windows), et écrire dans `<tmpdir>/architecture-review-<timestamp>.html`, pour que chaque exécution produise un fichier neuf. L'ouvrir pour l'utilisateur (`xdg-open <chemin>` sous Linux, `open <chemin>` sous macOS, `start <chemin>` sous Windows) et lui donner le chemin absolu.

Le rapport utilise **Tailwind via CDN** pour la mise en page et le style, et **Mermaid via CDN** pour les diagrammes là où un graphe, un flux ou une séquence communique la structure de façon fiable. Mélanger Mermaid et des visuels CSS/SVG faits à la main : Mermaid quand les relations ont une forme de graphe (graphes d'appel, dépendances, séquences), des `div`/SVG maison quand on veut quelque chose de plus éditorial (diagrammes de masse, coupes, effondrements). Chaque candidat reçoit une **visualisation avant/après**. Être visuel.

Pour chaque candidat, rendre une carte avec :

- **Fichiers** : quels fichiers ou modules sont concernés
- **Problème** : pourquoi l'architecture actuelle crée de la friction
- **Solution** : description en français clair de ce qui changerait
- **Gains** : expliqués en termes de localité et de levier, et de ce que les tests y gagnent
- **Diagramme avant / après** : côte à côte, dessiné sur mesure, illustrant la shallowness et l'approfondissement
- **Force de la recommandation** : `Ferme`, `À explorer` ou `Spéculatif`, rendue comme un badge

Terminer le rapport par une section **Recommandation principale** : quel candidat tu attaquerais en premier, et pourquoi.

**Employer le vocabulaire de `CONTEXT.md` pour le domaine, et celui de `/codebase-design` pour l'architecture.** Si `CONTEXT.md` définit « Commande », parler du « module d'admission des Commandes », pas du « FooBarHandler », et pas du « service Commande ».

**Conflits avec un ADR** : si un candidat contredit un ADR existant, ne le faire remonter que si la friction est assez réelle pour justifier de rouvrir l'ADR. Le marquer nettement dans la carte (un encadré d'avertissement, par exemple : _« contredit l'ADR-0007, mais mérite d'être rouvert parce que… »_). Ne pas lister tous les refactors théoriques qu'un ADR interdit.

Voir [HTML-REPORT.md](HTML-REPORT.md) pour la structure HTML complète, les motifs de diagramme et les consignes de style.

Ne PAS proposer d'interfaces à ce stade. Une fois le fichier écrit, demander à l'utilisateur : « Lequel veux-tu explorer ? »

### 3. Boucle de grilling

Une fois que l'utilisateur a choisi un candidat, appeler l'outil Skill avec « grilling » pour parcourir l'arbre de décision avec lui : contraintes, dépendances, forme du module approfondi, ce qui se tient derrière le seam, quels tests survivent.

Les effets de bord ont lieu au fil de l'eau, à mesure que les décisions se cristallisent ; appeler l'outil Skill avec « domain-modeling » pour tenir le modèle de domaine à jour en chemin :

- **Le module approfondi porte le nom d'un concept absent de `CONTEXT.md` ?** Ajouter le terme à `CONTEXT.md`. Créer le fichier paresseusement s'il n'existe pas.
- **Un terme flou s'affûte pendant la conversation ?** Mettre `CONTEXT.md` à jour sur-le-champ.
- **L'utilisateur rejette le candidat pour une raison porteuse ?** Proposer un ADR, formulé ainsi : _« Tu veux que je consigne ça comme un ADR, pour que les prochaines revues d'architecture ne le resuggèrent pas ? »_ Ne le proposer que si la raison serait réellement nécessaire à un futur explorateur pour éviter la même suggestion ; sauter les raisons éphémères (« ça n'en vaut pas la peine maintenant ») et les évidences.
- **Envie d'explorer des interfaces alternatives pour le module approfondi ?** Appeler l'outil Skill avec « codebase-design » et utiliser son motif de sous-agents parallèles décrit dans `DESIGN-IT-TWICE.md`.
