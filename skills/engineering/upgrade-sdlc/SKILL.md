---
name: upgrade-sdlc
description: "Constate ce qui manque à un dépôt déjà configuré depuis que le plugin a changé — fichiers de configuration absents, conventions périmées — et applique seulement ce qui manque, jamais la configuration entière. À utiliser après une mise à jour du plugin, ou quand un skill se plaint d'un fichier qui devrait exister."
disable-model-invocation: true
---

`/setup-sdlc` configure un dépôt une fois. Le plugin, lui, continue de bouger : une section s'ajoute, une convention change. Un dépôt configuré il y a un mois tourne alors sur un état que la chaîne ne sait plus tout à fait lire — sans que rien ne le signale.

Ce skill constate l'écart et ne comble **que** l'écart.

**Il ne rejoue jamais `/setup-sdlc`.** Il n'écrit que ce qui est absent. Un `docs/agents/*.md` déjà présent n'est jamais réécrit — l'utilisateur l'a peut-être édité à la main, et c'est même ce que `/setup-sdlc` lui dit de faire à la fin. Toucher à un fichier existant demande son accord explicite, fichier par fichier.

## Frontière avec `/analyze`

`/analyze` confronte les artefacts **d'une fonctionnalité** les uns aux autres : PRD, spec, tickets. Ce skill confronte l'**installation du dépôt** au plugin courant.

Aucun recouvrement : l'un ne regarde jamais un ticket, l'autre ne regarde jamais un fichier de configuration.

## Comment il sait ce qui a changé

**Par constat sur le dépôt, jamais par numéro de version.** Un dépôt configuré avant qu'un stamp de version existe n'en porte aucun, et c'est précisément le cas que ce skill doit traiter. Chaque migration porte donc sa propre détection, vraie sur un dépôt neuf comme sur un dépôt ancien.

Le registre est [MIGRATIONS.md](./MIGRATIONS.md), à côté de ce fichier.

## Process

### 1. Constater l'état du dépôt

Vérifier d'abord que le dépôt a bien été configuré : `docs/agents/issue-tracker.md` présent. **S'il est absent, s'arrêter** — le dépôt n'a jamais vu `/setup-sdlc`, et c'est lui qu'il faut lancer, pas ce skill. Le dire et s'arrêter là.

Relever ensuite, sans rien écrire :

- quels `docs/agents/*.md` existent — `issue-tracker.md`, `domain.md`, `git-workflow.md`, `triage-labels.md`, `coding-standards.md` ;
- quel tracker est configuré, lu dans `docs/agents/issue-tracker.md` ;
- si `.claude/hooks/` porte les garde-fous ;
- les fonctionnalités connues : les répertoires de `.scratch/`, les fichiers de `docs/specs/`, les issues de spec du tracker.

### 2. Dérouler le registre

Lire [MIGRATIONS.md](./MIGRATIONS.md) en entier et appliquer la **détection** de chaque entrée à l'état relevé. Une entrée dont la détection est fausse est déjà appliquée : ne pas la mentionner, sauf si l'utilisateur a demandé le détail.

Consulter `docs/agents/upgrades-refuses.md` s'il existe : les identifiants qui y figurent ont été refusés lors d'un passage précédent. **Les détecter quand même** — l'état a pu changer — mais les présenter séparément, comme un rappel, jamais comme une proposition neuve. Une migration qu'on redemande à chaque lancement finit par être appliquée par lassitude, ce qui n'est pas un accord.

Traiter aussi la section **Dérives tolérées** du registre : si l'une se constate, la nommer dans le rapport comme telle et **ne rien proposer**. Elle est là pour que l'utilisateur ne la confonde pas avec un oubli.

### 3. Rapporter avant d'écrire

Un rapport, puis rien. Par migration à appliquer :

- son identifiant et son titre ;
- **ce qui a été constaté** sur ce dépôt, précisément — quel fichier manque, quelle issue porte encore un corps de spec ;
- **ce qui casse si on ne l'applique pas**, repris du champ *Coût de refus* du registre ;
- **les gestes exacts** que l'application effectuerait, y compris les suppressions.

Une migration dont le coût de refus est nul doit être présentée comme telle. Ne pas pousser à appliquer ce qui ne casse rien.

Terminer par la question, une seule fois : lesquelles appliquer. **Ne rien écrire avant la réponse.**

### 4. Appliquer, une par une

Dans l'ordre du registre, et en s'arrêtant à la première qui échoue plutôt qu'en poursuivant sur un état à moitié migré.

Pour chacune : suivre la **remédiation** du registre, puis dire ce qui a réellement été écrit ou supprimé. Ne jamais annoncer une migration comme appliquée sans avoir constaté son effet — une détection qui redevient fausse est la preuve, pas l'intention d'écrire.

Ce qui touche à un fichier existant se redemande au moment de le faire, avec son contenu actuel sous les yeux. Un accord global à l'étape 3 ne vaut pas accord pour écraser un fichier que l'utilisateur a édité.

### 5. Consigner les refus

Pour chaque migration refusée, écrire ou compléter `docs/agents/upgrades-refuses.md` :

```markdown
# Migrations refusées

Les migrations du plugin que ce dépôt a délibérément écartées. `/upgrade-sdlc` les rappelle sans les reproposer.

- **M002** — refusée le <AAAA-MM-JJ>. <la raison donnée par l'utilisateur.>
```

Sans raison donnée, la demander en une phrase. Un refus sans motif se relit dans six mois comme un oubli, et quelqu'un le rattrape.

Ne rien écrire dans ce fichier pour une migration simplement reportée : « pas maintenant » n'est pas un refus.

## Ensuite

Migrations appliquées : dire lesquelles, et lesquelles restent refusées ou en attente.

Si **M001** a été appliquée, la chaîne a désormais des specs à `docs/specs/`. Proposer `/analyze <feature-slug>` sur la fonctionnalité migrée : c'est le contrôle qui dira si les tickets déjà publiés correspondent encore à la spec qu'on vient de déplacer.
