#!/bin/sh
# ---------------------------------------------------------------------------
# publicar.sh — publica a prévia do site no GitHub Pages
#
# Pré-requisitos:
#   - git e GitHub CLI instalados (brew install gh) e autenticado: gh auth login
#   - executar a partir da pasta do site: sh publicar.sh
#
# O que faz:
#   1. inicializa um repositório git local (se ainda não existir) na branch main
#   2. cria o repositório remoto "previa-dralexfabricio" (privado, se possível;
#      GitHub Pages em repositório privado exige plano Pro/Team; se a ativação
#      falhar, o script torna o repositório público e tenta de novo)
#   3. envia os arquivos e ativa o GitHub Pages a partir da branch main (pasta raiz)
#   4. imprime a URL da prévia
#
# Para atualizar depois:  git add -A && git commit -m "ajustes" && git push
# Para o domínio definitivo: ver README.md, seção "Opção C".
# ---------------------------------------------------------------------------
set -eu

REPO="previa-dralexfabricio"
cd "$(dirname "$0")"

command -v gh >/dev/null 2>&1 || { echo "Instale o GitHub CLI: brew install gh"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "Faça login primeiro: gh auth login"; exit 1; }

USUARIO="$(gh api user --jq .login)"

# Não versionar as capturas de verificação
[ -f .gitignore ] || printf '_capturas/\n.DS_Store\n' > .gitignore
# GitHub Pages: desliga o processamento Jekyll (serve os arquivos como estão)
[ -f .nojekyll ] || : > .nojekyll

if [ ! -d .git ]; then
  git init -b main
fi
git add -A
git diff --cached --quiet || git commit -m "Prévia do site institucional"

if ! gh repo view "$USUARIO/$REPO" >/dev/null 2>&1; then
  gh repo create "$REPO" --private --source=. --remote=origin --push \
    --description "Prévia do site dralexfabricio.com.br"
else
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$USUARIO/$REPO.git"
  git push -u origin main
fi

ativar_pages() {
  gh api -X POST "repos/$USUARIO/$REPO/pages" \
    -f 'source[branch]=main' -f 'source[path]=/' >/dev/null 2>&1 \
  || gh api -X PUT "repos/$USUARIO/$REPO/pages" \
    -f 'source[branch]=main' -f 'source[path]=/' >/dev/null 2>&1
}

if ! ativar_pages; then
  echo "Pages não pôde ser ativado em repositório privado (plano gratuito). Tornando público..."
  gh repo edit "$USUARIO/$REPO" --visibility public --accept-visibility-change-consequences
  ativar_pages || { echo "Falha ao ativar o GitHub Pages. Ative manualmente em Settings > Pages."; exit 1; }
fi

echo
echo "Publicado. A prévia ficará disponível em alguns minutos em:"
echo "  https://$USUARIO.github.io/$REPO/"
echo "Lembre-se: as páginas têm <meta name=\"robots\" content=\"noindex\"> até o lançamento."
