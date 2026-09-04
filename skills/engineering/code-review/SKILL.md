---
name: code-review
description: "Relit les changements depuis un point fixe (commit, branche, tag ou merge-base) selon deux axes : Standards (le code respecte-t-il les standards de code documentés du dépôt ?) et Spec (le code fait-il ce que l'issue ou la spec d'origine demandait ?). Lance les deux revues dans des sous-agents parallèles et les rapporte côte à côte. À utiliser quand l'utilisateur veut relire une branche, une PR, un travail en cours, ou demande de « relire depuis X »."
---

Revue à deux axes du diff entre `HEAD` et un point fixe fourni par l'utilisateur :

- **Standards** : le code est-il conforme aux standards de code documentés du dépôt ?
- **Spec** : le code implémente-t-il fidèlement l'issue ou la spec d'origine ?

Les deux axes tournent dans des **sous-agents parallèles**, pour ne pas polluer leurs contextes respectifs ; ce skill agrège ensuite leurs constats.

L'issue tracker devrait t'avoir été fourni. Si `docs/agents/issue-tracker.md` est absent, dire à l'utilisateur de lancer `/setup-sdlc`.

## Process

### 1. Fixer le point de référence

Le point fixe est celui que l'utilisateur a indiqué (un SHA de commit, un nom de branche, un tag, `HEAD~5`, etc.), ou celui qu'un skill appelant a fourni. Si personne n'en a donné, le demander.

`/implement` appelle ce skill deux fois, à deux découpages qu'il ne faut pas confondre : à chaque ticket, le point fixe est le `HEAD` d'avant le travail du ticket ; au dernier ticket de la fonctionnalité, c'est le **trunk**, et le diff porte alors sur la fonctionnalité entière.

Capturer la commande de diff une fois pour toutes : `git diff <point-fixe>...HEAD` (trois points, pour que la comparaison se fasse par rapport à la merge-base). Noter aussi la liste des commits via `git log <point-fixe>..HEAD --oneline`. Quand l'appelant relit un travail qu'il n'a pas encore commité — c'est le cas de la revue par ticket de `/implement`, qui relit avant de commiter —, comparer à l'arbre de travail : `git diff <point-fixe>` sans les trois points, sinon le diff est vide. Sa revue de fonctionnalité, elle, porte sur du travail déjà commité : les trois points s'appliquent normalement.

Avant d'aller plus loin, confirmer que le point fixe se résout (`git rev-parse <point-fixe>`) et que le diff n'est pas vide. Une mauvaise référence ou un diff vide doit échouer ici, pas à l'intérieur de deux sous-agents parallèles.

### 2. Identifier la source de la spec

Si un skill appelant l'a déjà fournie, la prendre telle quelle : `/implement` passe le ticket qu'il vient d'implémenter pour sa revue par ticket, et la **spec** de la fonctionnalité pour sa revue de fonctionnalité. Ne pas y substituer une source trouvée par la recherche ci-dessous — le découpage choisi par l'appelant est délibéré. Sinon, chercher la spec d'origine, dans cet ordre :

1. Les références d'issue dans les messages de commit (`#123`, `Closes #45`, `!67` chez GitLab, etc.), récupérées via le workflow décrit dans `docs/agents/issue-tracker.md`.
2. Un chemin passé en argument par l'utilisateur.
3. Un fichier de spec sous `docs/`, `specs/` ou `.scratch/` correspondant au nom de la branche ou de la fonctionnalité.
4. Si rien n'est trouvé, demander à l'utilisateur où est la spec. S'il répond qu'il n'y en a pas, le sous-agent **Spec** est sauté et rapporte « pas de spec disponible ».

### 3. Identifier les sources de standards

Tout ce qui, dans le dépôt, documente la façon dont le code doit être écrit : `CODING_STANDARDS.md`, `CONTRIBUTING.md`, etc.

En plus de ce que le dépôt documente, l'axe Standards porte toujours la **base de référence des smells** ci-dessous : un ensemble fixe de code smells de Fowler (_Refactoring_, ch. 3) qui s'applique même quand le dépôt ne documente rien. Deux règles l'encadrent :

- **Le dépôt prime.** Un standard documenté du dépôt l'emporte toujours ; là où il approuve quelque chose que la base signalerait, supprimer le smell.
- **Toujours un jugement.** Chaque smell est une heuristique étiquetée (« possible Feature Envy »), jamais une violation dure. Comme pour tout standard ici, sauter ce que l'outillage applique déjà.

Chaque smell se lit *ce que c'est* → *comment le corriger* ; le confronter au diff :

