---
name: resolving-merge-conflicts
description: "À utiliser quand tu dois résoudre un conflit de merge/rebase git en cours."
---

1. **Voir l'état actuel** du merge/rebase. Examiner l'historique git, et les fichiers en conflit.

2. **Trouver les sources primaires** de chaque conflit. Comprendre en profondeur pourquoi chaque changement a été fait, et quelle était l'intention d'origine. Lire les messages de commit, consulter les PR, consulter les issues/tickets d'origine.

3. **Résoudre chaque hunk.** Préserver les deux intentions quand c'est possible. Quand elles sont incompatibles, choisir celle qui correspond à l'objectif annoncé du merge et noter le compromis. Ne **pas** inventer de nouveau comportement. Toujours résoudre ; ne jamais faire `--abort`.

4. Découvrir les **vérifications automatisées** du projet et les lancer, typiquement le typecheck, puis les tests, puis le format. Corriger tout ce que le merge a cassé.

5. **Terminer le merge/rebase.** Tout mettre en staging et committer. En cas de rebase, poursuivre le processus de rebase jusqu'à ce que tous les commits soient rebasés.
