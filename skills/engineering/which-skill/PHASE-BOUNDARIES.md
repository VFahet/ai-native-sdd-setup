# Limites de phase

Une **phase** est un bloc de travail à l'intérieur d'une session : le grilling, l'implémentation, la QA. La définition est floue à dessein : une phase se termine quand tu te dis *« bon, on en a fini avec ça »*.

La **limite de phase** est l'intervalle entre deux phases, et c'est le seul endroit où cette décision a sa place. En pleine phase, il n'y a pas de décision à prendre : continuer, ou découper le travail restant en sous-agents. Compacter en pleine phase fait perdre le fil à l'agent.

## Les cinq options

| Option         | Ce que ça fait                                                                |
| -------------- | ----------------------------------------------------------------------------- |
| **Continuer**  | Rester dans la session. Aucun changement de contexte.                         |
| **`/clear`**   | Vider la fenêtre de contexte et repartir de rien.                             |
| **`/handoff`** | Écrire un fichier markdown portable et amorcer une session n'importe où avec. |
| **Sous-agent** | Envoyer la tâche dans sa propre fenêtre de contexte et récupérer un rapport.  |
| **`/compact`** | Compresser ce contexte et amorcer une session neuve avec le résumé.           |

## L'arbre

Dérouler de haut en bas à la limite. Le premier **oui** l'emporte.

**1. Peux-tu continuer dans cette session ?** Deux choses rendent la réponse positive : la phase suivante a besoin de celle-ci comme **source primaire**, ou il te reste assez de **[smart zone](https://www.aihero.dev/ai-coding-dictionary/smart-zone)** (~150k tokens) pour que la phase suivante y tienne. Grilling → implémentation est le oui standard : l'implémentation veut le raisonnement mot pour mot, pas un résumé de celui-ci. Continuer ne coûte rien et ne perd rien, donc l'écarter avant toute autre option.

**2. Le contexte est-il sans rapport avec ce qui vient ensuite ?** Tout ce qu'il y a dans cette session (l'exploration, les décisions, les impasses) est-il jetable ? Si oui, **`/clear`**. C'est le coup le moins cher du plateau : il ne prend aucun temps et rend la fenêtre entière. `/clear` n'est pas non plus définitif : l'ancienne session reste reprenable.

Le coût d'une erreur ici est à sens unique. Vider un contexte *pertinent*, c'est perdre le **pourquoi** derrière ce que tu as construit, et aucune relecture du diff ne te le rendra.

**3. As-tu besoin de passer la main ?** `/handoff` est étroit. Tu n'en as besoin que lorsque tu es en train de :

- changer de **harness** (Claude → Codex),
- passer à un **nouveau répertoire** ou un nouveau dépôt,
- envoyer le travail à un **collègue**,
- ou forker une tâche annexe trouvée **en pleine phase** sans faire dérailler ce que tu es en train de faire.

Cette liste, c'est toute la clause. Ce que `/handoff` achète, c'est la **portabilité** : un fichier qui voyage. Si rien ne voyage, tu n'en as pas besoin.

**4. La tâche peut-elle se faire AFK ?** Est-elle cadrée assez étroitement pour tourner sans toi devant le clavier, sans pilotage ? Alors l'envoyer à un **sous-agent** et laisser cette session intacte. La revue automatisée est le cas standard : l'agent lit le diff et rapporte, et tu n'es pas nécessaire pendant ce temps.

**5. Sinon, `/compact`.** Contexte pertinent, même harness, même répertoire, et tu dois rester dans la boucle : c'est là que l'arbre atterrit, et il y atterrit souvent. Lui passer une instruction (`/compact on va faire la QA de cette zone`) pour que le résumé garde ce dont la phase suivante a besoin.

`/compact` est le **défaut, pas le premier réflexe**. Il est tout en bas parce que les quatre questions au-dessus sont toutes moins chères ou plus précises. Le mode de défaillance, quand on commence ici, c'est une session neuve qui se trompe avec assurance sur une décision que le résumé a aplatie.

## Sources primaires et secondaires

Tout mouvement sauf **Continuer** transforme une **source primaire** en **source secondaire** : la session telle qu'elle s'est déroulée, remplacée par un résumé de celle-ci. Le compromis a toujours la même forme :

| Source                              | Information | Bruit    | Marge de manœuvre |
| ----------------------------------- | ----------- | -------- | ----------------- |
| Primaire (Continuer)                | Complète    | Beaucoup | Faible            |
| Secondaire (`/compact`, `/handoff`) | Lacunaire   | Moins    | Grande            |

C'est pour cela que la question 1 vient en premier. Tu ne paies la perte d'information que lorsque rester coûte plus que ça ne rapporte.

## Ce sont des questions de jugement

Les questions ne sont pas objectives : chacune contient une part de goût, et la même limite peut basculer dans deux sens selon le jour. La valeur est de les poser **dans l'ordre**, à la limite plutôt qu'au milieu du travail.
