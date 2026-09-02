# Garde-fous git

Ce qui accompagne le hook `block-trunk-writes.sh` dans `.claude/`. À la différence des autres gabarits de ce dossier, rien d'ici ne se copie sous `docs/agents/` : ce sont des entrées à **fusionner** dans `.claude/settings.json`, puis deux tests à lancer.

## Entrées de `.claude/settings.json`

```json
{
  "permissions": {
    "deny": [
      "Bash(gh pr merge:*)",
      "Bash(git push --force:*)",
      "Bash(git push -f:*)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/block-trunk-writes.sh\""
          }
        ]
      }
    ]
  }
}
```

Les règles `deny` ne couvrent que les formes catégoriques, et par préfixe : `git push origin main --force` leur échappe. C'est le hook qui rattrape le reste, en regardant la cible réelle et la branche courante. Les deux couches sont volontaires ; ne pas en retirer une au motif que l'autre existe. Le préfixe `bash ` dans la commande du hook est délibéré lui aussi : il rend le script exécutable là où le bit `+x` ne veut rien dire.

## Vérifier que ça refuse vraiment

Un garde-fou qu'on n'a pas vu bloquer n'est pas un garde-fou :

```bash
echo '{"tool_input":{"command":"gh pr merge 1"}}' | bash .claude/hooks/block-trunk-writes.sh; echo "code=$?"
echo '{"tool_input":{"command":"git status"}}'    | bash .claude/hooks/block-trunk-writes.sh; echo "code=$?"
```

Le premier doit sortir en `code=2` avec un message `BLOQUÉ`. Le second en `code=0`, sans rien afficher : c'est le test qui prouve que le hook laisse passer le travail ordinaire. Si l'un des deux ne fait pas ce qui est attendu, le dire à l'utilisateur et **ne pas** annoncer que la protection est en place.
