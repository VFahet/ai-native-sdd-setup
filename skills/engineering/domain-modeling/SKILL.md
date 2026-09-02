---
name: domain-modeling
description: Construire et affûter le modèle de domaine d'un projet. À utiliser quand on discute du vocabulaire ou du glossaire du code, qu'on écrit ou modifie un CONTEXT.md, ou qu'on consigne ou modifie un ADR.
---

# Domain Modeling

Construire et affûter activement le modèle de domaine du projet au fil de la conception. C'est la discipline *active* : contester les termes, inventer des scénarios limites, et écrire le glossaire et les décisions à l'instant même où ils se cristallisent. (Se contenter de *lire* `CONTEXT.md` pour son vocabulaire n'est pas ce skill : c'est une habitude d'une ligne que n'importe quel skill peut prendre. Ce skill sert quand tu modifies le modèle, pas quand tu te contentes de le consommer.)

## Structure des fichiers

La plupart des dépôts n'ont qu'un seul contexte :

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-commandes-event-sourcees.md
│       └── 0002-postgres-pour-le-modele-decriture.md
└── src/
```

Si un `CONTEXT-MAP.md` existe à la racine, le dépôt a plusieurs contextes. La carte indique où vit chacun d'eux :

```
/
├── CONTEXT-MAP.md
├── docs/
│   └── adr/                          ← décisions à l'échelle du système
├── src/
│   ├── commandes/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/                 ← décisions propres au contexte
│   └── facturation/
│       ├── CONTEXT.md
│       └── docs/adr/
```

Créer les fichiers paresseusement : seulement quand tu as quelque chose à écrire. S'il n'existe pas de `CONTEXT.md`, en créer un quand le premier terme est tranché. S'il n'existe pas de `docs/adr/`, le créer quand le premier ADR est nécessaire.

## Pendant la session

### Confronter au glossaire

Quand l'utilisateur emploie un terme qui entre en conflit avec le vocabulaire déjà posé dans `CONTEXT.md`, le signaler immédiatement. « Ton glossaire définit “annulation” comme X, mais tu sembles vouloir dire Y. Laquelle des deux ? »

### Affûter le vocabulaire flou

Quand l'utilisateur emploie des termes vagues ou surchargés, proposer un terme canonique précis. « Tu dis “compte” : parles-tu du Client ou de l'Utilisateur ? Ce sont deux choses différentes. »

### Discuter des scénarios concrets

Quand les relations du domaine sont en discussion, les mettre à l'épreuve avec des scénarios précis. Inventer des scénarios qui sondent les cas limites et forcent l'utilisateur à être précis sur les frontières entre les concepts.

### Recouper avec le code

Quand l'utilisateur affirme comment quelque chose fonctionne, vérifier si le code lui donne raison. Si tu trouves une contradiction, la faire remonter : « Ton code annule des Commandes entières, mais tu viens de dire que l'annulation partielle est possible. Qu'est-ce qui est juste ? »

### Mettre à jour CONTEXT.md au fil de l'eau

Quand un terme est tranché, mettre à jour `CONTEXT.md` sur-le-champ. Ne pas accumuler les mises à jour : les capturer à mesure qu'elles surviennent. Utiliser le format décrit dans [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

`CONTEXT.md` doit être totalement dépourvu de détails d'implémentation. Ne pas traiter `CONTEXT.md` comme une spec, un brouillon, ou un réceptacle à décisions d'implémentation. C'est un glossaire, rien d'autre.

### Proposer des ADR avec parcimonie

Ne proposer de créer un ADR que si les trois conditions sont vraies :

1. **Difficilement réversible** : le coût d'un changement d'avis plus tard est réel
2. **Surprenant sans le contexte** : un lecteur futur se demandera « pourquoi ont-ils fait comme ça ? »
3. **Le fruit d'un vrai arbitrage** : il existait de véritables alternatives et tu en as choisi une pour des raisons précises

Si l'une des trois manque, passer l'ADR. Utiliser le format décrit dans [ADR-FORMAT.md](./ADR-FORMAT.md).
