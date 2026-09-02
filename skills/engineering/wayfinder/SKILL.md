---
name: wayfinder
description: Planifier un énorme chantier (plus que ce qu'une seule session d'agent peut contenir) sous la forme d'une carte partagée de tickets de décision sur ton issue tracker, puis les résoudre un par un jusqu'à ce que le chemin vers la destination soit clair.
disable-model-invocation: true
---

Une idée vague est arrivée, trop grosse pour une seule session d'agent, et noyée dans le brouillard : le chemin d'ici jusqu'à la **destination** n'est pas encore visible. Le wayfinding consiste à trouver ce chemin, pas à foncer sur la destination. Ce skill cartographie le chemin sous forme de **carte partagée** sur l'issue tracker du dépôt, puis traite ses **tickets de décision** (des questions dont la résolution est une décision, pas des tranches de construction à exécuter) un par un jusqu'à ce que la route soit claire.

La destination varie d'un chantier à l'autre, et la nommer est le premier acte de cartographie : elle façonne chaque ticket. Ce peut être une spec à transmettre et à itérer, une décision à verrouiller avant que la planification ne commence, ou un changement effectué sur place comme une migration de structure de données. La carte est agnostique du domaine : travail d'ingénierie, contenu de cours, tout ce qui épouse cette forme.

## Planifier, pas faire

Wayfinder fait de la **planification** par défaut : chaque ticket résout une décision, et la carte est terminée quand le chemin est clair, sans plus rien à décider avant que quelqu'un aille faire la chose. L'envie de simplement faire le travail est en général le signe que tu as atteint le bord de la carte et qu'il est temps de passer la main. Un chantier peut surcharger cette règle dans ses **Notes**, et porter l'exécution jusque dans la carte elle-même, mais à défaut, produis des décisions, pas des livrables.

## Désigner par le nom

Chaque carte et chaque ticket est une issue, donc a un **nom** : son titre. Dans tout ce que l'humain lit (narration, section Décisions à ce jour de la carte), désigne-les par ce nom, jamais par un simple id, numéro ou slug. Un mur de `#42, #43, #44` est illisible ; les noms se lisent d'un coup d'œil. L'id et l'URL ne disparaissent pas — un nom enveloppe son lien — mais ils voyagent _à l'intérieur_ du nom, ils ne le remplacent jamais.

## La carte

La carte est une issue unique sur l'issue tracker de ce dépôt, labellisée `wayfinder:map` ; c'est l'artefact canonique. Ses tickets sont des issues enfants de la carte.

La carte est un **index**, pas un entrepôt. Elle liste les décisions prises et pointe vers les tickets qui en contiennent le détail ; une décision vit à exactement un endroit, son ticket, donc la carte ne la reformule jamais : elle en donne seulement l'essentiel et met le lien.

**L'endroit où vivent physiquement la carte, ses tickets enfants, le blocage et les requêtes de frontière dépend du tracker.** L'issue tracker devrait t'avoir été fourni. Sinon, dis à l'utilisateur de lancer `/setup-sdlc`. Consulte la section « Opérations de wayfinding » de la doc du tracker pour savoir comment _ce_ dépôt les exprime. Si aucun tracker n'a été fourni, utilise par défaut le tracker markdown local.

Les labels `wayfinder:map` et `wayfinder:<type>` appartiennent à ce skill, pas à la configuration du dépôt : sur un tracker où un label doit préexister pour être appliqué, crée-le toi-même en dressant la carte, plutôt que de renvoyer l'utilisateur à une étape de configuration.

### Le corps de la carte

Toute la carte en basse résolution, chargée une fois par session. Les tickets ouverts n'y sont **pas** listés : ce sont des issues enfants ouvertes, retrouvées par requête.

