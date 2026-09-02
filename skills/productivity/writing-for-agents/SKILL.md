---
name: writing-for-agents
description: Écrire des documents pour des agents. À utiliser pour créer ou modifier un skill, ou pour modifier AGENTS.md ou CLAUDE.md.
---

Référence pour écrire tout document consommé par un agent : un skill, un `AGENTS.md` / `CLAUDE.md`, un doc atteint par un pointeur. L'emballage diffère ; l'écriture, non : les mêmes leviers rendent chacun prévisible, puisque l'agent suit le même _processus_ à chaque exécution plutôt que de produire la même sortie.

Quand le document que tu écris est un skill, lis [`SKILL-MECHANICS.md`](SKILL-MECHANICS.md) pour le frontmatter, le choix d'invocation et les skills routeurs.

## Pointeurs de contexte

Un **pointeur de contexte** est une référence tenue dans le contexte de l'agent, qui nomme un matériau hors contexte et encode la condition pour l'atteindre. La description d'un skill en est un ; une ligne d'`AGENTS.md` qui nomme un doc est le même objet. C'est la _formulation_ du pointeur, non sa cible, qui décide quand l'agent atteint le matériau, et avec quelle fiabilité. Une cible indispensable derrière un pointeur mal formulé est un bug de variance : affûte d'abord la formulation, et n'intègre le matériau au fichier que si l'affûtage échoue.

Un pointeur fait deux choses : dire ce qu'est le matériau, et lister les **branches** qui doivent déclencher l'accès au matériau (une branche est un cas distinct que le document traite, si bien que des exécutions différentes le traversent par des chemins différents). Chaque mot d'un pointeur toujours chargé coûte à chaque tour, ce qui lui vaut un élagage encore plus dur que le corps :

- **Place le mot directeur en tête** : c'est dans le pointeur qu'il fait son travail de déclenchement.
- **Un déclencheur par branche.** Des synonymes qui renomment une seule branche, c'est une branche écrite deux fois ; fusionne-les et ne garde que les branches réellement distinctes.
- **Coupe l'identité que le corps porte déjà.**

## Les deux charges

Chaque document et chaque pointeur que tu ajoutes dépense l'un de deux budgets :

- La **charge de contexte** est le coût du matériau toujours chargé sur la fenêtre de l'agent : une ligne d'`AGENTS.md`, la description d'un skill, tout ce qui siège dans le contexte à chaque tour, dépensant des tokens et de l'attention qu'il se déclenche ou non.
- La **charge cognitive** est le coût sur l'humain : quels documents existent et quand recourir à chacun. L'humain est l'index. Pas un coût à minimiser : c'est le prix de l'agentivité humaine ; dépense-la là où le jugement humain compte, retire-la là où il ne compte pas.

Un matériau qu'on n'atteint que par un pointeur échappe à la charge de contexte au prix de la ligne du pointeur lui-même ; un matériau sans aucun pointeur repose entièrement sur la charge cognitive.

## Hiérarchie de l'information

Un document est bâti à partir de deux types de contenu : les **étapes** (les actions ordonnées que l'agent exécute) et la **référence** (définitions, règles, faits consultés à la demande). Les deux se mélangent librement : que des étapes (une recette), que de la référence (les règles d'une revue, ce skill), ou les deux. La décision centrale est de savoir où chaque morceau se place dans la **hiérarchie de l'information**, une échelle classée selon l'immédiateté avec laquelle l'agent a besoin du matériau :

