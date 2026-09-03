---
name: implement
description: "Implémente un ticket ou une spec sur la branche de sa fonctionnalité, puis valide le résultat critère d'acceptation par critère d'acceptation avant de commiter et d'ouvrir la PR."
disable-model-invocation: true
---

Implémenter le travail décrit par l'utilisateur dans le ticket ou la spec, puis **prouver** qu'il est fait.

## 1. Charger le ticket

Lire le ticket en entier — corps, critères d'acceptation, bloqueurs. Si l'utilisateur a passé un chemin ou un numéro, le récupérer via le workflow décrit dans `docs/agents/issue-tracker.md`. Sur un tracker markdown local, un numéro nu ne suffit pas à désigner un fichier : la chaîne prescrit un `/clear` entre chaque ticket, donc le `<feature-slug>` n'est plus en contexte. Parcourir `.scratch/*/issues/` à la recherche du fichier portant ce numéro — le glob est sans ambiguïté, les tickets de décision d'un chantier `/wayfinder` vivant sous `.scratch/<chantier>/decisions/`. Un seul : l'annoncer et continuer. Plusieurs : demander lequel. Aucun : le dire et demander le chemin complet.

Vérifier que les bloqueurs du ticket sont tous terminés. Si l'un ne l'est pas, le dire et s'arrêter : implémenter un ticket bloqué produit du travail à refaire.

Si le ticket ne porte **aucun critère d'acceptation**, ne pas en inventer en silence. Les proposer à l'utilisateur, les faire valider, et les écrire dans le ticket avant de commencer. On ne peut pas valider contre une cible qui n'existe pas.

## 2. Se placer sur la branche de la fonctionnalité

Lire `docs/agents/git-workflow.md`. **S'il n'existe pas, sauter cette étape** et travailler sur la branche courante : le dépôt n'a pas déclaré de modèle de branche, ce n'est pas à ce skill d'en imposer un.

Sous le modèle par défaut — une branche par fonctionnalité — déterminer la branche attendue à partir du ticket chargé à l'étape 1 :

- **Tickets en markdown local** : le `<feature-slug>` est le répertoire qui contient `issues/`, soit `.scratch/<feature-slug>/issues/NN-*.md`. Branche attendue : `feature/<feature-slug>`.
- **Tickets dans un tracker** : dériver le slug de l'issue parente que le ticket référence dans sa section « Parent ». À défaut de parent, du titre de la fonctionnalité. Le proposer à l'utilisateur avant de créer quoi que ce soit — un slug inventé en silence casse le lien que `/code-review` suit depuis le nom de la branche pour retrouver la spec.

Comparer avec `git branch --show-current` :

- **C'est déjà la branche attendue** → continuer.
- **On est sur le trunk** → créer la branche depuis un trunk à jour, et le dire. Arbre de travail sale : s'arrêter et le signaler, ne pas emporter des modifications non liées sur une branche neuve.
- **On est sur une autre branche de fonctionnalité** → s'arrêter et demander. Implémenter un ticket de la fonctionnalité B sur la branche de la fonctionnalité A mélange deux PR ; c'est une décision de l'utilisateur, pas une supposition.

Constater enfin si le dépôt a un remote : `git remote` muet, il n'y en a pas. Le modèle de branche tient tel quel ; c'est son dernier geste qui tombe — **ne pas pousser à l'étape 6, ne pas ouvrir de PR à l'étape 7**. Commiter sur la branche locale, et remettre en clair à l'utilisateur ce qui aurait été le corps de la PR. Le cas est courant en greenfield, `/setup-sdlc` proposant justement le tracker markdown local aux dépôts sans remote.

L'état git est sur disque, comme le ticket : cette étape se retrouve seule après un `/clear`, sans rien devoir à la fenêtre précédente.

## 3. Implémenter

Appeler l'outil Skill avec « tdd » autant que possible, aux seams convenus à l'avance. Un seam non confirmé n'est pas un seam.

Découvrir les vérifications automatisées du projet et les lancer régulièrement — typiquement le typecheck, puis les fichiers de test concernés. Garder la boucle courte.

Rester dans le périmètre du ticket. Tout ce qui est utile mais hors périmètre se note pour un ticket suivant, ne s'implémente pas ici.

## 4. Valider, critère par critère

C'est l'étape qui distingue « le code est écrit » de « le ticket est fait ». Ne pas la résumer.

Reprendre les critères d'acceptation **un par un, dans l'ordre**. Pour chacun, énoncer :

- La **preuve** : le test qui le couvre, ou la vérification manuelle effectuée avec son résultat observé.
- Le **verdict** : satisfait, partiellement satisfait, ou non satisfait.

Un critère sans preuve nommable n'est pas satisfait. « Ça devrait marcher » n'est pas une preuve ; le nom d'un test qui passe en est une.

Puis lancer la suite de tests **complète**, une fois. Une suite verte sur les fichiers touchés ne dit rien de ce que le changement a cassé ailleurs.

