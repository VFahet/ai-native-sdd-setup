# Approfondissement

Comment approfondir sans risque un cluster de modules shallow, compte tenu de ses dépendances. Suppose acquis le vocabulaire de [SKILL.md](SKILL.md) : **module**, **interface**, **seam**, **adaptateur**.

## Catégories de dépendances

Quand on évalue un candidat à l'approfondissement, classer ses dépendances. La catégorie détermine comment le module approfondi est testé à travers son seam.

### 1. Intra-processus

Calcul pur, état en mémoire, aucune E/S. Toujours approfondissable : fusionner les modules et tester directement à travers la nouvelle interface. Aucun adaptateur nécessaire.

### 2. Substituable en local

Dépendances qui disposent d'une doublure de test locale (PGLite pour Postgres, système de fichiers en mémoire). Approfondissable si la doublure existe. Le module approfondi est testé avec la doublure qui tourne dans la suite de tests. Le seam est interne ; pas de port à l'interface externe du module.

### 3. Distant mais qui t'appartient (Ports & Adapters)

Tes propres services de l'autre côté d'une frontière réseau (microservices, API internes). Définir un **port** (une interface) au seam. Le deep module détient la logique ; le transport est injecté sous forme d'**adaptateur**. Les tests utilisent un adaptateur en mémoire. La production utilise un adaptateur HTTP/gRPC/queue.

Forme de la recommandation : *« Définir un port au seam, implémenter un adaptateur HTTP pour la production et un adaptateur en mémoire pour les tests, pour que la logique tienne dans un seul deep module même si elle est déployée à travers un réseau. »*

### 4. Vraiment externe (Mock)

Services tiers (Stripe, Twilio, etc.) que tu ne contrôles pas. Le module approfondi prend la dépendance externe comme port injecté ; les tests fournissent un adaptateur mock.

## Discipline des seams

- **Un seul adaptateur, c'est un seam hypothétique. Deux adaptateurs, c'est un vrai seam.** N'introduire un port que si au moins deux adaptateurs se justifient (typiquement production + test). Un seam à un seul adaptateur n'est que de l'indirection.
- **Seams internes contre seams externes.** Un deep module peut avoir des seams internes (privés à son implémentation, utilisés par ses propres tests) aussi bien que le seam externe à son interface. Ne pas exposer les seams internes à travers l'interface juste parce que des tests s'en servent.

## Stratégie de test : remplacer, ne pas empiler

- Les anciens tests unitaires sur les modules shallow n'ont plus de valeur dès que des tests existent à l'interface du module approfondi ; les supprimer.
- Écrire de nouveaux tests à l'interface du module approfondi. L'**interface est la surface de test**.
- Les tests vérifient des résultats observables à travers l'interface, pas l'état interne.
- Les tests doivent survivre aux refactors internes, puisqu'ils décrivent un comportement, pas une implémentation. Si un test doit changer quand l'implémentation change, c'est qu'il teste au-delà de l'interface.
