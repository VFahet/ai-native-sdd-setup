# AI-native SDLC

Un environnement Claude Code qui structure le cycle de développement complet — cadrage, spec, découpage, exécution, revue — en skills réutilisables d'un projet à l'autre. **En français.**

L'idée : ne pas laisser l'agent improviser le processus. Chaque étape produit un artefact versionné que la suivante consomme. Le développement reste sous ton contrôle ; l'IA exécute à l'intérieur d'un cadre que tu as posé.

> Les skills sont en majeure partie tirés des [skills de Matt Pocock](https://github.com/mattpocock/skills) (MIT), traduits en français puis remaniés pour coller à mes besoins : couche produit ajoutée, chaîne recâblée, Claude Code uniquement.

## Installation

```bash
/plugin marketplace add VFahet/ai-native-sdlc-setup
/plugin install ai-native-sdlc
```

Puis, dans le dépôt où tu veux travailler :

```
/setup-sdlc
```

Cette commande configure une fois pour toutes où vivent les issues, les ADR et le glossaire du projet, et pose le workflow git : une branche par fonctionnalité, et des garde-fous qui refusent à l'agent de merger vers le trunk. Les autres skills en dépendent.

## La chaîne

Une phase de cadrage séquentielle, une fois. Puis des boucles, une par fonctionnalité.

```
─── cadrage, une fois ───────────────────────────────────────────
   /discover  ──▶  /to-prd  ──▶  docs/prd.md        [gelé]
                                      │
                                      │  décomposition en fonctionnalités
─── livraison, par fonctionnalité ────┼──────────────────────────
                                      ▼
   /grill-with-docs  ─▶  /to-spec  ─▶  /to-tickets  ─▶  /implement
                              │              │                │
                     spec.md ─┘              │                ├─▶ /tdd
                                             │                └─▶ /code-review
     .scratch/<feature-slug>/issues/NN-*.md ─┘
```

Le détail complet — diagrammes, artefacts, points de `/clear`, skills hors chaîne — est dans [FLUX.md](./FLUX.md).

Le PRD n'est pas un document de communication : c'est **l'invariant qui rend l'itération falsifiable**. Sans point fixe, changer une spec et changer d'avis deviennent indiscernables. Il est gelé par défaut et ne bouge que par révision datée.

Le partage entre PRD et spec ne se fait pas au zoom mais à l'axe : le PRD porte ce qui **contraint tout le projet** et reste vrai quelle que soit la solution ; la spec porte ce qui **décrit une seule fonctionnalité** et qu'un test peut vérifier.

## Les skills

### Product

Le cadrage amont, absent du dépôt d'origine.

| Skill | Rôle |
|---|---|
| **discover** | Cadrage produit initial, une fois par projet : problème, acteurs, exigences non fonctionnelles, périmètre, métriques, lot MVP |
| **to-prd** | Synthétise le cadrage en `docs/prd.md` : plafonné à deux pages, gelé, décomposé en fonctionnalités ordonnées en lots |

### Engineering

| Skill | Rôle |
|---|---|
| **setup-sdlc** | Configure le dépôt : tracker d'issues, docs de domaine, workflow git et garde-fous. À lancer une fois avant tout le reste |
| **which-skill** | Routeur : quel skill ou quel enchaînement correspond à ta situation |
| **research** | Enquête sur sources primaires et capture les résultats dans un fichier du dépôt |
| **wayfinder** | Cartographie un chantier trop gros pour une session, en tickets de décision résolus un à un |
| **prototype** | Construit un prototype jetable pour trancher une question de conception |
| **grill-with-docs** | L'interview de `grilling`, qui produit ADR et glossaire au passage. Premier tour : cadre la fonctionnalité contre le PRD, puis enchaîne sur la conception |
| **to-spec** | Transforme la conversation en spec technique : problème, user stories, décisions d'implémentation, hors-scope |
| **to-tickets** | Découpe une spec en tickets *tracer bullet*, chacun déclarant ce qui le bloque |
| **implement** | Exécute un ticket sur la branche de sa fonctionnalité : TDD aux seams convenus, typecheck, revue, commit — puis, au dernier ticket, revue de la fonctionnalité entière et PR |
| **tdd** | La boucle red-green-refactor, et ce qui fait un test qui mérite d'être gardé |
| **code-review** | Revue sur deux axes en parallèle : conformité aux standards du dépôt, et conformité à la spec d'origine |
| **diagnosing-bugs** | Boucle de diagnostic pour les bugs durs et les régressions de performance |
| **domain-modeling** | Construit et affine le modèle de domaine : `CONTEXT.md` et ADR |
| **codebase-design** | Vocabulaire partagé pour concevoir des *deep modules* : où placer un seam, comment approfondir une interface |
| **improve-codebase-architecture** | Balaie le code à la recherche de modules *shallow*, les présente dans un rapport HTML visuel, puis grille celui que tu retiens |
| **resolving-merge-conflicts** | Résout un merge ou un rebase en conflit, en préservant les deux intentions |
| **wizard** | Génère un script bash qui guide un humain à travers ce que lui seul peut faire : dashboards tiers, secrets de CI, bascules |

### Productivity

| Skill | Rôle |
|---|---|
| **grilling** | Met une idée, un plan ou une décision sous pression jusqu'à ce qu'elle tienne ou casse |
| **grill-me** | Le même, en interview dirigée |
| **handoff** | Compacte la session en document de passation pour l'agent suivant |
| **teach** | Enseigne un concept ou une compétence dans le contexte de ce workspace |
| **to-questionnaire** | Transforme une décision que tu ne peux pas trancher seul en questionnaire pour celui qui détient le contexte |
| **wait-what** | « Ce message n'est pas passé. Re-pitche. » |
| **writing-for-agents** | Écrire des documents pour des agents : skills, `CLAUDE.md`, `AGENTS.md` |
| **retro** | Rétrospective sur une session : ce qu'il faut changer dans l'environnement de l'agent pour que les suivantes coûtent moins |

Les skills conservés mais non traduits vivent dans [skills/backlog/](./skills/backlog/) et ne sont pas livrés dans le plugin.

## Conventions

Le corps des skills est en français, mais les `name:` restent en anglais — ce sont les commandes et les références croisées. Certains termes de l'art (`seam`, `tracer bullet`, `deep module`, `red-green-refactor`, `trunk`) ne sont pas traduits non plus : [CONTEXT.md](./CONTEXT.md) dit lesquels et pourquoi.

Les skills du plugin sont aussi exposés sous le préfixe `ai-native-sdlc:`, et le nom nu suffit tant que rien d'autre ne le revendique. Une exception, et une seule : `code-review` entre en collision avec la commande intégrée de Claude Code, donc un skill qui l'appelle passe `ai-native-sdlc:code-review` à l'outil Skill. La forme préfixée ne va pas plus loin : dans la prose, les tableaux et les schémas de ce dépôt, le nom s'écrit nu — `/code-review`.

## Licence

MIT. Œuvre dérivée de [mattpocock/skills](https://github.com/mattpocock/skills), © Matt Pocock.
