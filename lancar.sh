#!/bin/sh
# ---------------------------------------------------------------------------
# lancar.sh — lança o site no domínio definitivo dralexfabricio.com.br
#
# Pré-requisitos (conferir ANTES de rodar):
#   1. Registros DNS criados no registro.br (ver README.md, Opção C):
#        A     @    185.199.108.153 / 185.199.109.153 / 185.199.110.153 / 185.199.111.153
#        AAAA  @    2606:50c0:8000::153 / 8001::153 / 8002::153 / 8003::153
#        CNAME www  allbele.github.io.
#      Conferir: dig +short dralexfabricio.com.br A
#   2. GitHub CLI autenticado na conta allbele:  gh auth status
#   3. Árvore git limpa (tudo o que estiver pendente entraria no commit de lançamento).
#
# Uso, a partir da pasta site/:
#   sh lancar.sh                 lança SEM os elementos de e-mail (a caixa contato@ não existe)
#   COM_EMAIL=1 sh lancar.sh     lança COM e-mail (quando a caixa estiver criada)
#   SECO=1 sh lancar.sh          "modo seco": só edita os arquivos locais; não faz commit,
#                                push nem chamadas à API do GitHub
#
# O que faz, nesta ordem:
#   (a) grava CNAME com dralexfabricio.com.br
#   (b) troca o noindex por "index, follow" em index.html e privacidade.html
#   (c) garante canonical, og:url e "url" do JSON-LD apontando para o domínio
#   (d) COM_EMAIL != 1: põe a classe sem-email no <html> de index.html (esconde os
#       elementos de e-mail) e tira a linha "email" do JSON-LD; COM_EMAIL=1: o inverso
#   (e) commit "Lançamento no domínio" (só se houver mudança) e git push origin main
#   (f) define o domínio no GitHub Pages (cname)
#   (g) tenta ligar "Enforce HTTPS" (até 10 vezes, 60 s entre elas; depende do certificado)
#   (h) diagnóstico: dig e curl
#
# Para desfazer: sh reverter-lancamento.sh
# ---------------------------------------------------------------------------
set -eu

DOMINIO="dralexfabricio.com.br"
REPO="allbele/previa-dralexfabricio"
COM_EMAIL="${COM_EMAIL:-0}"
SECO="${SECO:-0}"
EMAIL_JSONLD='"email": "contato@dralexfabricio.com.br",'

cd "$(dirname "$0")"

# sed portátil (BSD/macOS e GNU): edita no lugar via arquivo temporário
editar() { # editar ARQUIVO EXPRESSÃO-SED...
  _arq="$1"; shift
  sed "$@" "$_arq" > "$_arq.tmp" && mv "$_arq.tmp" "$_arq"
}

if [ "$SECO" != 1 ]; then
  command -v gh >/dev/null 2>&1 || { echo "Instale o GitHub CLI: brew install gh"; exit 1; }
  gh auth status >/dev/null 2>&1 || { echo "Faça login primeiro: gh auth login"; exit 1; }
  if [ -n "$(git status --porcelain)" ]; then
    echo "Há alterações não commitadas. Faça commit (ou descarte) antes de lançar:"
    git status --short
    exit 1
  fi
  if ! dig +short "$DOMINIO" A | grep -q '^185\.199\.'; then
    echo "AVISO: dig não encontrou os registros A do GitHub Pages para $DOMINIO."
    echo "       Crie os registros no registro.br (README, Opção C). Continuando mesmo assim;"
    echo "       o certificado HTTPS só será emitido depois que o DNS propagar."
  fi
fi

# (a) CNAME
printf '%s\n' "$DOMINIO" > CNAME
echo "(a) CNAME gravado"

# (b) noindex -> index, follow (e remove o comentário de prévia)
for p in index.html privacidade.html; do
  editar "$p" \
    -e 's|<meta name="robots" content="noindex, nofollow">|<meta name="robots" content="index, follow">|' \
    -e '/<!-- PRÉVIA:.*-->$/d'
  grep -q '<meta name="robots" content="index, follow">' "$p" || { echo "ERRO: meta robots não encontrada em $p"; exit 1; }
done
echo "(b) noindex removido"

