#!/usr/bin/env bash
# Garde-fou trunk — hook PreToolUse sur Bash, installé par /setup-sdlc sur demande.
#
# Refuse ce qui ferait atterrir du code sur le trunk. C'est un durcissement opt-in :
# par défaut la règle vit dans docs/agents/git-workflow.md et l'agent merge quand
# l'utilisateur le demande. Une fois ce hook posé, le refus vaut aussi contre lui.
# Volontairement DIRECTIONNEL : `git merge` et `git push` ne sont pas interdits
# en soi, ils le sont vers le trunk. Un blocage catégorique casserait
# /resolving-merge-conflicts et la synchronisation d'une branche avec le trunk.
set -uo pipefail

# /setup-sdlc remplace cette valeur par la branche de référence du dépôt.
TRUNK="${SDLC_TRUNK_BRANCH:-main}"

INPUT=$(cat)

# Extraire la commande. jq et python donnent la valeur exacte ; à défaut, on
# retombe sur la charge brute, échappements aplatis — approximatif mais
# conservateur : au pire un faux positif, jamais un trou.
extract() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' && return
  fi
  for py in python3 python; do
    if command -v "$py" >/dev/null 2>&1; then
      printf '%s' "$INPUT" | "$py" -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' && return
    fi
  done
  printf '%s' "$INPUT" | sed -e 's/.*"command" *: *"//' -e 's/\\[nrt]/ /g' -e 's/\\"/ /g'
}

CMD=$(extract 2>/dev/null)
[ -z "$CMD" ] && exit 0

# Normaliser les espaces : les motifs ne doivent pas dépendre de la mise en forme.
CMD=$(printf '%s' "$CMD" | tr '\n\t' '  ' | tr -s ' ')

CURRENT=$(git -C "${CLAUDE_PROJECT_DIR:-.}" rev-parse --abbrev-ref HEAD 2>/dev/null || true)

deny() {
  echo "BLOQUÉ : $1" >&2
  echo "Règle : docs/agents/git-workflow.md — rien n'atterrit sur \`$TRUNK\` sans décision humaine." >&2
  echo "Ouvre une PR (\`gh pr create --base $TRUNK\`) et arrête-toi là." >&2
  exit 2
}

has() { printf '%s' "$CMD" | grep -Eq "$1"; }

# 1. Fusionner une PR — catégorique, quelle que soit la branche.
has '(^|[;&|(] *)gh +pr +merge($| )' \
  && deny "\`gh pr merge\` fusionne la PR. C'est la décision que l'humain se réserve."

# 2. Force-push — catégorique, où que ce soit.
if has 'git +push( |$)'; then
  has 'git +push( .*)?( --force| --force-with-lease| -f)( |$)' \
    && deny "un force-push réécrit un historique déjà publié."
  has 'git +push .*(^| )\+[A-Za-z0-9._/-]+:' \
    && deny "la refspec commence par \`+\`, c'est un force-push déguisé."

  # 3. Push dont la cible est le trunk.
  has "git +push .*(^| |:)(HEAD:)?${TRUNK}( |$)" \
    && deny "ce push vise \`$TRUNK\` directement."
  [ "$CURRENT" = "$TRUNK" ] \
    && deny "\`HEAD\` est sur \`$TRUNK\` : un push sans refspec y pousserait."
fi

# 4. Intégrer quelque chose alors que HEAD est sur le trunk.
if [ "$CURRENT" = "$TRUNK" ] && has 'git +(merge|rebase|cherry-pick)( |$)'; then
  has 'git +(merge|rebase|cherry-pick) .*(--abort|--continue|--quit|--skip)( |$)' \
    || deny "\`HEAD\` est sur \`$TRUNK\` : cette intégration y ferait atterrir du code."
fi

# 5. Chaînage : basculer sur le trunk puis intégrer, dans la même commande.
has "git +(checkout|switch) +(-[A-Za-z]+ +)*${TRUNK}( |$)" \
  && has 'git +(merge|rebase|cherry-pick|push)( |$)' \
  && deny "cette commande bascule sur \`$TRUNK\` puis y intègre du code."

# 6. Déplacer ou supprimer la référence du trunk.
has "git +branch +(-[A-Za-z]+ +)*(-f|--force|-M|-D|-d) .*\b${TRUNK}( |$)" \
  && deny "cette commande déplace ou supprime la branche \`$TRUNK\`."
has "git +push .*(^| )(--delete|:)${TRUNK}( |$)" \
  && deny "cette commande supprime \`$TRUNK\` sur le remote."

exit 0
