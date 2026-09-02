# Origine amont

Ce dépôt est un **fork traduit en français** de [mattpocock/skills](https://github.com/mattpocock/skills) (licence MIT).

| | |
|---|---|
| Dépôt source | https://github.com/mattpocock/skills |
| Commit de référence | `6654f6b60cd9d5be8b54c6fafe44346dabeb3b76` |
| Date | 2026-08-24 |
| Version du plugin amont | 1.2.3 |

## Ce qui a été modifié

- **Langue** : le corps des skills et les `description:` du frontmatter sont en français. Les `name:` restent en anglais — ce sont les commandes (`/tdd`, `/to-spec`) et les références croisées entre skills.
- **Claude uniquement** : les fichiers `agents/openai.yaml` (portage Codex) sont supprimés.
- **`setup-matt-pocock-skills` renommé `setup-sdlc`** : le nom d'origine n'a pas de sens dans un fork. Toutes les références croisées ont été mises à jour.
- **Périmètre réduit** : les skills non traduits vivent dans `skills/backlog/` et ne sont pas livrés dans le plugin. Voir [CLAUDE.md](./CLAUDE.md).

## Se resynchroniser avec l'amont

```bash
git clone --depth 1 https://github.com/mattpocock/skills.git /tmp/upstream
cd /tmp/upstream && git fetch --unshallow
git diff 6654f6b6 HEAD -- skills/engineering skills/productivity
```

Reporter les changements pertinents à la main, puis mettre à jour le commit de référence ci-dessus.
