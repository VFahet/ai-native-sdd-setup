# Docs de domaine

Comment les skills d'ingénierie doivent consommer la documentation de domaine de ce dépôt lorsqu'ils explorent le code.

## Avant d'explorer, lire ceci

- **`CONTEXT.md`** à la racine du dépôt, ou
- **`CONTEXT-MAP.md`** à la racine s'il existe : il pointe vers un `CONTEXT.md` par contexte. Lire chacun de ceux qui touchent au sujet.
- **`docs/adr/`** : lire les ADR qui concernent la zone où tu t'apprêtes à travailler. Dans les dépôts multi-contextes, regarder aussi `src/<contexte>/docs/adr/` pour les décisions propres à un contexte.

Si l'un de ces fichiers n'existe pas, **continuer sans rien dire**. Ne pas signaler son absence ; ne pas proposer de le créer d'emblée. Le skill `/domain-modeling` (atteint via `/grill-with-docs`) les crée paresseusement, quand un terme ou une décision est réellement tranché.

## Structure des fichiers

Dépôt mono-contexte (la plupart des dépôts) :

```
/
├── CONTEXT.md
├── docs/adr/
│   ├── 0001-commandes-event-sourcees.md
│   └── 0002-postgres-pour-le-modele-decriture.md
└── src/
```

Dépôt multi-contexte (présence d'un `CONTEXT-MAP.md` à la racine) :

```
/
├── CONTEXT-MAP.md
├── docs/adr/                          ← décisions à l'échelle du système
└── src/
    ├── commandes/
    │   ├── CONTEXT.md
    │   └── docs/adr/                  ← décisions propres au contexte
    └── facturation/
        ├── CONTEXT.md
        └── docs/adr/
```

## Utiliser le vocabulaire du glossaire

Quand ta sortie nomme un concept du domaine (dans un titre d'issue, une proposition de refactor, une hypothèse, un nom de test), utiliser le terme tel que défini dans `CONTEXT.md`. Ne pas dériver vers des synonymes que le glossaire écarte explicitement.

Si le concept dont tu as besoin n'est pas encore dans le glossaire, c'est un signal : soit tu inventes un vocabulaire que le projet n'emploie pas (à reconsidérer), soit il y a un vrai manque (à noter pour `/domain-modeling`).

## Signaler les conflits avec un ADR

Si ta sortie contredit un ADR existant, le dire explicitement plutôt que de passer outre en silence :

> _Contredit l'ADR-0007 (commandes event-sourcées), mais mérite d'être rouvert parce que…_
