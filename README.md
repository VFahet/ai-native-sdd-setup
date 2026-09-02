# AI-native SDLC

Un environnement Claude Code qui structure le cycle de développement complet — cadrage, spec, découpage, exécution, revue — en skills réutilisables d'un projet à l'autre. **En français.**

L'idée : ne pas laisser l'agent improviser le processus. Chaque étape produit un artefact versionné que la suivante consomme. Le développement reste sous ton contrôle ; l'IA exécute à l'intérieur d'un cadre que tu as posé.

> Ce dépôt est une traduction française des [skills de Matt Pocock](https://github.com/mattpocock/skills) (MIT), adaptée à Claude Code. Voir [UPSTREAM.md](./UPSTREAM.md) pour ce qui a changé et comment se resynchroniser.

## Installation

```bash
/plugin marketplace add VFahet/ai-native-sdlc-setup
/plugin install ai-native-sdlc
```

Puis, dans le dépôt où tu veux travailler :

```
/setup-sdlc
```

Cette commande configure une fois pour toutes où vivent les issues, les ADR et le glossaire du projet. Les autres skills en dépendent.

## La chaîne

```
idée  ──/grilling──▶  cadrée
                          │
                    /to-spec        →  .scratch/<feature>/spec.md
                          │
                   /to-tickets      →  .scratch/<feature>/issues/NN-*.md
                          │
                   /implement  ──▶  /tdd  ──▶  /code-review
```

## Les skills

### Engineering

| Skill | Rôle |
|---|---|
| **setup-sdlc** | Configure le dépôt : tracker d'issues, docs de domaine. À lancer une fois avant tout le reste |
| **which-skill** | Routeur : quel skill ou quel enchaînement correspond à ta situation |
| **research** | Enquête sur sources primaires et capture les résultats dans un fichier du dépôt |
| **wayfinder** | Cartographie un chantier trop gros pour une session, en tickets de décision résolus un à un |
| **prototype** | Construit un prototype jetable pour trancher une question de conception |
| **grill-with-docs** | L'interview de `grilling`, qui produit ADR et glossaire au passage |
| **to-spec** | Transforme la conversation en spec technique : problème, user stories, décisions d'implémentation, hors-scope |
| **to-tickets** | Découpe une spec en tickets *tracer bullet*, chacun déclarant ce qui le bloque |
| **implement** | Exécute un ticket : TDD aux seams convenus, typecheck, revue, commit |
| **tdd** | La boucle red-green-refactor, et ce qui fait un test qui mérite d'être gardé |
| **code-review** | Revue sur deux axes en parallèle : conformité aux standards du dépôt, et conformité à la spec d'origine |
| **diagnosing-bugs** | Boucle de diagnostic pour les bugs durs et les régressions de performance |
| **domain-modeling** | Construit et affine le modèle de domaine : `CONTEXT.md` et ADR |
| **codebase-design** | Vocabulaire partagé pour concevoir des *deep modules* : où placer un seam, comment approfondir une interface |
| **resolving-merge-conflicts** | Résout un merge ou un rebase en conflit, en préservant les deux intentions |

### Productivity

| Skill | Rôle |
|---|---|
| **grilling** | Met une idée, un plan ou une décision sous pression jusqu'à ce qu'elle tienne ou casse |
| **grill-me** | Le même, en interview dirigée |
| **handoff** | Compacte la session en document de passation pour l'agent suivant |
| **teach** | Enseigne un concept ou une compétence dans le contexte de ce workspace |
| **wait-what** | « Ce message n'est pas passé. Re-pitche. » |
| **writing-for-agents** | Écrire des documents pour des agents : skills, `CLAUDE.md`, `AGENTS.md` |

Les skills conservés mais non traduits vivent dans [skills/backlog/](./skills/backlog/) et ne sont pas livrés dans le plugin.

## Conventions

Le corps des skills est en français, mais les `name:` restent en anglais — ce sont les commandes et les références croisées. Certains termes de l'art (`seam`, `tracer bullet`, `deep module`, `red-green-refactor`) ne sont pas traduits non plus : [CONTEXT.md](./CONTEXT.md) dit lesquels et pourquoi.

## Licence

MIT. Œuvre dérivée de [mattpocock/skills](https://github.com/mattpocock/skills), © Matt Pocock.
