# Prototype de logique

Un fichier HTML unique et autonome (une **démo partageable**) qui laisse n'importe qui piloter un modèle d'état en cliquant sur des boutons. À utiliser quand la question porte sur la **logique métier, les transitions d'état ou la forme des données** : le genre de chose qui a l'air raisonnable sur papier et qu'on ne sent bancale qu'une fois poussée dans de vrais cas.

Comme c'est un seul fichier avec rien à installer, tu peux le donner à un non-développeur (un designer, un PM, un expert du domaine) et le laisser ressentir le modèle par lui-même. Il parle donc sa langue à lui, pas celle du code.

## Quand c'est la bonne forme

- « Je ne suis pas sûr que cette machine à états gère le cas limite où X puis Y. »
- « Est-ce que ce modèle de données me permet vraiment de représenter le cas où… »
- « Je veux sentir à quoi devrait ressembler l'API avant de l'écrire. »
- Toute situation où quelqu'un veut **appuyer sur des boutons et regarder l'état changer**.

Si la question est « à quoi est-ce que ça devrait ressembler », c'est la mauvaise branche. Utiliser [UI.md](UI.md).

## Procédure

### 1. Énoncer la question

Avant d'écrire du code, noter par écrit quel modèle d'état et quelle question sont prototypés. Un paragraphe, en haut de la démo (dans une intro visible, pas seulement dans un commentaire). Un prototype de logique qui répond à la mauvaise question est du pur gâchis : rendre donc la question explicite pour qu'elle puisse être vérifiée plus tard, que l'utilisateur regarde maintenant ou qu'il y revienne plus tard, loin du clavier.

### 2. Isoler la logique dans un module portable

Mettre la logique réelle (la partie qui répond à la question) dans un seul bloc `<script>`, écrit comme un petit module pur qui pourrait être extrait tel quel et déposé plus tard dans la vraie base de code. La page autour est jetable ; ce module ne l'est pas.

La bonne forme dépend de la question :

- **Un reducer pur** : `(state, action) => state`. Bon quand les actions sont des événements discrets et que l'état est une valeur unique.
- **Une machine à états** : états et transitions explicites. Bon quand « quelles actions sont autorisées à cet instant » fait partie de la question.
- **Un petit ensemble de fonctions pures** sur un type de données simple. Bon quand il n'y a pas d'état courant implicite, juste des transformations.
- **Une classe ou un module avec une surface de méthodes claire** quand la logique possède réellement un état interne qui perdure.

Choisir la forme qui correspond le mieux à la question posée, *et non* celle qui est la plus facile à brancher sur une page. La garder pure : pas de DOM, pas de `document`, pas de gestionnaires de boutons qui viennent fouiller dedans. La page appelle le module ; rien ne circule dans l'autre sens. C'est ce qui rend le prototype utile au-delà de sa propre durée de vie : une fois la question tranchée, la version validée du reducer / de la machine / de l'ensemble de fonctions se transplante toute seule dans le vrai module.

### 3. Construire le fichier HTML partageable

Un seul fichier, HTML/CSS/JS bruts : pas de framework, pas de bundler, pas de serveur, tout intégré au fichier pour qu'il s'ouvre d'un double-clic et survive à un envoi par e-mail. N'importe qui doit pouvoir le lancer simplement en l'ouvrant.

L'écrire pour un non-développeur. Chaque libellé est dans le **langage du domaine**, pas dans celui du code : les boutons et l'état se lisent comme le métier, pas comme le reducer. Expliquer en mots simples ce qui se passe.

Le disposer selon une hiérarchie claire, de haut en bas :

1. **Titre et explication en une ligne** de ce que cette démo permet d'explorer (la question de l'étape 1).
2. **État courant** : tout l'état pertinent, rendu sous forme de panneau lisible (des champs étiquetés, pas un dump JSON brut), re-rendu après chaque clic pour que le changement soit visible. Là où cela aide un non-développeur à suivre, signaler ce qui vient de changer.
3. **Boutons en libre exploration** : un bouton par action, toujours disponibles, pour que n'importe qui puisse titiller le modèle dans n'importe quel ordre. Chaque clic dispatche son action et re-rend l'état.
4. **Parcours guidés** : un ensemble de **scénarios**, un par onglet. Chaque onglet contient une courte description en langage courant du scénario (la situation qu'il met en place et ce qu'il faut observer) et, en dessous, les **boutons à presser** dans l'ordre pour ce scénario. Chaque étape est un vrai bouton : le cliquer effectue l'action et passe à l'étape suivante. Démarrer un parcours réinitialise à un état initial connu pour que le scénario se déroule de la même façon à chaque fois.

Choisir des scénarios qui démontrent les cas délicats, ceux qui sont difficiles à raisonner sur papier : le chemin nominal, un cas limite épineux, une tentative de faire quelque chose qui devrait être interdit.

Le garder beau mais sobre : typographie propre, espacements généreux, une seule couleur d'accent. Pas d'animations, pas de gadgets : rien qui vienne concurrencer l'état et les boutons.

### 4. Le transmettre

Leur envoyer le fichier, ou l'ouvrir pour eux. Ils cliqueront dans les parcours guidés et exploreront librement quand ils en auront le temps ; les moments intéressants sont ceux où ils disent « attends, ça ne devrait pas être possible » ou « tiens, je pensais que X serait différent » ; ce sont les bugs de l'_idée_, et c'est tout l'intérêt. S'ils veulent de nouvelles actions ou un nouveau scénario, les ajouter. Les prototypes évoluent.

### 5. Capturer la réponse et le prototype

Une fois que le prototype a répondu à sa question, capturer la réponse, puis capturer le prototype comme le décrit le [SKILL](SKILL.md). La correspondance spécifique à la logique : la version validée du reducer / de la machine / de l'ensemble de fonctions se transplante dans le vrai module (la décision, absorbée) ; la coquille HTML, elle, part sur la branche jetable qui conserve le prototype comme source primaire et, comme c'est un fichier unique et autonome, elle y reste trivialement ré-exécutable.

## Anti-patterns

- **Ne pas ajouter de tests.** Un prototype qui a besoin de tests n'est plus un prototype.
- **Ne pas le brancher sur la vraie base de données.** Utiliser un état en mémoire, sauf si la question porte spécifiquement sur la persistance.
- **Ne pas généraliser.** Pas de « et si on voulait supporter X plus tard ». Le prototype répond à une seule question.
- **Ne pas mélanger la logique et la page.** Si le module pur référence le DOM, `document` ou des gestionnaires de boutons, il n'est plus transplantable. Garder la page comme une fine coquille au-dessus d'un module pur.
- **Ne pas se ruer sur un framework, un bundler ou un serveur.** Un seul fichier que le destinataire ouvre d'un double-clic ; une app React ou un serveur de dev anéantissent le « partageable ».
- **Ne pas expédier la coquille HTML en production.** La page est optimisée pour être cliquée à la main. C'est le module de logique derrière elle qui vaut la peine d'être gardé.
