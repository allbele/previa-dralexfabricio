#!/bin/sh
# ---------------------------------------------------------------------------
# reverter-lancamento.sh — desfaz o lançamento feito por lancar.sh
#
# O que faz:
#   - volta o <meta name="robots" content="noindex, nofollow"> nas duas páginas
#   - remove o arquivo CNAME
#   - tira a classe sem-email do <html> e recoloca a linha "email" no JSON-LD
#     (estado da prévia)
#   - remove o domínio do GitHub Pages (cname = null)
#
# NÃO faz commit nem push: confira com `git status`/`git diff` e depois
#   git add -A && git commit -m "Reverte lançamento" && git push origin main
#
# Uso, a partir da pasta site/:   sh reverter-lancamento.sh
#   SECO=1 sh reverter-lancamento.sh   só edita os arquivos, sem chamar a API
# ---------------------------------------------------------------------------
set -eu

REPO="allbele/previa-dralexfabricio"
SECO="${SECO:-0}"
EMAIL_JSONLD='"email": "contato@dralexfabricio.com.br",'

cd "$(dirname "$0")"

editar() { # editar ARQUIVO EXPRESSÃO-SED...
  _arq="$1"; shift
  sed "$@" "$_arq" > "$_arq.tmp" && mv "$_arq.tmp" "$_arq"
}

# noindex de volta
for p in index.html privacidade.html; do
  editar "$p" -e 's|<meta name="robots" content="index, follow">|<meta name="robots" content="noindex, nofollow">|'
  grep -q 'content="noindex, nofollow"' "$p" || { echo "ERRO: meta robots não encontrada em $p"; exit 1; }
done
echo "noindex restaurado"

# CNAME
rm -f CNAME
echo "CNAME removido"

# e-mail: estado da prévia (sem classe, com a linha no JSON-LD)
editar index.html -e '/^<html /s/ sem-email//'
if ! grep -q "$EMAIL_JSONLD" index.html; then
  editar index.html -e "/^\([[:space:]]*\)\"telephone\": .*,\$/{p;s//\\1$EMAIL_JSONLD/;}"
fi
grep -q "$EMAIL_JSONLD" index.html || { echo "ERRO: linha email do JSON-LD não recolocada"; exit 1; }
echo "e-mail: classe sem-email removida, JSON-LD com email"

if [ "$SECO" = 1 ]; then
  echo; echo "Modo seco: sem chamada à API."; git status --short; exit 0
fi

command -v gh >/dev/null 2>&1 || { echo "Instale o GitHub CLI: brew install gh"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "Faça login primeiro: gh auth login"; exit 1; }
printf '{"cname": null}' | gh api -X PUT "repos/$REPO/pages" --input - >/dev/null
echo "domínio removido do GitHub Pages"

echo
echo "Arquivos revertidos (sem commit). Para publicar a reversão:"
echo "  git add -A && git commit -m \"Reverte lançamento\" && git push origin main"
git status --short