1. L'**étape dans le fichier** est l'échelon primaire : ce que l'agent fait, dans l'ordre.
2. La **référence dans le fichier** se consulte à la demande. Souvent un ensemble de pairs légitimement plat (toutes les règles d'une revue sur un même barreau), ce qui est un bon arrangement, pas un smell.
3. La **référence divulguée** est poussée dans un fichier séparé, atteinte par un pointeur de contexte, chargée seulement quand le pointeur se déclenche. Cela va du fichier voisin dans le même dossier jusqu'à la référence pleinement externe, qui vit n'importe où et que n'importe quel document peut pointer.

Pousse trop peu vers le bas et le sommet enfle ; pousse trop et tu caches du matériau dont l'agent a réellement besoin. Toute la décision tient dans cette tension.

La **divulgation progressive** est le mouvement vers le bas de l'échelle (hors du fichier principal et derrière un pointeur) pour que le sommet reste lisible. Ce n'est pas d'abord une optimisation de tokens : c'est ainsi qu'on protège la hiérarchie. Le branchement est le test de divulgation le plus net : intègre au fichier ce dont chaque branche a besoin, et pousse derrière un pointeur ce que seules certaines branches atteignent. Quand un document comporte des étapes, une référence dans le fichier qui devrait être divulguée les enterre et transforme le fait d'y prêter attention en pile ou face : un levier de variance, pas seulement de lisibilité.

La **co-localisation** est le pendant intra-fichier : là où l'échelle décide _jusqu'où_ un morceau descend, la co-localisation décide _ce qui se tient à côté de lui_ une fois arrivé. Garde la définition, les règles et les mises en garde d'un concept sous un même titre plutôt qu'éparpillées, pour que lire une partie amène ses voisines avec elle. Le test : le document doit se lire comme de la documentation écrite pour l'agent. Un matériau groupé se lit ainsi ; un matériau éparpillé, non. (À distinguer de la duplication : celle-ci répète un sens à deux endroits ; l'éparpillement fragmente un sens sur plusieurs.)

L'**étalement** est le mode de défaillance à cet endroit : un document tout simplement trop long, même quand chaque ligne est vivante et unique. L'attention se dilue sur l'excédent, et chaque ligne de plus est une ligne de plus à garder pertinente. Le remède est l'échelle : divulgue la référence derrière des pointeurs, et découpe par branche ou par séquence pour que chaque chemin ne porte que ce dont il a besoin.

## Étapes et critères d'achèvement

Chaque étape se termine sur un **critère d'achèvement**, la condition qui dit à l'agent que le travail est fini. Deux propriétés en font un levier :

