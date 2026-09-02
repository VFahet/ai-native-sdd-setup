---
name: which-skill
description: Demander quel skill ou quel enchaînement correspond à ta situation. Un routeur au-dessus des skills de ce dépôt.
disable-model-invocation: true
---

# Quel skill ?

Tu ne te souviens pas de tous les skills, alors demande.

Un **enchaînement** est un chemin à travers les skills. La plupart des chemins suivent un unique **enchaînement principal**, que deux **bretelles d'accès** rejoignent. Tout le reste est autonome, ou constitue une couche de vocabulaire qui tourne en dessous.

## L'enchaînement principal : idée → livraison

La route que suit la majorité du travail. Une phase de cadrage **séquentielle, une seule fois par projet**, puis une boucle par fonctionnalité.

### Cadrage, une fois

1. **`/discover`** mène le cadrage produit : huit branches — problème, acteurs, exigences fonctionnelles et non fonctionnelles, périmètre, métriques de succès, contraintes données, lot MVP. Aucune solution n'y est discutée. Sortie : `.scratch/discovery.md`, jetable.
2. **`/to-prd`** synthétise sans interviewer et écrit **`docs/prd.md`** : deux pages maximum, **gelé**, se terminant par la liste des **fonctionnalités** ordonnées en lots. Le lot 1 est le MVP — la plus petite combinaison qui fait bouger une métrique de succès — et c'est la seule partie que le gel couvre.

Le PRD n'est pas un document de communication : c'est l'**invariant qui rend l'itération falsifiable**. Sans point fixe, changer une spec et changer d'avis deviennent indiscernables.

Pas de projet à cadrer, juste une idée dans un dépôt existant ? Sauter directement à l'étape 3.

### Livraison, une boucle par fonctionnalité