Si un critère n'est pas satisfait : revenir à l'étape 3. Ne pas cocher, ne pas commiter, ne pas signaler le ticket comme terminé.

## 5. Relire

Appeler l'outil Skill avec « ai-native-sdlc:code-review » (forme namespacée : le nom nu entre en collision avec la commande intégrée). Son axe **Spec** confronte le diff au ticket d'origine — c'est un second regard sur ce que l'étape 4 vient d'affirmer, et il est indépendant.

Lui passer d'emblée les deux choses qu'il demanderait sinon : le **point fixe**, c'est-à-dire le `HEAD` d'avant le travail du ticket, en signalant que ce travail n'est pas encore commité ; et la **référence du ticket** comme source de spec, sous la forme résolue à l'étape 1 — le chemin du fichier sur un tracker local, jamais un numéro nu, que la revue ne sait pas résoudre.

C'est ici qu'a lieu le refactor, le troisième temps du red-green-refactor que la boucle de `/tdd` laisse volontairement de côté : les constats de l'axe **Standards** — les smells de la base de référence de Fowler que la revue rapporte — se traitent maintenant, la suite de tests restant verte à chaque pas. Traiter les constats bloquants avant de commiter. Consigner ceux qu'on choisit de ne pas traiter, avec la raison.

## 6. Clore le ticket

Cocher les critères d'acceptation dans le ticket, et y consigner la preuve retenue pour chacun.

Commiter sur la branche de l'étape 2, en référençant le ticket dans le message. Un ticket, un commit ; la branche porte le `<feature-slug>`, et c'est ce qui laisse une revue retrouver la spec depuis le nom de la branche. Puis pousser la branche, sauf dépôt sans remote (étape 2).

Dire à l'utilisateur quels tickets sont désormais débloqués par celui-ci.

Reste-t-il des tickets ouverts dans la fonctionnalité ? Cela se constate, ne se suppose pas : les autres fichiers de `.scratch/<feature-slug>/issues/`, ou les sous-issues encore ouvertes du parent. **S'il en reste, s'arrêter ici** ; l'étape 7 ne concerne que le dernier ticket. Dans le doute, s'arrêter aussi, et le dire.

## 7. Clore la fonctionnalité

Ne tourne qu'au dernier ticket de la fonctionnalité. Deux choses, dans cet ordre : relire la fonctionnalité entière, puis ouvrir la PR.

**La revue de fonctionnalité.** Rappeler l'outil Skill avec « ai-native-sdlc:code-review », sur un tout autre découpage que celui de l'étape 5 :

- **Point fixe** : le trunk nommé par `docs/agents/git-workflow.md`. Le diff est donc la fonctionnalité complète, pas le dernier ticket. Le travail est commité, cette fois : la comparaison à trois points s'applique normalement.
- **Source de spec** : la **spec** de la fonctionnalité — `.scratch/<feature-slug>/spec.md`, ou l'issue de spec dont les tickets descendent. Surtout pas un ticket : c'est le couple trunk + spec qui fait tout l'intérêt de cette passe. **S'il n'y a pas de spec** — `/to-spec` a été sauté —, le dire à la revue au lieu de la laisser en chercher une : elle tourne alors sur son seul axe Standards, qui suffit à voir les incohérences entre tickets, et le rapport porte la mention que rien n'a confronté le diff à une intention.
- **Cadrage** à lui transmettre, verbatim : « Ce diff a déjà été relu ticket par ticket, chaque ticket contre son propre ticket. Ne rapporte que ce que seul le diff complet révèle : (a) les exigences de la spec que ne couvre aucun ticket — trace chaque exigence de la spec jusqu'à l'endroit du diff qui la satisfait, ou déclare-la non couverte ; (b) les incohérences entre tickets — duplication, deux solutions au même problème, une abstraction créée par un ticket puis contournée par un autre. Ne rouvre pas ce qui a déjà été arbitré au niveau du ticket. »

Ce que cette passe cherche est invisible ticket par ticket, par construction. Une exigence tombée entre deux tickets au moment du découpage n'est écrite dans aucun ticket : aucune revue de ticket ne peut la chercher. Une duplication entre le ticket 1 et le ticket 4 laisse les deux revues au vert.

Traiter les constats bloquants avant d'ouvrir la PR, en commits sur la même branche, et pousser s'il y a lieu. Consigner ceux qu'on écarte, avec la raison.

**La PR.** Sans remote, il n'y en a pas — étape 2. Sinon `gh pr create --base <trunk>`, en résumant la fonctionnalité, en listant les tickets qu'elle clôt, et en reprenant le résultat de la revue de fonctionnalité — c'est ce que l'utilisateur lira avant de décider de merger.

**Ne pas merger la PR**, ni y toucher ensuite. C'est la décision que l'utilisateur se réserve, et la raison d'être des garde-fous posés par `/setup-sdlc`. Si une commande git est refusée, ce refus est le mécanisme qui fonctionne : le rapporter à l'utilisateur, ne pas chercher une autre formulation qui passerait.
