---
name: handoff
description: Condense la conversation en cours en un document de passation qu'un autre agent pourra reprendre.
argument-hint: "À quoi servira la prochaine session ?"
disable-model-invocation: true
---

Rédiger un document de passation qui résume la conversation en cours, afin qu'un nouvel agent puisse poursuivre le travail. L'enregistrer dans le répertoire temporaire du système d'exploitation de l'utilisateur — pas dans l'espace de travail courant.

Inclure dans le document une section « skills suggérés », en nommant les skills que le prochain agent devra invoquer via l'outil Skill.

Ne pas dupliquer le contenu déjà consigné dans d'autres artefacts (specs, plans, ADR, issues, commits, diffs). Les référencer plutôt par chemin ou par URL.

Caviarder toute information sensible, comme les clés d'API, les mots de passe ou les données à caractère personnel.

Si l'utilisateur a passé des arguments, les traiter comme une description de ce sur quoi la prochaine session se concentrera, et adapter le document en conséquence.