3. **`/grill-with-docs`** affûte la fonctionnalité par interview. Son **premier tour** la cadre contre le PRD — quatre questions maximum : laquelle, quel comportement attendu, quelles limites, quelle contribution aux métriques — et en dérive le **slug**. Les **tours suivants** portent sur le *comment*. Il n'y a pas de cloison entre les deux : le basculement quoi → comment se fait à l'intérieur du même entretien. Sortie : ADR + `CONTEXT.md`, plus `.scratch/<feature-slug>/decisions.md`.

   (Pas de répertoire de travail ? Utiliser `/grill-me`, couvert sous Skills autonomes. Les deux font tourner la même primitive `/grilling` ; `grill-with-docs` est celui qui laisse une trace écrite, ce qui en fait le meilleur des deux dès qu'il y a un dépôt où la laisser.)

4. **Embranchement : peux-tu trancher toutes les questions en conversation ?** Si une question exige une réponse exécutable (un modèle d'état, de la logique métier, une UI qu'il faut voir), faire un détour par **`/prototype`**, avec **`/handoff`** comme pont dans les deux sens — un prototype vit dans son propre répertoire, ce qui est exactement le rôle de `/handoff` (voir Limites de phase).

5. **`/to-spec`** transforme l'entretien en spec et la publie dans le tracker avec le label `ready-for-agent`. Il n'interviewe pas : il lit `decisions.md`, relève dans `docs/prd.md` les **exigences non fonctionnelles qui contraignent cette fonctionnalité** avec leur chiffre, puis esquisse les **seams** de test et te les fait valider. Une seule spec, celle de cette fonctionnalité.

6. **`/to-tickets`** la découpe en tickets **tracer bullet** : des tranches *verticales* qui traversent toutes les couches étroitement mais complètement, chacune démontrable seule et dimensionnée pour une fenêtre de contexte neuve. Chaque ticket déclare ses **arêtes de blocage**, et c'est ici que naissent les critères d'acceptation. Sur un tracker local, cela donne un fichier par ticket sous `.scratch/<feature-slug>/issues/` ; sur un vrai tracker, les arêtes deviennent des liens de blocage natifs.

7. **`/implement`**, un ticket à la fois, **en faisant un `/clear` du contexte entre chacun**. Chaque ticket est autoportant, donc le contexte du précédent est jetable. Il pilote **`/tdd`** en interne (une tranche red-green à la fois, aux seams convenus), valide critère par critère avec une preuve nommable, puis clôt par **`/code-review`** — une revue du diff sur deux axes, Standards et Spec — avant de commiter.

Puis retour à l'étape 3 pour la fonctionnalité suivante.

Prendre **`/tdd`** seul quand tu veux simplement construire un comportement concret en commençant par les tests, sans spec complète, et **`/code-review`** seul dès que tu veux relire une branche ou une PR par rapport à un point fixe.

### Hygiène de contexte

Chaque skill lit ses entrées sur disque, donc chacun **tourne dans une fenêtre neuve**. Enchaîner les étapes 1 à 6 d'une traite reste préférable — le cadrage, la conception et le découpage raisonnent mieux sur une même réflexion continue — mais ce n'est pas une condition de survie des données.

La limite réelle, c'est la **smart zone** : la fenêtre (~150k tokens sur les modèles de pointe) à l'intérieur de laquelle le modèle raisonne encore finement. Si une session s'en approche, ne pas continuer en mode dégradé ; couper à la limite de phase la plus proche (voir Limites de phase).

## Bretelles d'accès

Une situation de départ qui génère du travail, puis rejoint l'enchaînement principal.

- **Quelque chose est cassé** → **`/diagnosing-bugs`**. Pour les cas durs : le bug qui résiste au premier coup d'œil, le test qui échoue par intermittence, la régression qui s'est glissée entre deux états connus comme bons. Il refuse de théoriser tant qu'il n'a pas une **boucle de rétroaction serrée** (une seule commande qui passe déjà au rouge sur *ce* bug), puis corrige avec un test de non-régression. Quand son post-mortem conclut qu'il n'existait pas de bon seam pour verrouiller le bug, ce qu'il produit est une idée de conception : l'emmener à `/grill-with-docs`, avec `/codebase-design` pour vocabulaire.

- **Un chantier énorme et brumeux : un projet greenfield ou une grosse fonctionnalité, trop gros pour une seule session** → **`/wayfinder`**, l'enchaînement le plus exigeant cognitivement d'ici. Quand le chemin d'ici jusqu'à la destination n'est pas encore visible, il trace une **carte partagée** de **tickets de décision** sur l'issue tracker et les résout un par un, en produisant des **décisions, pas des livrables**, jusqu'à ce que le brouillard recule.

  Là où `/grill-with-docs` affûte une fonctionnalité que tu peux tenir en une seule session, wayfinder est fait pour celle que tu ne peux pas. Le réserver exactement à ça : si tu peux nommer tes fonctionnalités en une ligne chacune et dire laquelle vient d'abord, tu n'en as pas besoin.

  Quand la carte s'éclaircit, **il passe la main, il ne construit pas** : rejoindre l'enchaînement principal à **`/to-spec`**, qui condense les décisions liées en un plan constructible, puis `/to-tickets` et `/implement` comme d'habitude. Reboucler la carte directement sur `/implement` saute cette condensation et jette le détail lié.

## Le vocabulaire en dessous

Deux références invoquées par le modèle qui tournent *en dessous* des autres skills, chacune étant la source de vérité unique de son vocabulaire. Les prendre directement quand ce sont les **mots**, et non le processus, qui posent problème ; ou laisser les skills ci-dessus les tirer à eux.

- **`/domain-modeling`** : affûter la langue du *domaine* du projet — remettre en cause un terme flou, démêler un mot surchargé (« compte » qui fait trois métiers), consigner sous forme d'ADR une décision difficilement réversible. C'est la discipline active que `/grill-with-docs` pilote pour garder `CONTEXT.md` comme un glossaire propre.
- **`/codebase-design`** : le vocabulaire des deep modules (module, interface, profondeur, seam, adaptateur, levier, localité) pour concevoir la *forme* d'un module — beaucoup de comportement derrière une petite interface, à un seam propre. `/to-spec` et `/tdd` le parlent tous les deux.

## Limites de phase

Une **phase** est un bloc de travail à l'intérieur d'une session : le grilling, l'implémentation, la QA. À la **limite** entre deux d'entre elles, tu as cinq options, et choisir entre elles est la décision la plus floue de toute cette carte :

- **Continuer** : rester sur place. Ne coûte rien, ne perd rien.
- **`/clear`** : vider la fenêtre, quand rien d'ici n'importe pour la suite.
- **`/handoff`** écrit un fichier markdown portable. Étroit : uniquement pour un **nouveau harness**, un **nouveau répertoire**, un **collègue**, ou pour forker une tâche annexe **en pleine phase**. Ce qu'il achète, c'est la portabilité.
- **Sous-agent** : envoyer une tâche étroitement cadrée dans sa propre fenêtre et récupérer un rapport.
- **`/compact`** compresse ce contexte et amorce une session neuve avec. Le **défaut**, en bas de l'arbre plutôt qu'en premier réflexe.

Lire [PHASE-BOUNDARIES.md](PHASE-BOUNDARIES.md) pour l'arbre ordonné : les cinq questions, le raisonnement derrière chaque branche, et pourquoi le coût en source primaire fait de **Continuer** l'option à écarter en premier. Prendre la décision **à** une limite ; en pleine phase, continuer ou découper le reste en sous-agents.

## Skills autonomes

Complètement en dehors de l'enchaînement principal.

- **`/grill-me`** : la même interview implacable que `/grill-with-docs`, mais **sans état** — elle n'enregistre rien en local et ne construit aucun `CONTEXT.md`. La prendre quand tu **ne travailles pas dans un répertoire de travail** (affûter un plan, une conception, un texte, tout ce qui n'a pas de dépôt en dessous). Si tu es dans un répertoire de travail, utiliser `/grill-with-docs` : il fait tourner la même interview et laisse une trace écrite, donc il est strictement meilleur.
- **`/grilling`** est la primitive d'interview elle-même : les tours, la frontière, les faits sont le travail de l'agent et les décisions sont les tiennes. `/discover`, `/grill-me` et `/grill-with-docs` sont ses portes d'entrée nommées, et `/wayfinder` la fait tourner en interne. Ne la prendre directement que si tu veux l'interview sans aucune enveloppe autour.
- **`/resolving-merge-conflicts`** traite un conflit de merge ou de rebase en cours, hunk par hunk, en résolvant par **intention** remontée jusqu'à la source primaire de chaque côté plutôt qu'en choisissant des lignes, puis termine l'opération. Il ne lance jamais `--abort`. Le prendre quand tu es déjà au milieu d'un conflit.
- **`/prototype`** est un petit programme jetable qui répond à une seule question de conception : ce modèle d'état est-il juste, ou à quoi cette UI devrait-elle ressembler. Jetable est une contrainte sur la façon dont le code est écrit, pas une promesse de le détruire : la réponse se replie dans le vrai code, et le prototype lui-même est conservé comme **source primaire** sur une branche `prototype/<name>` hors de main, pointée depuis l'issue d'implémentation. C'est le détour de l'étape 4 de l'enchaînement principal, mais le prendre chaque fois qu'une question de conception est difficile à trancher sur le papier.
- **`/research`** : déléguer le travail de lecture à un **agent en arrière-plan** — il enquête sur une question à partir de **sources primaires**, puis dépose dans le dépôt un fichier Markdown sourcé. Continuer à travailler pendant qu'il lit. Le fichier qu'il produit est quelque chose à emmener *dans* l'enchaînement principal, à `/discover` ou `/grill-with-docs` : la recherche alimente la réflexion plutôt qu'elle ne la remplace.
- **`/wait-what`** est le correctif pour un message qui n'est pas passé. L'utiliser en pleine conversation, à l'intérieur de n'importe quel autre skill, et l'agent re-pitche ce qu'il vient de dire avec le contexte qui te manquait, en langage clair, en utilisant le vocabulaire de `CONTEXT.md`. Il agit après coup ; `/grill-with-docs` est le remède en amont, parce qu'une langue commune décidée tôt est ce qui empêche le jargon d'arriver.
- **`/teach`** : apprendre un concept sur plusieurs sessions, en utilisant le répertoire courant comme espace de travail à état.
- **`/writing-for-agents`** est la référence pour rédiger les documents que des agents consomment : skills, `CLAUDE.md`, `AGENTS.md`, docs pointées.

## Prérequis

**`/setup-sdlc`** : à lancer avant ton premier enchaînement, pour configurer l'issue tracker et l'organisation des docs de domaine que les autres skills présupposent. Les issue trackers personnalisés fonctionnent aussi.