- **Mysterious Name** : une fonction, une variable ou un type dont le nom ne dit pas ce qu'il fait ou contient. → le renommer ; si aucun nom honnête ne vient, c'est le design qui est trouble.
- **Duplicated Code** : la même forme de logique apparaît dans plus d'un hunk ou fichier du changement. → extraire la forme commune, l'appeler des deux côtés.
- **Feature Envy** : une méthode qui touche aux données d'un autre objet plus qu'aux siennes. → déplacer la méthode vers les données qu'elle envie.
- **Data Clumps** : les mêmes quelques champs ou paramètres voyagent toujours ensemble (un type qui demande à naître). → les regrouper en un seul type et passer celui-ci.
- **Primitive Obsession** : un primitif ou une chaîne tient lieu d'un concept du domaine qui mérite son propre type. → donner au concept son propre petit type.
- **Repeated Switches** : le même `switch` ou la même cascade de `if` sur le même type revient dans tout le changement. → remplacer par du polymorphisme, ou une table partagée par les deux endroits.
- **Shotgun Surgery** : un seul changement logique impose des modifications éparpillées dans de nombreux fichiers du diff. → rassembler ce qui change ensemble dans un même module.
- **Divergent Change** : un fichier ou un module est modifié pour plusieurs raisons sans rapport. → découper pour que chaque module ne change que pour une seule raison.
- **Speculative Generality** : abstraction, paramètres ou points d'extension ajoutés pour des besoins que la spec n'a pas. → supprimer ; réinliner jusqu'à ce qu'un vrai besoin apparaisse.
- **Message Chains** : de longues navigations `a.b().c().d()` dont l'appelant ne devrait pas dépendre. → cacher le parcours derrière une méthode du premier objet.
- **Middle Man** : une classe ou une fonction qui ne fait guère que déléguer plus loin. → la supprimer, appeler la vraie cible directement.
- **Refused Bequest** : une sous-classe ou une implémentation qui ignore ou surcharge l'essentiel de ce qu'elle hérite. → abandonner l'héritage, utiliser la composition.

### 4. Lancer les deux sous-agents en parallèle

Si un skill appelant a fourni un **cadrage** — une consigne qui restreint ce que la revue doit chercher —, le coller verbatim en tête des deux briefs ci-dessous. `/implement` en passe un pour sa revue de fin de fonctionnalité, dont le diff a déjà été relu ticket par ticket : sans ce cadrage, la revue rapporte à nouveau ce qui a déjà été arbitré. Un cadrage restreint le champ de la recherche ; il ne relâche jamais le critère d'achèvement des briefs.

Si l'étape 1 a retenu la commande de l'arbre de travail, le dire dans les deux prompts : le travail n'est pas encore commité, la liste des commits est donc vide.

Le **prompt du sous-agent Standards** doit inclure :

- La commande de diff retenue à l'étape 1 et la liste des commits.
- La liste des fichiers-sources de standards trouvés à l'étape 3, **plus la base de référence des smells de l'étape 3 collée intégralement** (le sous-agent n'y a aucun autre accès).
- Le brief : « Rapporte, par fichier ou hunk quand c'est pertinent, (a) chaque endroit où le diff enfreint un standard documenté : cite le standard (fichier + règle) ; et (b) tout smell de la base que tu repères : nomme-le et cite le hunk. Distingue les violations dures des jugements : une infraction à un standard documenté peut être dure, mais les smells de la base sont toujours des jugements, et un standard documenté du dépôt l'emporte sur la base. Saute tout ce que l'outillage applique. Moins de 400 mots. »

Le **prompt du sous-agent Spec** doit inclure :

- La commande de diff retenue à l'étape 1 et la liste des commits.
- Le chemin ou le contenu récupéré de la spec.
- Le brief : « Rapporte : (a) les exigences demandées par la spec qui sont absentes ou partielles ; (b) les comportements présents dans le diff qui n'ont pas été demandés (dérive de périmètre) ; (c) les exigences qui semblent implémentées mais dont l'implémentation paraît fausse. Cite la ligne de spec pour chaque constat. Moins de 400 mots. »

Si la spec est absente, sauter le sous-agent Spec et le signaler dans le rapport final.

### 5. Agréger

Présenter les deux rapports sous les titres `## Standards` et `## Spec`, verbatim ou légèrement nettoyés. Ne **pas** fusionner ni reclasser les constats : les deux axes sont délibérément séparés (voir _Pourquoi deux axes_).

Terminer par un résumé d'une ligne : nombre total de constats par axe, et le pire problème _à l'intérieur de chaque axe_ (s'il y en a un). Ne pas désigner un unique gagnant tous axes confondus : c'est exactement le reclassement que la séparation existe pour empêcher.

## Pourquoi deux axes

Un changement peut passer un axe et échouer à l'autre :

- Du code qui respecte tous les standards mais implémente la mauvaise chose → **Standards OK, Spec KO.**
- Du code qui fait exactement ce que l'issue demandait mais casse les conventions du projet → **Spec OK, Standards KO.**

Les rapporter séparément empêche un axe de masquer l'autre.
