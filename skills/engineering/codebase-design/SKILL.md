---
name: codebase-design
description: Vocabulaire partagé pour concevoir des deep modules. À utiliser quand l'utilisateur veut concevoir ou améliorer l'interface d'un module, repérer des modules à approfondir, décider où placer un seam, rendre le code plus testable ou plus navigable par une IA, ou quand un autre skill a besoin du vocabulaire des deep modules.
---

# Codebase Design

Concevoir des **deep modules** : beaucoup de comportement derrière une petite interface, posée à un seam net, testable à travers cette interface. Utiliser ce langage et ces principes partout où du code est conçu ou restructuré. Le but est le levier pour les appelants, la localité pour les mainteneurs, et la testabilité pour tout le monde.

## Glossaire

Utiliser ces termes exactement : ne pas leur substituer « composant », « service », « API » ou « boundary ». La cohérence du langage est tout l'enjeu.

**Module** : tout ce qui a une interface et une implémentation. Délibérément agnostique à l'échelle : une fonction, une classe, un paquet, ou une tranche qui traverse plusieurs étages. _À éviter_ : unité, composant, service.

**Interface** : tout ce qu'un appelant doit savoir pour utiliser correctement le module — la signature de type, mais aussi les invariants, les contraintes d'ordre, les modes d'erreur, la configuration requise et les caractéristiques de performance. _À éviter_ : API, signature (trop étroits, ils ne désignent que la surface au niveau des types).

**Implémentation** : ce qu'il y a à l'intérieur d'un module, son corps de code. À distinguer de l'**adaptateur** : une chose peut être un petit adaptateur avec une grosse implémentation (un repository Postgres) ou un gros adaptateur avec une petite implémentation (un fake en mémoire). Employer « adaptateur » quand le sujet est le seam ; « implémentation » sinon.

**Profondeur** : le levier à l'interface. La quantité de comportement qu'un appelant (ou un test) peut exercer par unité d'interface qu'il doit apprendre. Un module est **deep** quand beaucoup de comportement se trouve derrière une petite interface, **shallow** quand l'interface est presque aussi complexe que l'implémentation.

**Seam** _(Michael Feathers)_ : un endroit où l'on peut modifier le comportement sans éditer à cet endroit ; l'*emplacement* où vit l'interface d'un module. Où poser le seam est une décision de conception à part entière, distincte de ce que l'on met derrière. _À éviter_ : boundary (surchargé par le bounded context du DDD).

**Adaptateur** : une chose concrète qui satisfait une interface à un seam. Décrit un *rôle* (quel emplacement il occupe), pas une substance (ce qu'il y a dedans).

**Levier** : ce que les appelants retirent de la profondeur. Plus de capacité par unité d'interface apprise. Une seule implémentation est rentabilisée sur N sites d'appel et M tests.

**Localité** : ce que les mainteneurs retirent de la profondeur. Le changement, les bugs, la connaissance et la vérification se concentrent en un seul endroit au lieu de se disperser chez les appelants. Corrigé une fois, corrigé partout.

## Deep vs shallow

**Deep module** = petite interface + beaucoup d'implémentation :

```
┌─────────────────────────┐
│    Petite interface     │  ← Peu de méthodes, params simples
├─────────────────────────┤
│                         │
│ Implémentation profonde │  ← Logique complexe cachée
│                         │
└─────────────────────────┘
```

**Shallow module** = grande interface + peu d'implémentation (à éviter) :

```
┌─────────────────────────────────┐
│        Grande interface         │  ← Beaucoup de méthodes, params complexes
├─────────────────────────────────┤
│  Implémentation fine            │  ← Ne fait que transmettre
└─────────────────────────────────┘
```

En concevant une interface, se demander :

- Puis-je réduire le nombre de méthodes ?
- Puis-je simplifier les paramètres ?
- Puis-je cacher davantage de complexité à l'intérieur ?

## Principes

- **La profondeur est une propriété de l'interface, pas de l'implémentation.** Un deep module peut être composé en interne de petites parties mockables et interchangeables ; elles ne font simplement pas partie de l'interface. Un module peut avoir des **seams internes** (privés à son implémentation, utilisés par ses propres tests) aussi bien que le **seam externe** à son interface.
- **Le test de suppression.** Imaginer que l'on supprime le module. Si la complexité disparaît, c'était un passe-plat. Si la complexité réapparaît chez N appelants, il justifiait sa place.
- **L'interface est la surface de test.** Les appelants et les tests traversent le même seam. Si tu veux tester *au-delà* de l'interface, c'est probablement que le module n'a pas la bonne forme.
- **Un seul adaptateur, c'est un seam hypothétique. Deux adaptateurs, c'est un vrai seam.** N'introduire un seam que si quelque chose varie réellement de part et d'autre.

## Concevoir pour la testabilité

Les bonnes interfaces rendent le test naturel :

1. **Accepter les dépendances, ne pas les créer.**

   ```typescript
   // Testable
   function processOrder(order, paymentGateway) {}

   // Difficile à tester
   function processOrder(order) {
     const gateway = new StripeGateway();
   }
   ```

2. **Retourner des résultats, ne pas produire d'effets de bord.**

   ```typescript
   // Testable
   function calculateDiscount(cart): Discount {}

   // Difficile à tester
   function applyDiscount(cart): void {
     cart.total -= discount;
   }
   ```

3. **Petite surface.** Moins de méthodes = moins de tests nécessaires. Moins de params = mise en place de test plus simple.

## Relations

- Un **Module** a exactement une **Interface** (la surface qu'il présente aux appelants et aux tests).
- La **Profondeur** est une propriété d'un **Module**, mesurée à l'aune de son **Interface**.
- Un **Seam** est l'endroit où vit l'**Interface** d'un **Module**.
- Un **Adaptateur** se place à un **Seam** et satisfait l'**Interface**.
- La **Profondeur** produit du **Levier** pour les appelants et de la **Localité** pour les mainteneurs.

## Cadrages rejetés

- **La profondeur comme rapport entre lignes d'implémentation et lignes d'interface** (Ousterhout) : récompense le gonflage de l'implémentation. On utilise plutôt la profondeur-comme-levier.
- **L'« interface » au sens du mot-clé TypeScript `interface` ou des méthodes publiques d'une classe** : trop étroit — l'interface inclut ici tout fait qu'un appelant doit connaître.
- **« Boundary »** : surchargé par le bounded context du DDD. Dire **seam** ou **interface**.

## Aller plus loin

- **Approfondir un cluster compte tenu de ses dépendances**, voir [DEEPENING.md](DEEPENING.md) : catégories de dépendances, discipline des seams, et tests qui remplacent au lieu d'empiler.
- **Explorer des interfaces alternatives**, voir [DESIGN-IT-TWICE.md](DESIGN-IT-TWICE.md) : lancer des sous-agents en parallèle pour concevoir l'interface de plusieurs façons radicalement différentes, puis les comparer sur la profondeur, la localité et le placement du seam.
