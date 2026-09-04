#!/usr/bin/env bash
#
# Un wizard guide un humain, pas à pas, à travers une procédure manuelle.
# Généré par le skill /wizard.
#
# Tout ce qui est au-dessus du marqueur "STAGES" est la bibliothèque du wizard :
# ne pas l'éditer à la main. Écrire les étapes sous le marqueur.

set -euo pipefail

# ──────────────────────────────────────────────────────────────────────────
# Bibliothèque du wizard : une UX soignée et constante, identique partout.
# ──────────────────────────────────────────────────────────────────────────

if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
  BOLD=$(tput bold); DIM=$(tput dim); RESET=$(tput sgr0)
  BLUE=$(tput setaf 4); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3); RED=$(tput setaf 1)
else
  BOLD=""; DIM=""; RESET=""; BLUE=""; GREEN=""; YELLOW=""; RED=""
fi

# L'auteur règle ceci en tête de la section des étapes.
TOTAL_STAGES=0

_STAGE_INDEX=0
ENV_FILE="${ENV_FILE:-.env}"
WRITTEN_ENV=()    # KEYs écrites dans ENV_FILE pendant cette exécution
WRITTEN_SECRET=() # NAMEs de secrets posés pendant cette exécution
SKIPPED=()        # ce qu'on n'a pas pu faire (gh absent, par exemple)

# _clear efface le terminal pour ne laisser que l'étape courante à l'écran.
# Sans effet quand la sortie n'est pas un terminal : les logs redirigés
# restent lisibles.
_clear() {
  [[ -t 1 ]] || return 0
  if command -v tput >/dev/null 2>&1; then tput clear; else printf '\033[2J\033[3J\033[H'; fi
}

# banner "Titre" affiche le cadre d'ouverture : ce que fait ce wizard.
banner() {
  _clear
  printf '\n%s%s  %s%s\n' "$BOLD" "$BLUE" "$1" "$RESET"
  printf '%s  %s étapes%s\n\n' "$DIM" "$TOTAL_STAGES" "$RESET"
  printf '%s  Tu pilotes le navigateur ; ce wizard te dit exactement quoi faire et\n' "$DIM"
  printf '  récupère les valeurs que tu recopies. Tu peux arrêter à tout moment avec\n'
  printf '  Ctrl-C et relancer plus tard : il retient les valeurs déjà enregistrées.%s\n' "$RESET"
  pause "Prêt à commencer ?"
}

# stage "Nom" efface l\'écran, annonce une étape et montre la progression.
# L'effacement ne laisse que l'étape courante à l'écran.
stage() {
  _clear
  _STAGE_INDEX=$((_STAGE_INDEX + 1))
  printf '\n%s%s▸ Étape %s/%s · %s%s\n' \
    "$BOLD" "$BLUE" "$_STAGE_INDEX" "$TOTAL_STAGES" "$1" "$RESET"
}

# say "..." imprime une ligne d\'instruction simple.
say()  { printf '  %s\n' "$1"; }
# step "..." est une action que l\'humain effectue dans le navigateur.
step() { printf '  %s•%s %s\n' "$BLUE" "$RESET" "$1"; }
note() { printf '  %s%s%s\n' "$DIM" "$1" "$RESET"; }
warn() { printf '  %s⚠ %s%s\n' "$YELLOW" "$1" "$RESET"; }

# open_url URL l'ouvre dans le navigateur de l'humain, multi-plateforme, WSL compris.
open_url() {
  local url="$1"
  printf '  %s↗ ouverture%s %s\n' "$GREEN" "$RESET" "$url"
  { if   command -v wslview     >/dev/null 2>&1; then wslview "$url"
    elif command -v explorer.exe >/dev/null 2>&1; then explorer.exe "$url"
    elif command -v xdg-open    >/dev/null 2>&1; then xdg-open "$url"
    elif command -v open        >/dev/null 2>&1; then open "$url"
    else warn "impossible d'ouvrir un navigateur ; ouvre l'adresse à la main : $url"; fi
  } >/dev/null 2>&1 || warn "impossible d'ouvrir un navigateur ; ouvre l'adresse à la main : $url"
}

# pause "msg" attend que l'humain confirme avoir fait la partie manuelle.
pause() {
  printf '  %s%s%s ' "$DIM" "${1:-Entrée pour continuer}" "$RESET"
  read -r _ || true
}

# confirm "question" est une porte o/N ; renvoie un succès sur oui.
confirm() {
  local reply=""
  printf '  %s? %s [o/N] ' "$YELLOW" "$1"
  read -r reply || true
  [[ "$reply" =~ ^[OoYy] ]]
}

# _existing KEY : valeur actuelle de KEY dans ENV_FILE, s'il y en a une.
_existing() {
  [[ -f "$ENV_FILE" ]] || return 1
  local line; line=$(grep -E "^${1}=" "$ENV_FILE" | tail -n1) || return 1
  printf '%s' "${line#*=}"
}