# (c) canonical, og:url e "url" do JSON-LD
garantir_url() { # garantir_url ARQUIVO URL
  _p="$1"; _u="$2"
  if grep -q '<link rel="canonical"' "$_p"; then
    editar "$_p" -e "s|<link rel=\"canonical\" href=\"[^\"]*\">|<link rel=\"canonical\" href=\"$_u\">|"
  else
    editar "$_p" -e "/<meta name=\"description\"/a\\
  <link rel=\"canonical\" href=\"$_u\">"
  fi
  if grep -q 'property="og:url"' "$_p"; then
    editar "$_p" -e "s|<meta property=\"og:url\" content=\"[^\"]*\">|<meta property=\"og:url\" content=\"$_u\">|"
  else
    editar "$_p" -e "/<link rel=\"canonical\"/a\\
  <meta property=\"og:url\" content=\"$_u\">"
  fi
  grep -q "<link rel=\"canonical\" href=\"$_u\">" "$_p" || { echo "ERRO: canonical em $_p"; exit 1; }
  grep -q "<meta property=\"og:url\" content=\"$_u\">" "$_p" || { echo "ERRO: og:url em $_p"; exit 1; }
}
garantir_url index.html "https://$DOMINIO/"
garantir_url privacidade.html "https://$DOMINIO/privacidade.html"
# "url" do JSON-LD (linha própria, indentada, dentro do <script type="application/ld+json">)
editar index.html -e "s|^\([[:space:]]*\"url\": \)\"[^\"]*\"|\1\"https://$DOMINIO/\"|"
echo "(c) canonical, og:url e JSON-LD apontando para https://$DOMINIO/"

# (d) e-mail: classe sem-email no <html> e linha "email" do JSON-LD
editar index.html -e '/^<html /s/ sem-email//' \
  -e "/^[[:space:]]*$EMAIL_JSONLD\$/d"
if [ "$COM_EMAIL" = 1 ]; then
  # recoloca a linha "email" logo após "telephone"
  editar index.html -e "/^\([[:space:]]*\)\"telephone\": .*,\$/{p;s//\\1$EMAIL_JSONLD/;}"
  grep -q "$EMAIL_JSONLD" index.html || { echo "ERRO: linha email do JSON-LD não recolocada"; exit 1; }
  echo "(d) COM e-mail: classe sem-email ausente, JSON-LD com email"
else
  editar index.html -e '/^<html /s/class="\([^"]*\)"/class="\1 sem-email"/'
  grep -q '^<html .*class="[^"]*sem-email"' index.html || { echo "ERRO: classe sem-email não aplicada"; exit 1; }
  echo "(d) SEM e-mail: classe sem-email no <html>, JSON-LD sem email (COM_EMAIL=1 para incluir)"
fi

# sitemap: data do lançamento
if [ -f sitemap.xml ]; then
  editar sitemap.xml -e "s|<lastmod>[^<]*</lastmod>|<lastmod>$(date +%Y-%m-%d)</lastmod>|"
fi

if [ "$SECO" = 1 ]; then
  echo
  echo "Modo seco: arquivos editados, sem commit, push nem API. Diferenças:"
  git status --short
  exit 0
fi

# (e) commit e push
git add -A
if git diff --cached --quiet; then
  echo "(e) nada a commitar"
else
  git commit -q -m "Lançamento no domínio"
  echo "(e) commit feito"
fi
git push origin main
echo "(e) push feito"

# (f) domínio no GitHub Pages
gh api -X PUT "repos/$REPO/pages" -f cname="$DOMINIO" >/dev/null
echo "(f) domínio $DOMINIO definido no GitHub Pages"

# (g) Enforce HTTPS (só funciona depois que o GitHub emite o certificado)
echo "(g) tentando ligar Enforce HTTPS (aguarda o certificado; até 10 tentativas, 60 s cada)..."
tentativa=1; https_ok=0
while [ "$tentativa" -le 10 ]; do
  if gh api -X PUT "repos/$REPO/pages" -F https_enforced=true >/dev/null 2>&1; then
    https_ok=1; break
  fi
  echo "    tentativa $tentativa/10 falhou; esperando 60 s"
  tentativa=$((tentativa + 1))
  [ "$tentativa" -le 10 ] && sleep 60
done
if [ "$https_ok" = 1 ]; then
  echo "(g) Enforce HTTPS ligado"
else
  echo "(g) Enforce HTTPS ainda não pôde ser ligado (certificado pendente). Repita mais tarde:"
  echo "    gh api -X PUT repos/$REPO/pages -F https_enforced=true"
  echo "    (ou marque 'Enforce HTTPS' em Settings > Pages)"
fi

# (h) diagnóstico
echo
echo "(h) diagnóstico"
echo "--- dig +short $DOMINIO A"; dig +short "$DOMINIO" A || true
echo "--- dig +short www.$DOMINIO CNAME"; dig +short "www.$DOMINIO" CNAME || true
echo "--- curl -sI https://$DOMINIO | head -5"; curl -sI "https://$DOMINIO" | head -5 || true
echo "--- estado do Pages"; gh api "repos/$REPO/pages" --jq '{cname: .cname, https_enforced: .https_enforced, status: .status, state: .https_certificate.state}' || true
echo
echo "Pronto. O site deve responder em https://$DOMINIO/ assim que o DNS propagar."