- La **clarté** : l'agent sait-il distinguer fini de pas-fini ? Une borne vague (« compréhension atteinte ») invite à l'**achèvement prématuré** : terminer l'étape avant qu'elle ne soit réellement finie, l'attention glissant vers le fait _d'en avoir fini_. Les étapes visibles encore devant (les **étapes post-achèvement**) fournissent la traction ; la clarté du critère est la résistance. Défends dans cet ordre : **affûte d'abord la borne** (local et bon marché) ; seulement si elle est irréductiblement floue _et_ que tu observes la précipitation, cache les étapes ultérieures en découpant la séquence. Cacher ne fonctionne qu'à travers une vraie frontière de contexte (une passation ou l'envoi d'un sous-agent ; un appel inline laisse les étapes ultérieures dans le contexte et ne vide rien).
- L'**exigence** : combien le critère réclame. « Chaque modèle modifié est pris en compte » force un travail minutieux là où « produire une liste de changements » ne le fait pas. L'exigence entraîne le **travail de fond** (les fouilles que l'agent mène à l'intérieur du travail, latentes dans la formulation plutôt qu'écrites comme une étape à part), et elle n'est pas liée aux étapes : « chaque règle appliquée » contraint un corps de référence plate autant que « chaque étape faite » contraint une séquence, ce qui est la façon dont un document tout en référence porte quand même une barre d'exhaustivité.

Les critères les plus forts sont à la fois vérifiables et exhaustifs.

## Quand découper

Découper un document en deux dépense l'une des deux charges, alors ne découpe que si la coupe le mérite :

- **Par séquence** : découpe une suite d'étapes là où les étapes post-achèvement poussent l'agent à bâcler celle qui est devant lui. Les garder hors de vue entraîne plus de travail de fond sur la tâche courante. Attention à l'inverse : fusionner des séquences expose chaque étape à ce qui la suit, ce qui invite à l'achèvement prématuré.
- **Par invocation**, spécifique aux skills : voir [`SKILL-MECHANICS.md`](SKILL-MECHANICS.md).

## Mots directeurs

Un **mot directeur** est un concept compact vivant déjà dans le pré-entraînement du modèle, avec lequel l'agent pense pendant qu'il exécute le document (_lesson_, _fog of war_, _tracer bullets_). Répété comme token, jamais comme phrase, il accumule une définition distribuée et ancre toute une région de comportement en un minimum de tokens, en recrutant des a priori que le modèle détient déjà. Forger le tien fonctionne si tu le définis clairement, mais un mot inventé ne recrute aucun a priori : tu paies en tokens de définition ce qu'un mot pré-entraîné donne gratuitement ; cherche d'abord un mot existant.

Il ancre deux fois. Dans le corps, l'_exécution_ : l'agent recourt au même comportement chaque fois que le mot apparaît, et à l'intérieur d'une référence plate il concentre l'attention sur une classe de choses à chercher. Dans un pointeur, l'_invocation_ : quand le même mot vit dans tes prompts, tes docs et ta base de code, l'agent relie ce langage partagé au matériau et l'atteint plus fiablement.

Chasse les occasions de refactorer avec des mots directeurs. Un triptyque écrit en toutes lettres à trois endroits, un pointeur qui dépense une phrase pour désigner une seule idée. Chacun est un passage qui supplie de s'effondrer en un seul token :

- « rapide, déterministe, à faible surcoût » → _tight_ (une boucle _tight_).
- « une boucle en laquelle tu crois » → _red_, ce qui transforme une porte floue en un état binaire observable (la boucle devient _red_ sur le bug, ou non).

Tu gagnes deux fois : moins de tokens, et un crochet plus net où l'agent accroche sa pensée. Pars du principe que chaque document transporte des redites que des mots directeurs mettent à la retraite. Va les trouver.

La **négation** est le mode de défaillance qui accompagne ce levier : piloter par l'interdit tire le comportement interdit dans le contexte et le rend _plus_ disponible, pas moins. _Ne pense pas à un éléphant_, et il n'y a plus que l'éléphant ; la négation est un faible modificateur que le concept fortement activé submerge, si bien que l'interdiction se lit à moitié comme une consigne de faire la chose. Formule le **positif** : énonce le comportement visé (« écrire des commentaires d'une ligne ») pour que celui qui est banni ne soit jamais prononcé. Une interdiction ne mérite sa place que comme garde-fou dur que tu ne peux pas formuler positivement ; et même alors, associe-la à la cible positive pour que l'attention se pose sur ce qu'il faut faire.

## Élagage

- Garde chaque sens dans une **source de vérité unique** : un seul endroit faisant autorité, pour que changer le comportement soit une édition à un seul endroit. La **duplication** (le même sens à plus d'un endroit) coûte en maintenance et en tokens, et gonfle la proéminence d'un sens sur l'échelle au-delà de son rang réel. (L'inverse accidentel d'un mot directeur, qui répète un token à dessein, jamais le sens.)
- L'**environnement** est lui aussi une source de vérité (les scripts de `package.json`, les fichiers de configuration, l'arborescence des dossiers, la sortie de `--help`), et un document qui le redit est un **cache** : la copie d'une consultation, qui ne mérite sa charge que lorsque la consultation coûte cher. Mets en cache ce que l'agent ne peut pas trouver en regardant : la convention non écrite, la raison derrière un choix, le piège qu'aucune configuration n'avoue. Laisse à l'environnement les consultations à un fichier, à une commande, là où elles ne peuvent pas devenir obsolètes.
- Vérifie la **pertinence** de chaque ligne : porte-t-elle encore sur ce que fait le document ? Une ligne perd sa pertinence en ne portant jamais sur la tâche (simple exposé, ou branche qui devrait être divulguée) ou en devenant obsolète à mesure que change le comportement ou le monde qu'elle décrit. Les documents plus courts sont plus faciles à garder pertinents. Sans discipline d'élagage, le destin par défaut est le **sédiment** : des couches obsolètes qui se déposent parce qu'ajouter paraît sûr et retirer paraît risqué, jusqu'à ce qu'il faille carotter à travers elles pour trouver ce qui est encore vivant.
- Chasse les **no-ops** phrase par phrase : une instruction que le modèle suit déjà par défaut paie une charge pour ne rien dire. Le test (change-t-elle le comportement par rapport au défaut ?) est relatif au modèle, pas au lecteur : deux personnes en désaccord sur un no-op sont en désaccord sur le défaut, et elles tranchent en exécutant le document, pas en débattant. Quand une phrase échoue, supprime la phrase entière plutôt que de lui rogner des mots. Le test note aussi les mots directeurs : un mot trop faible pour battre le défaut (_sois minutieux_ quand l'agent est déjà à peu près minutieux) est un no-op, et le correctif est un mot plus fort (_implacable_), pas une autre technique.
