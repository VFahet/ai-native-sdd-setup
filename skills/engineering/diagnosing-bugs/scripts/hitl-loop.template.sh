#!/usr/bin/env bash
# Boucle de reproduction human-in-the-loop.
# Copier ce fichier, éditer les étapes ci-dessous, puis le lancer.
# L'agent lance le script ; l'utilisateur suit les invites dans son terminal.
#
# Usage :
#   bash hitl-loop.template.sh
#
# Deux fonctions utilitaires :
#   step "<instruction>"          → affiche l'instruction, attend Entrée
#   capture VAR "<question>"      → affiche la question, lit la réponse dans VAR
#
# À la fin, les valeurs capturées sont affichées en KEY=VALUE pour que l'agent les parse.
#
# `capture` réaffiche sa valeur dans le terminal, où l'agent la lit :
# capturer donc des observations, et laisser la connexion à l'utilisateur comme un `step`.

set -euo pipefail

step() {
  printf '\n>>> %s\n' "$1"
  read -r -p "    [Entrée quand c'est fait] " _
}

capture() {
  local var="$1" question="$2" answer
  printf '\n>>> %s\n' "$question"
  read -r -p "    > " answer
  printf -v "$var" '%s' "$answer"
}

# --- éditer ci-dessous --------------------------------------------------

step "Ouvrir l'application sur http://localhost:3000 et se connecter."

capture ERRORED "Cliquer sur le bouton 'Export'. A-t-il levé une erreur ? (y/n)"

capture ERROR_MSG "Coller le message d'erreur (ou 'none') :"

# --- éditer ci-dessus ---------------------------------------------------

printf '\n--- Capturé ---\n'
printf 'ERRORED=%s\n' "$ERRORED"
printf 'ERROR_MSG=%s\n' "$ERROR_MSG"
