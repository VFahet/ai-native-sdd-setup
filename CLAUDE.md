Les skills sont rangés en buckets sous `skills/` :

- `product/` : cadrage amont — le **quoi** et le **pourquoi**, avant toute décision technique. Écrits ici, absents du dépôt d'origine dont celui-ci est un fork
- `engineering/` : travail de code au quotidien
- `productivity/` : outils de workflow hors code

`product/` est la contribution propre de ce dépôt : le dépôt d'origine est volontairement engineering-only, sa chaîne démarre à `to-spec` et suppose le *quoi* déjà décidé. Un skill n'a sa place dans `product/` que s'il reste vrai indépendamment de la solution retenue ; dès qu'il parle de modules, de seams ou de schéma, il appartient à `engineering/`.

Tout skill de `product/`, `engineering/` ou `productivity/` doit avoir une entrée dans le tableau `skills` de `.claude-plugin/plugin.json` et une ligne dans le `README.md` racine.

## Règles de traduction

Avant de traduire ou d'écrire un skill, lire la section « Langue » de [CONTEXT.md](./CONTEXT.md). Elle liste les termes qui restent en anglais et pourquoi. Un skill dont la prose traduit `seam` ou `tracer bullet` est un bug, pas une préférence de style.

Le `name:` du frontmatter reste toujours en anglais. La `description:` est traduite — c'est elle qui décide du déclenchement, et l'utilisateur formule ses demandes en français.

Ce dépôt cible **Claude Code uniquement**. Pas de fichiers `agents/` pour Codex ou Gemini.

## Après toute rupture de convention

Un changement qui laisse un dépôt **déjà configuré** dans un état que la chaîne ne sait plus lire — un fichier de configuration nouveau, un artefact qui change d'emplacement, un marqueur qui change de forme — demande une entrée dans [skills/engineering/upgrade-sdlc/MIGRATIONS.md](./skills/engineering/upgrade-sdlc/MIGRATIONS.md), écrite **dans le même commit que la rupture**.

Une convention changée sans entrée est une rupture silencieuse : les dépôts déjà configurés continuent de tourner sur l'ancienne, et rien ne le signale. C'est le seul mécanisme qui rende `/upgrade-sdlc` capable de faire son travail.

## Après toute modification des manifestes

```bash
claude plugin validate . --strict
```
