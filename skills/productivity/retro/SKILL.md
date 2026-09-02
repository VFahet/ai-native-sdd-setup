---
name: retro
description: "Relit une session de code déjà jouée et en tire des changements concrets de l'environnement de l'agent : navigation, vérifications automatiques, standards de revue, directives inertes, économie d'outils."
argument-hint: "Quelle session relire ?"
disable-model-invocation: true
---

L'utilisateur demande une **rétrospective**. Le travail consiste à proposer des améliorations de l'**environnement** de l'agent, pour que les exécutions suivantes se passent mieux. Pas à juger la session : à changer ce qui l'a rendue difficile.

## Étapes

1. Appeler l'outil Skill avec « writing-for-agents » : c'est le guide de style de tout document destiné à un agent, et la plupart des candidats trouvés ci-dessous se soldent par l'écriture d'un tel document.

2. Lire les **sources primaires** de la session que l'utilisateur désigne. Cela peut vouloir dire fouiller les logs de session présents sur cette machine. Si l'utilisateur ne désigne aucune session, prendre la session courante.

3. Chercher des candidats à l'amélioration dans ces catégories :

   - **Navigation** : l'agent a-t-il trouvé les bons fichiers facilement ? Y a-t-il des dépendances cachées entre fichiers ? Un **pointeur de contexte** rendrait-il le chemin plus court ? _À retenir quand_ la session a passé beaucoup de temps à chercher une information.
   - **Vérifications automatiques** : une vérification automatique aurait-elle attrapé l'erreur commise ? Linting, typage, tests, linters de système de fichiers ? _À retenir quand_ l'agent a commis une erreur qu'un outil aurait pu attraper.
   - **Standards de code** : faut-il donner une nouvelle règle à faire respecter à l'**agent de revue** ? Faut-il en retirer une, ou la clarifier ? _À retenir quand_ l'agent de revue n'a pas attrapé une erreur.
   - **`CLAUDE.md`** : des directives y siègent-elles qui appartiennent plutôt aux standards de code, ou à une vérification automatique ? _À retenir quand_ le fichier est particulièrement gros — dans le dépôt **ou** dans la portée globale de l'utilisateur.
   - **Économie d'outils** : l'agent a-t-il fait des appels d'outils coûteux qui pourraient être raccourcis ? Un outillage maison (CLI, MCP) est-il particulièrement dispendieux en tokens ? _À retenir quand_ un appel d'outil a coûté cher.
   - **Instructions inertes** : chercher, dans les fichiers de directives, les instructions qui ne modifient aucun comportement de l'agent. _À retenir quand_ ces fichiers sont gros et difficiles à manier.
   - **Accès à l'information** : chercher les occasions d'élargir l'accès de l'agent à l'information. Rediriger les logs du serveur de dev vers un fichier lisible, ouvrir un accès en lecture seule à un service tiers. _À retenir quand_ une information cruciale n'était pas à la portée de l'agent.

4. Présenter les candidats à l'utilisateur, par ordre de gravité.

## Référence

### Implémentation et revue

Tout travail passe par deux temps : l'implémentation et la revue. L'agent d'implémentation est celui qui subit la plus forte **pression sur le contexte** — il porte l'exploration, l'écriture du code et le débogage des échecs.

L'agent de revue subit la plus faible : il reçoit un diff, donc aucune exploration. Il n'a le plus souvent ni code à écrire ni bug à traquer.

D'où la règle : c'est à l'agent de revue d'imposer les standards de code, pas à l'agent d'implémentation.

### Les fichiers

Plusieurs fichiers du dépôt sont à ta disposition :

- **`CLAUDE.md` / `AGENTS.md`** : poussés dans la fenêtre de contexte de tout agent qui travaille dans ce dépôt. À utiliser avec une parcimonie extrême, en général pour les seuls **pointeurs de contexte** vers d'autres fichiers.
- **`CODING_STANDARDS.md`** : lu pendant la revue, pas pendant l'implémentation. Au-delà d'un millier de lignes, y placer des pointeurs de contexte vers des dossiers de docs.
- **Les docs** : des fichiers de référence, atteints par un pointeur porté par un autre fichier. Chercher les docs existantes avant d'en écrire une nouvelle.
- **Les skills** : à utiliser pour de la documentation — leur `description` entre dans la fenêtre de contexte de l'agent, elle est donc elle-même un pointeur — ou pour des commandes invoquées par l'utilisateur. Suivre ce que dit `writing-for-agents`.
