#!/usr/bin/env bash
# Veröffentlicht Startseite + Datenschutzerklärung über GitHub Pages.
# Voraussetzung: GitHub CLI (sudo apt-get install -y gh) und `gh auth login`.
set -euo pipefail

REPO="${1:-acf-legal}"
cd "$(dirname "$0")"

if grep -q "\[Anschrift\]" privacy.html; then
  echo "Bitte zuerst in privacy.html [Anschrift] durch deine Anschrift ersetzen." >&2
  exit 1
fi

USER_NAME="$(gh api user --jq .login)"
[[ -d .git ]] || git init -q -b main
git add index.html privacy.html
git commit -qm "Startseite und Datenschutzerklärung" || true

if ! gh repo view "$USER_NAME/$REPO" >/dev/null 2>&1; then
  gh repo create "$REPO" --public --source . --push
else
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$USER_NAME/$REPO.git"
  git push -u origin main
fi

# GitHub Pages aus dem main-Branch aktivieren (Fehler ignorieren, falls schon aktiv)
gh api -X POST "repos/$USER_NAME/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1 || true

BASE="https://${USER_NAME,,}.github.io/$REPO"
echo
echo "Fertig (Seiten sind nach 1-2 Minuten erreichbar):"
echo "  Startseite:            $BASE/"
echo "  Datenschutzerklärung:  $BASE/privacy.html"
echo "  Autorisierte Domain:   ${USER_NAME,,}.github.io"