```markdown
## Destination

<à quoi ressemble le fait d'atteindre le bout de cette carte : la spec, la décision ou le changement vers lequel ce chantier cherche son chemin. Une ou deux lignes ; chaque session s'y oriente avant de choisir un ticket.>

## Notes

<domaine ; skills que chaque session doit consulter ; préférences permanentes pour ce chantier>

## Décisions à ce jour

<!-- l'index : une ligne par ticket fermé, assez pour juger de la pertinence, puis zoomer sur le lien pour le détail que contient le ticket -->

- [<titre du ticket fermé>](lien) : <résumé en une ligne de la réponse>

## Pas encore spécifié

<!-- voir « Brouillard de guerre » : le brouillard dans le périmètre que tu ne peux pas encore ticketer ; promu à mesure que la frontière avance -->

## Hors périmètre

<!-- voir « Hors périmètre » : le travail jugé au-delà de la destination ; fermé, jamais promu -->
```

### Tickets

Chaque ticket est une **issue enfant** de la carte ; l'id d'issue du tracker est son identité. Son corps est la question, dimensionnée pour une session d'agent de 100K tokens :

```markdown
## Question

<la décision ou l'investigation que ce ticket résout>
```

Chaque ticket porte un label `wayfinder:<type>`, parmi `research`, `prototype`, `grilling`, `task` (voir [Types de ticket](#types-de-ticket)).

Une session **réserve** un ticket en l'assignant au dev qui pilote la carte, **d'abord**, avant tout travail, pour que les sessions concurrentes le sautent. Cet assigné _est_ la réservation : un ticket ouvert et non assigné n'est pas réservé.

Le blocage utilise la relation de dépendance **native** du tracker : c'est essentiel, parce que cela rend la frontière _visible_ dans l'interface du tracker lui-même, si bien que l'humain voit ce qui est prenable sans ouvrir la carte. Seul un tracker dépourvu de blocage natif se rabat sur une convention dans le corps. Un ticket est **débloqué** quand tous les tickets qui le bloquent sont fermés ; la **frontière**, ce sont les enfants ouverts, débloqués et non réservés : le bord du connu.

La réponse ne fait pas partie du corps ; elle est consignée à la résolution (voir [Parcourir la carte](#parcourir-la-carte)). Les ressources créées en résolvant un ticket sont liées depuis l'issue, pas collées dedans.

## Types de ticket

Chaque ticket est soit **HITL** (human in the loop : travaillé _avec_ un humain qui parle en son nom propre), soit **AFK**, mené par l'agent seul. Un ticket HITL ne se résout que par cet échange en direct ; l'agent ne se substitue jamais à la partie humaine (un agent de grilling qui répond à ses propres questions a enfreint cette règle).

- **Research** (AFK) : lire de la documentation, des API tierces ou des ressources locales comme des bases de connaissances pour faire remonter un fait dont dépend une décision. Résolu par un sous-agent qui appelle l'outil Skill avec « research ». À utiliser quand des connaissances extérieures au répertoire de travail courant sont nécessaires.
- **Prototype** (HITL) : élever la fidélité de la discussion en fabriquant un artefact concret, bon marché et grossier auquel réagir (un plan, une ébauche, un stub, ou du code d'UI/de logique) en appelant l'outil Skill avec « prototype ». Lie le prototype comme ressource. À utiliser quand « à quoi cela doit ressembler » ou « comment cela doit se comporter » est la question clé.
- **Grilling** (HITL) : la conversation. Le cas par défaut. Appelle toujours l'outil Skill deux fois, pour « grilling » et « domain-modeling ».
- **Task** (HITL ou AFK) : du travail manuel qui doit avoir lieu avant qu'une _décision_ puisse être prise : rien à décider, à prototyper ni à rechercher, mais la discussion est bloquée tant que ce n'est pas fait. S'inscrire à un service pour pouvoir juger son API, provisionner des accès, déplacer des données pour en voir la forme. C'est le seul type qui _fait_ au lieu de décider, et il gagne sa place en débloquant une décision, pas en livrant la destination. L'agent le mène seul quand il le peut (AFK) ; sinon il remet à l'humain une checklist précise (HITL). Résolu quand le travail est fait ; la réponse consigne ce qui a été fait et les faits qui en découlent (emplacement des identifiants, nouvelles URL, nombres de lignes) et dont dépendent les tickets ultérieurs.

## Brouillard de guerre

La carte est _délibérément_ incomplète : ne cartographie pas ce que tu ne vois pas encore. Au-delà des tickets vivants s'étend le **brouillard de guerre** : la vue floue des décisions et des investigations que tu devines à venir mais que tu ne peux pas encore fixer, parce qu'elles dépendent de questions encore ouvertes. Résoudre un ticket dissipe le brouillard devant lui et promeut en nouveaux tickets tout ce qui devient spécifiable, un à la fois, jusqu'à ce que le chemin vers la destination soit clair et qu'il ne reste plus aucun ticket.

La section **Pas encore spécifié** de la carte est l'endroit où cette vue floue s'écrit : la question soupçonnée, la zone à revisiter plus tard. C'est la frontière non découverte _vers_ la destination : tout ce qui s'y trouve est dans le périmètre, simplement pas assez net pour être ticketé. Écris de façon aussi vague ou aussi complète que la vue le permet ; cela sert aussi de panneau indicateur aux collaborateurs qui lisent où va le chantier.

**Brouillard ou ticket ?** Le test, c'est de savoir si tu peux énoncer la question précisément maintenant, _pas_ si tu peux y répondre maintenant.

- **Un ticket quand** la question est déjà nette, même si elle est bloquée et que tu ne peux pas encore agir dessus.
- **Pas encore spécifié quand** tu ne peux pas encore la formuler aussi nettement. Ne pré-découpe pas le brouillard en morceaux de la taille d'un ticket : il est plus grossier qu'un ticket, et une même zone peut être promue en plusieurs tickets, ou en aucun, une fois que la frontière l'atteint.

**Pas encore spécifié** exclut ce qui est déjà décidé (Décisions à ce jour), ce qui est déjà un ticket vivant, et ce qui est hors périmètre (la section suivante).

## Hors périmètre

Le brouillard ne s'amasse jamais que _vers_ la destination. La destination fixe le périmètre, donc le travail qui la dépasse est **hors périmètre** : ce n'est pas du brouillard, et il n'a pas sa place dans **Pas encore spécifié**. Il a sa propre section **Hors périmètre** sur la carte : le travail que tu as consciemment exclu de _ce_ chantier. C'est le périmètre, pas la netteté, qui l'y range.

Le travail hors périmètre n'est jamais promu (la frontière s'arrête à la destination) : il ne revient que si la destination est redessinée, et alors comme un nouveau chantier, pas comme une reprise.

Déclarer quelque chose hors périmètre est un acte de cadrage, pas une étape sur la route. Quand un ticket qui existe déjà se révèle situé au-delà de la destination (mal cadré au moment de la cartographie, ou mis au jour par une résolution), **ferme-le** (un ticket fermé est sans ambiguïté hors de la frontière) et laisse une ligne dans la section **Hors périmètre** : l'essentiel, plus la raison pour laquelle c'est hors périmètre, avec le lien vers le ticket fermé. Il reste en dehors de **Décisions à ce jour**, qui consigne la route effectivement parcourue ; une limite de périmètre n'en est pas une étape.

## Invocation

Deux modes. Dans les deux cas, **ne résous jamais plus d'un ticket par session**, à l'exception des tickets research.

### Dresser la carte

L'utilisateur invoque avec une idée vague.

1. **Nommer la destination.** Appelle l'outil Skill deux fois, pour « grilling » et « domain-modeling », afin de fixer ce vers quoi cette carte cherche son chemin : la spec, la décision ou le changement. La destination fixe le périmètre, elle se règle donc en premier.
2. **Cartographier la frontière.** Refais un grilling, **en largeur d'abord** cette fois : déploie-toi sur tout l'espace plutôt qu'en profondeur sur un seul fil, en faisant remonter les décisions ouvertes et les premiers pas prenables tout de suite. **Si cela ne fait remonter aucun brouillard** (le chemin vers la destination est déjà clair, tout le voyage tient dans une seule session), tu n'as pas besoin de carte. Arrête-toi et demande à l'utilisateur comment il souhaite procéder.
3. **Créer la carte** (label `wayfinder:map`) : Destination et Notes remplies, Décisions à ce jour vide, le brouillard esquissé dans **Pas encore spécifié**.
4. **Créer les tickets que tu peux spécifier maintenant** en tant qu'issues enfants de la carte, puis câbler les arêtes de blocage dans une **seconde passe** (les issues ont besoin d'un id avant de pouvoir se référencer entre elles). Le câblage les répartit entre la frontière et les bloqués ; tout ce que tu ne peux pas encore spécifier reste dans le brouillard : la section **Pas encore spécifié**.
5. **Lancer les sous-agents de research.** Pour chaque ticket `research` que tu viens de créer, démarre un sous-agent qui appelle l'outil Skill avec « research » pour le résoudre en parallèle, en consignant ses trouvailles sur une branche jetable `research/<name>` avec un pointeur de contexte depuis le ticket.
6. Arrête-toi : dresser la carte est le travail d'une session ; cela ne résout aucun ticket à la main.

### Parcourir la carte

L'utilisateur invoque avec une carte (URL ou numéro). Un ticket est **optionnel** : sans ticket, c'est toi qui choisis la décision suivante, pas l'utilisateur.

1. Charge la **carte** : la vue basse résolution, pas le corps de chaque ticket.
2. Choisis le ticket. Si l'utilisateur en a nommé un, prends celui-là. Sinon, prends le premier ticket de la frontière dans l'ordre. **Réserve-le** : assigne-le-toi avant tout travail.
3. Résous-le. **Zoome au besoin** : récupère à la demande le corps complet de n'importe quel ticket lié ou fermé ; appelle l'outil Skill pour les skills que nomme le bloc `## Notes`. En cas de doute, appelle l'outil Skill deux fois, pour « grilling » et « domain-modeling ».
4. Consigne la résolution : poste la réponse en **commentaire de résolution**, **ferme** l'issue, et **ajoute un pointeur de contexte** aux Décisions à ce jour de la carte.
5. Ajoute les tickets nouvellement apparus (créer puis câbler) ; promeus tout brouillard que la réponse a rendu spécifiable, en retirant de **Pas encore spécifié** chaque zone promue pour qu'elle ne vive plus que comme son nouveau ticket. Si la réponse révèle qu'un ticket (celui-ci ou un autre) se situe au-delà de la destination, **déclare-le hors périmètre** plutôt que de le résoudre sur la route. Si la décision invalide d'autres parties de la carte, mets à jour ou supprime ces tickets.

L'utilisateur peut faire tourner les tickets débloqués en parallèle : attends-toi donc à ce que d'autres sessions modifient le tracker en même temps.

## Ensuite

`/to-spec`. La carte est terminée quand le chemin vers la destination est clair et qu'il ne reste plus aucun ticket : annonce-le à l'utilisateur — la destination, les décisions qui y mènent, et le fait qu'il ne reste rien à décider avant que quelqu'un aille construire — puis passe la main.

Passer la main, c'est **nommer le `<feature-slug>`** de chaque spec que la carte appelle — un chantier en donne souvent plusieurs — puis annoncer à l'utilisateur la commande exacte à taper : `/to-spec <feature-slug>`, pointeur vers la carte compris. Ni le slug ni le pointeur ne survivent au `/clear` : ils doivent voyager dans la commande.

Le slug est en kebab-case et **distinct du nom du chantier** : il nomme le `.scratch/<feature-slug>/` où la spec est publiée, puis où `/to-tickets` écrira les tickets d'implémentation — ce qui laisse `.scratch/<chantier>/issues/` aux seuls tickets de décision. Les confondre mettrait deux vocabulaires `Status:` dans un même répertoire, et `/implement`, qui retrouve un ticket en balayant `.scratch/*/issues/`, prendrait une décision fermée pour une tranche à construire.

Sauf si les **Notes** du chantier en ont décidé autrement, wayfinder a produit des décisions et non des livrables : c'est `/to-spec` qui les condense en un plan constructible. Il ira lire la carte (`.scratch/<chantier>/map.md` sur le tracker markdown local, l'issue labellisée `wayfinder:map` ailleurs) pour ses **Décisions à ce jour**, puis les réponses consignées dans les tickets de décision fermés, pour le détail que l'index ne porte pas. Reboucler directement sur `/implement` sauterait cette condensation et jetterait ce détail.
