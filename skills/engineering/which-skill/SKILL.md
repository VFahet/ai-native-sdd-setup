---
name: which-skill
description: Demander quel skill ou quel enchaînement correspond à ta situation. Un routeur au-dessus des skills de ce dépôt.
disable-model-invocation: true
---

# Quel skill ?

Tu ne te souviens pas de tous les skills, alors demande.

Un **enchaînement** est un chemin à travers les skills. La plupart des chemins suivent un unique **enchaînement principal**, que deux **bretelles d'accès** rejoignent. Tout le reste est autonome, ou constitue une couche de vocabulaire qui tourne en dessous.

## L'enchaînement principal : idée → livraison

La route que suit la majorité du travail. Tu as une idée et tu veux la voir construite.

1. **`/grill-with-docs`** affûte l'idée par interview. Commencer ici dès que tu **travailles dans un répertoire de travail** : il conserve un état, retenant ce qu'il apprend dans `CONTEXT.md` et dans des ADR. (Pas de répertoire de travail ? Utiliser `/grill-me` à la place, couvert sous Skills autonomes. Les deux font tourner la même primitive `/grilling` ; `grill-with-docs` est celui qui laisse une trace écrite, ce qui en fait le meilleur des deux dès qu'il y a un dépôt où la laisser.)
2. **Embranchement : peux-tu trancher toutes les questions en conversation ?** Si une question exige une réponse exécutable (un état, de la logique métier, une UI qu'il faut voir), faire un détour par un prototype, avec **`/handoff`** comme pont dans les deux sens (un prototype vit dans son propre répertoire, ce qui est exactement le rôle de `/handoff` ; voir Limites de phase) :
   - **`/handoff`** vers l'extérieur, puis ouvrir une session neuve sur ce fichier,
   - **`/prototype`** pour répondre à la question avec du code jetable,
   - **`/handoff`** en retour de ce que tu as appris, et le référencer depuis le fil de l'idée d'origine.
3. **Embranchement : est-ce un chantier sur plusieurs sessions ?**
   - **Oui** → **`/to-spec`** (transformer le fil en spec), puis **`/to-tickets`** pour la découper en tickets tracer bullet, chacun déclarant ses **arêtes de blocage**. Sur un tracker local, cela donne un fichier par ticket sous `.scratch/<feature>/issues/`, traités bloqueurs d'abord, à la main ; sur un vrai tracker, les arêtes deviennent des liens de blocage natifs, si bien que tout ticket dont les bloqueurs sont terminés peut être pris : lancer **`/implement`** par ticket, **en faisant un `/clear` du contexte entre chacun**. Chaque ticket est autoportant, donc le contexte du précédent est jetable.
   - **Non** → **`/implement`** directement ici, dans la même fenêtre de contexte.

   Dans les deux cas, **`/implement`** construit chaque issue en pilotant **`/tdd`** en interne (une tranche red-green à la fois), puis clôt en lançant **`/code-review`**, une revue du diff sur deux axes (Standards + Spec), avant de commiter. Prendre **`/tdd`** seul quand tu veux simplement construire un comportement concret en commençant par les tests, sans spec complète, et **`/code-review`** seul dès que tu veux relire une branche ou une PR par rapport à un point fixe.

### Hygiène de contexte

Garder les étapes 1 à 3 dans **une seule fenêtre de contexte ininterrompue** (ne pas compacter ni clear avant d'avoir passé `/to-tickets`) pour que le grilling, la spec et les tickets s'appuient tous sur la même réflexion. Chaque `/implement` repart ensuite de zéro, en travaillant à partir du ticket.

La limite à cela, c'est la **[smart zone](https://www.aihero.dev/ai-coding-dictionary/smart-zone)** : la fenêtre (~150k tokens sur les modèles de pointe) à l'intérieur de laquelle le modèle raisonne encore finement. Si une session s'en approche avant `/to-tickets`, ne pas continuer en mode dégradé ; faire un `/compact` à la limite de phase la plus proche et poursuivre (voir Limites de phase).

## Bretelles d'accès

Une situation de départ qui génère du travail, puis rejoint l'enchaînement principal.

- **Des bugs et des demandes qui s'accumulent** → **`/triage`**. Il fait passer les issues par les rôles de triage et produit des issues prêtes pour un agent, que **`/implement`** reprend ensuite.

  Le triage ne concerne que les issues **que tu n'as pas créées** : rapports de bug, demandes de fonctionnalité entrantes, tout ce qui arrive brut. Les tickets produits par `/to-tickets` sont déjà prêts pour un agent, donc **ne pas les trier**.

- **Quelque chose est cassé** → **`/diagnosing-bugs`**. Pour les cas durs : le bug qui résiste au premier coup d'œil, le test qui échoue par intermittence, la régression qui s'est glissée entre deux états de référence. Il refuse de théoriser tant qu'il n'a pas une **boucle de rétroaction serrée** (une seule commande qui passe déjà au rouge sur *ce* bug), puis corrige avec un test de non-régression. Son post-mortem passe la main à **`/improve-codebase-architecture`** quand le vrai constat est qu'il n'existe pas de bon seam pour verrouiller le bug.

- **Un chantier énorme et brumeux : un projet greenfield ou la construction d'une grosse fonctionnalité, trop gros pour une seule session** → **`/wayfinder`**, l'enchaînement le plus exigeant cognitivement d'ici. Quand le chemin d'ici jusqu'à la destination n'est pas encore visible, il trace une **carte partagée** de **tickets de décision** sur l'issue tracker et les résout un par un, en produisant des **décisions, pas des livrables**, jusqu'à ce que le brouillard recule et que la voie soit dégagée. Là où **`/grill-with-docs`** affûte une idée que tu peux tenir en une seule session, wayfinder est fait pour celle que tu ne peux pas, et il est plus lent et plus dense : le réserver exactement à ça, jamais à une fonctionnalité bien cadrée.

  Quand la carte s'éclaircit, **il passe la main, il ne construit pas** : rejoindre l'enchaînement principal à **`/to-spec`**, qui condense les décisions liées de la carte en un plan constructible, puis `/to-tickets` et `/implement` comme d'habitude. Reboucler la carte directement sur `/implement` saute cette condensation et jette le détail lié : n'aller directement à `/implement` que si le chantier s'est révélé vraiment petit.

## Santé de la base de code

Pas du travail de fonctionnalité, juste de l'entretien.

- **`/improve-codebase-architecture`** tourne dès que tu as un moment de libre, pour garder la base de code agréable à opérer pour des agents. Il fait remonter des **opportunités d'approfondissement** ; en choisir une _génère une idée_ que tu peux emmener dans l'enchaînement principal à `/grill-with-docs`. C'est le relevé de terrain qui trouve les candidates ; **`/codebase-design`** (ci-dessous) est l'établi sur lequel tu conçois celle que tu as retenue.

## Le vocabulaire en dessous

Deux références invoquées par le modèle qui tournent *en dessous* des autres skills, chacune étant la source de vérité unique de son vocabulaire. Les prendre directement quand ce sont les **mots**, et non le processus, qui posent problème ; ou laisser les skills ci-dessus les tirer à eux.

- **`/domain-modeling`** : affûter la langue du *domaine* du projet — remettre en cause un terme flou, démêler un mot surchargé (« compte » qui fait trois métiers), consigner sous forme d'ADR une décision difficilement réversible. C'est la discipline active que `/grill-with-docs` pilote pour garder `CONTEXT.md` comme un glossaire propre.
- **`/codebase-design`** est le vocabulaire des deep modules (module, interface, profondeur, seam, adaptateur, levier, localité) pour concevoir la *forme* d'un module : beaucoup de comportement derrière une petite interface, à un seam propre. `/tdd` et `/improve-codebase-architecture` le parlent tous les deux.

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

- **`/grill-me`** : la même interview sans relâche que `/grill-with-docs`, mais **sans état** : elle n'enregistre rien en local et ne construit aucun `CONTEXT.md`. La prendre quand tu **ne travailles pas dans un répertoire de travail** (affûter un plan, une conception, un texte, tout ce qui n'a pas de dépôt en dessous). Si tu es dans un répertoire de travail, utiliser `/grill-with-docs` à la place : il fait tourner la même interview et laisse une trace écrite, donc il est strictement meilleur.
- **`/grilling`** est la primitive d'interview elle-même : les tours, la frontière, les faits sont le travail de l'agent et les décisions sont les tiennes. `/grill-me` et `/grill-with-docs` sont les deux portes d'entrée nommées, et `/triage`, `/wayfinder` et `/improve-codebase-architecture` la font tous tourner en interne. Ne la prendre directement que si tu veux l'interview sans aucune enveloppe autour.
- **`/resolving-merge-conflicts`** traite un conflit de merge ou de rebase en cours, hunk par hunk, en résolvant par **intention** remontée jusqu'à la source primaire de chaque côté plutôt qu'en choisissant des lignes, puis termine l'opération. Il ne lance jamais `--abort`. Autonome et en dehors de tous les enchaînements : le prendre quand tu es déjà au milieu d'un conflit.
- **`/prototype`** est un petit programme jetable qui répond à une seule question de conception : ce modèle d'état est-il juste, ou à quoi cette UI devrait-elle ressembler. Jetable est une contrainte sur la façon dont le code est écrit, pas une promesse de le détruire : la réponse se replie dans le vrai code, et le prototype lui-même est conservé comme **source primaire** sur une branche `prototype/<name>` hors de main, pointée depuis l'issue d'implémentation. C'est le détour de l'étape 2 de l'enchaînement principal, mais le prendre chaque fois qu'une question de conception est difficile à trancher sur le papier.
- **`/research`** : déléguer le travail de lecture à un **agent en arrière-plan** — il enquête sur une question à partir de **sources primaires**, puis dépose dans le dépôt un fichier Markdown sourcé. Continuer à travailler pendant qu'il lit. Le fichier qu'il produit est quelque chose à emmener *dans* l'enchaînement principal à `/grill-with-docs`, puisque la recherche alimente la réflexion plutôt qu'elle ne la remplace.
- **`/to-questionnaire`** intervient quand ce qui te bloque n'est ni dans ta tête ni dans la base de code mais dans **celle de quelqu'un d'autre**, et il lui écrit un questionnaire à remplir. C'est l'inverse de `/grill-me` : au lieu de t'interviewer sur le sujet, il t'interviewe sur l'**envoi** (à qui il part, ce dont tu as besoin en retour) et braque les questions sur le manque. Ce qui revient est de la matière pour `/grill-with-docs` ou `/to-spec`.
- **`/wizard`** est fait pour les étapes que seul un **humain** peut franchir : provisionner de l'infrastructure, mettre en place des identifiants ou des secrets de CI, cliquer dans un dashboard tiers inconnu, lancer une migration ou une bascule ponctuelle. Il génère un script bash interactif qui ouvre chaque URL, capture chaque valeur et l'écrit dans `.env` et dans les secrets GitHub, pour que la procédure cesse d'être quelque chose que tu réexpliques à un agent à chaque fois. Invoqué par le modèle, donc l'agent le prend dès qu'il tombe sur un mur que toi seul peux passer. Si l'agent pouvait simplement le faire lui-même, il devrait ; ceci est pour les cas où un humain est réellement dans la boucle.
- **`/wait-what`** est le correctif pour un message qui n'est pas passé. L'utiliser en pleine conversation, à l'intérieur de n'importe quel autre skill, et l'agent re-pitche ce qu'il vient de dire avec le contexte qui te manquait, en langage clair, en utilisant le vocabulaire de `CONTEXT.md`. Il agit après coup ; `/grill-with-docs` est le remède en amont, parce qu'une langue commune décidée tôt est ce qui empêche le jargon d'arriver.
- **`/teach`** : apprendre un concept sur plusieurs sessions, en utilisant le répertoire courant comme espace de travail à état.
- **`/writing-for-agents`** est la référence pour rédiger les documents que des agents consomment : skills, AGENTS.md, docs pointées.

## Prérequis

**`/setup-sdlc`** : à lancer avant ton premier enchaînement d'ingénierie, pour configurer l'issue tracker, les labels de triage et l'organisation des docs que les autres skills présupposent. Les issue trackers personnalisés fonctionnent aussi.