# ask KEY "Invite" lit une valeur dans $KEY. Propose la valeur déjà présente
# dans .env comme défaut lors d'une relance (Entrée la conserve). Saisie visible.
ask() {
  local key="$1" prompt="$2" current input
  current=$(_existing "$key" || true)
  if [[ -n "$current" ]]; then
    printf '  %s%s%s %s[Entrée conserve la valeur]%s ' "$BOLD" "$prompt" "$RESET" "$DIM" "$RESET"
  else
    printf '  %s%s%s ' "$BOLD" "$prompt" "$RESET"
  fi
  read -r input || true
  [[ -z "$input" && -n "$current" ]] && input="$current"
  printf -v "$key" '%s' "$input"
}

# ask_secret KEY "Invite" est comme ask, mais la saisie est masquée.
ask_secret() {
  local key="$1" prompt="$2" current input
  current=$(_existing "$key" || true)
  if [[ -n "$current" ]]; then
    printf '  %s%s%s %s[Entrée conserve la valeur]%s ' "$BOLD" "$prompt" "$RESET" "$DIM" "$RESET"
  else
    printf '  %s%s%s ' "$BOLD" "$prompt" "$RESET"
  fi
  read -rs input || true
  printf '\n'
  [[ -z "$input" && -n "$current" ]] && input="$current"
  printf -v "$key" '%s' "$input"
}

# write_env KEY VALUE insère ou remplace KEY=VALUE dans ENV_FILE (le crée au
# besoin, remplace la ligne existante). Idempotent.
write_env() {
  local key="$1" value="$2" tmp
  touch "$ENV_FILE"
  tmp=$(mktemp)
  grep -vE "^${key}=" "$ENV_FILE" > "$tmp" || true
  printf '%s=%s\n' "$key" "$value" >> "$tmp"
  mv "$tmp" "$ENV_FILE"
  WRITTEN_ENV+=("$key")
  printf '  %s✓ écrit%s %s → %s\n' "$GREEN" "$RESET" "$key" "$ENV_FILE"
}

# set_secret NAME VALUE pose un secret de dépôt GitHub Actions via gh. Se rabat
# sur un avertissement (et l'enregistre) si gh est absent ou non authentifié.
set_secret() {
  local name="$1" value="$2"
  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    if printf '%s' "$value" | gh secret set "$name" >/dev/null 2>&1; then
      WRITTEN_SECRET+=("$name")
      printf '  %s✓ posé%s secret GitHub %s\n' "$GREEN" "$RESET" "$name"
      return
    fi
  fi
  SKIPPED+=("secret GitHub $name (à poser à la main : gh secret set $name)")
  warn "secret GitHub $name sauté : gh n'est pas prêt ; à poser plus tard"
}

# set_var NAME VALUE pose une variable de dépôt GitHub Actions (non secrète).
set_var() {
  local name="$1" value="$2"
  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    if gh variable set "$name" --body "$value" >/dev/null 2>&1; then
      printf '  %s✓ posé%s variable GitHub %s\n' "$GREEN" "$RESET" "$name"
      return
    fi
  fi
  SKIPPED+=("variable GitHub $name")
  warn "variable GitHub $name sautée : gh n'est pas prêt ; à poser plus tard"
}

# finish efface, puis affiche le résumé de clôture de tout ce qui a été configuré.
finish() {
  _clear
  printf '\n%s%s  ✓ Installation terminée%s\n' "$BOLD" "$GREEN" "$RESET"
  (( ${#WRITTEN_ENV[@]} ))    && note "${#WRITTEN_ENV[@]} valeur(s) écrite(s) dans $ENV_FILE : ${WRITTEN_ENV[*]}"
  (( ${#WRITTEN_SECRET[@]} )) && note "${#WRITTEN_SECRET[@]} secret(s) GitHub posé(s) : ${WRITTEN_SECRET[*]}"
  if (( ${#SKIPPED[@]} )); then
    printf '\n'; warn "reste à faire à la main :"
    for s in "${SKIPPED[@]}"; do note "  - $s"; done
  fi
  printf '\n'
}

# ──────────────────────────────────────────────────────────────────────────
# STAGES : c'est cette section qu'on écrit. Un stage() par étape que
# l'humain traverse. Remplacer l'exemple ci-dessous, et régler TOTAL_STAGES.
# ──────────────────────────────────────────────────────────────────────────

TOTAL_STAGES=1

banner "Installation Stripe"

# ── Étape d'exemple : à remplacer par les vraies étapes ─────────────────
stage "Stripe : clés d'API"
say "On récupère tes clés de test Stripe et on les range pour le dev local et la CI."
open_url "https://dashboard.stripe.com/test/apikeys"
step "Sur la page API keys, copier la « Publishable key » (elle commence par pk_test_)."
ask STRIPE_PUBLISHABLE_KEY "Colle la clé publique :"
step "Cliquer sur « Reveal test key » sur la ligne « Secret key », puis la copier."
ask_secret STRIPE_SECRET_KEY "Colle la clé secrète :"
write_env STRIPE_PUBLISHABLE_KEY "$STRIPE_PUBLISHABLE_KEY"
write_env STRIPE_SECRET_KEY "$STRIPE_SECRET_KEY"
set_secret STRIPE_SECRET_KEY "$STRIPE_SECRET_KEY"   # celle-ci est nécessaire à la CI
# ──────────────────────────────────────────────────────────────────────────

finish
