# Site institucional · Dr. Alex Fabrício de Oliveira

SEO: ver `SEO.md` (o que está feito na página, o que depende do Mateus, segunda fase).

Site estático (HTML + CSS + JS mínimo), sem framework e sem etapa de build. Basta copiar os arquivos para qualquer servidor web.

```
site/
├── index.html          página única (hero, apresentação, modo de trabalho, formação, atendimento, contato)
├── privacidade.html    aviso de privacidade (LGPD)
├── consulta/index.html página de destino dos anúncios do Google (uma ação só: WhatsApp; CSS próprio inline; ?cidade=slug troca o título; data-conv para a tag de conversão)
├── css/estilo.css      estilos
├── assets/
│   ├── vitruviano-mosaico.png      identidade do médico: homem vitruviano em mosaico de placas douradas, como no cartão de visita (1415x1783, fundo transparente)
│   ├── vitruviano-mosaico-720.png  mesma imagem, 571x720, usada no hero e no retrato provisório
│   ├── vitruviano-cartao.jpg       pergaminho original extraído do PDF do cartão (fonte do mosaico; não é usado no site)
│   ├── vitruviano.svg              line-art geométrico (favicon, marca do cabeçalho e do rodapé)
│   └── og.png                      imagem para redes sociais (1200x630); fonte em _capturas/og-fonte.html
├── favicon.svg
├── robots.txt, sitemap.xml
├── publicar.sh         publica a prévia no GitHub Pages (ver abaixo)
├── lancar.sh           lança no domínio dralexfabricio.com.br (Opção C); reverter-lancamento.sh desfaz
└── _capturas/          screenshots de verificação e script capturar.mjs (não precisa publicar)
```

## Identidade visual
A peça que o médico reconhece como sua é o homem vitruviano em mosaico, do cartão de visita (fundo preto, placas douradas inclinadas) e do cabeçalho do receituário (mosaico pequeno dentro de um círculo). O site usa:

- no **hero**, uma placa de pergaminho claro (`.hero-placa`, `--pergaminho`) com o traço do vitruviano em dourado escuro.
  **Desde 27/10 nenhum fundo do site é preto**: a placa é clara e as faixas escuras (lema, contato, rodapé) usam o verde
  profundo `--placa: #27392f`. O favicon e a `og.png` seguem a mesma regra;
- no **retrato provisório**, o mosaico dentro de um círculo fino (`.retrato-selo`), como no receituário; sai quando entrar a foto;
- no cabeçalho, rodapé e favicon, o line-art `vitruviano.svg`, mais discreto.

Como regenerar o mosaico, se preciso: `pdfimages -png "00000018-Cartão - Alex F. de Oliveira.pdf" x` extrai o pergaminho (285x402); o mosaico é 4 colunas x 8 linhas de placas com cantos arredondados, vão de ~2 % da largura, rotação de 11° no sentido horário, sobre fundo transparente.

## 1. Campos a preencher (`data-fill`)

Os campos que dependiam do médico continuam marcados no HTML com o atributo `data-fill`, para facilitar trocas futuras. Em 02/09/2026 foram preenchidos com os dados confirmados por ele na mensagem de 30/08/2026. Procure por `data-fill="..."` e troque o texto visível (e o `href`, quando houver).

| `data-fill` | Onde | Situação em 02/09/2026 |
|---|---|---|
| `rqe` | hero, formação, rodapé (index e privacidade) | **Preenchido:** `RQE 27461` (confirmado no CRM-MG em 28/08/2026). Se for preciso remover, leia a nota abaixo. |
| `whatsapp` | botão "Agendar pelo WhatsApp" | **Preenchido:** `https://wa.me/5532998462999?text=...` (secretária). |
| `telefone` | lista de contato | **Preenchido:** `(32) 99846-2999`, com link `tel:+5532998462999` e a nota "Secretaria, para agendamento". Também no `telephone` do JSON-LD. |
| `endereco` | lista de contato e privacidade | **Preenchido:** Rua Coronel Júlio Soares, 151-B, Centro, Ubá/MG, CEP 36500-051, em frente à Unimed-Ubá. O médico informou o CEP incompleto ("36.500-05"); o 36500-051 foi conferido em bases públicas de CEP (ruacep, TeleListas, ProCep, CEPBrasil) e coincide com o início informado. Vale confirmar com ele. Também em `streetAddress`, `addressLocality` e `postalCode` do JSON-LD, no `<title>`, na meta description e no og:description. |
| `horario` | lista de contato | **Preenchido, a confirmar:** `Segunda a sexta, das 7h às 17h`. O médico disse "a confirmar"; se mudar, trocar aqui e em `openingHoursSpecification` no JSON-LD. |
| `email` | lista de contato | **Preenchido:** `contato@dralexfabricio.com.br`, confirmado pelo médico (também nos `mailto:` do rodapé, da privacidade e no JSON-LD). |
| `retrato` | bloco do retrato | **Pendente.** O médico pediu que Mateus escolha três ou quatro fotos de estúdio do Drive. Ver "Foto do médico". |
| `teleconsulta` | lead de "Atendimento" e item "Teleconsulta" no contato | **Confirmado:** o médico faz teleconsulta. Itens mantidos e `Teleconsulta psiquiátrica` acrescentada em `availableService` no JSON-LD. |
| `docencia` | apresentação e formação | **Preenchido:** UNIFAGOC (Ubá), docência atual desde 2017. |
| `data-privacidade` | privacidade.html | `setembro de 2026`. Atualizar a cada revisão. |

Outras informações confirmadas em 30/08/2026 e já aplicadas: público de adultos, adolescentes e idosos (crianças são encaminhadas a especialistas em infância e adolescência); atendimento somente particular, sem convênios, consulta de uma hora; formação completa (graduação UFJF 2002, residência UFRJ 2005, mestrado Unesp 2010, docência FAMEMA, UFV e UNIFAGOC, pós-graduação IESPE e Hospital Albert Sabin, consultório desde 2006), resumida na seção "Formação e docência".

Ainda pendente: foto do médico (`retrato`), confirmação do horário e do CEP. A `og:image` (`assets/og.png`, 1200x630) pode ser trocada por uma foto quando houver.

### Foto do médico
Salve a foto como `assets/retrato.jpg` (proporção 4:5, ex.: 800x1000) e, dentro de `<figure class="retrato">`, substitua os dois elementos (`div.retrato-selo` e `figcaption`) por:

```html
<img src="assets/retrato.jpg" alt="Dr. Alex Fabrício de Oliveira" width="800" height="1000">
```

### Nota sobre o RQE
A Resolução CFM 2.336/2023 só permite anunciar-se como "Psiquiatra" com o RQE da especialidade. Se ele não existir: trocar "Psiquiatra"/"Psiquiatria" por "Médico" com "atuação em saúde mental" em `<title>`, meta description, hero (`titulo-cargo`), JSON-LD (`medicalSpecialty`) e rodapé; remover os `<span data-fill="rqe">`. Nunca incluir preços, promessas de resultado, "melhor/único", depoimentos de pacientes ou antes/depois.

## 2. Remover o `noindex` no lançamento
Enquanto for prévia, as duas páginas têm:

```html
<meta name="robots" content="noindex, nofollow">
```

O `lancar.sh` (seção 3, Opção C) troca essa linha por `index, follow` em `index.html` e `privacidade.html`, confere `<link rel="canonical">` e `og:url` e publica. Para fazer à mão: apague a linha nos dois arquivos e confira que canonical e `og:url` apontam para `https://dralexfabricio.com.br/`.

### E-mail (`sem-email`)
A caixa `contato@dralexfabricio.com.br` ainda não existe. Os elementos de e-mail (botão "Escrever e-mail", item da lista de contato, link do rodapé) têm `class="so-com-email"` ou `data-fill="email"`; a regra `html.sem-email ...` em `css/estilo.css` os esconde quando o `<html>` de `index.html` tem a classe `sem-email`. O `lancar.sh` põe essa classe (e tira a linha `"email"` do JSON-LD) a menos que seja executado com `COM_EMAIL=1`. Os `mailto:` do texto de `privacidade.html` não são afetados: trocar à mão se a caixa não for criada.

## 3. Publicar

### Opção A: GitHub Pages (prévia)
Requer `gh` autenticado (`gh auth login`). Leia e execute `publicar.sh` a partir desta pasta:

```sh
sh publicar.sh
```

Ele cria o repositório `previa-dralexfabricio` (privado se o plano permitir Pages em repositório privado; senão público), envia os arquivos e ativa o Pages na branch `main`. A URL fica em `https://<usuario>.github.io/previa-dralexfabricio/`. Para atualizar depois: `git add -A && git commit -m "ajustes" && git push`.

### Opção B: qualquer servidor estático
Copie o conteúdo desta pasta (exceto `_capturas/` e `publicar.sh`) para a raiz do servidor: Netlify, Vercel, Cloudflare Pages, HostGator, Hostinger, um bucket S3 etc. Não há dependências nem build. Garanta HTTPS.

### Opção C: domínio definitivo (registro.br → GitHub Pages)
Com os registros DNS criados (passo 2 abaixo) e `gh auth status` ok, o lançamento é um comando, a partir desta pasta:

```sh
sh lancar.sh                 # sem os elementos de e-mail (caixa contato@ ainda não existe)
COM_EMAIL=1 sh lancar.sh     # com e-mail, quando a caixa estiver criada
SECO=1 sh lancar.sh          # modo seco: só edita os arquivos, sem commit/push/API
```

Ele grava o `CNAME`, remove o `noindex`, confere canonical/og:url, faz commit e push, define o domínio no Pages, tenta ligar "Enforce HTTPS" (repetir depois se o certificado ainda não tiver sido emitido) e imprime um diagnóstico (`dig`, `curl`). Para desfazer: `sh reverter-lancamento.sh` (edita os arquivos e tira o domínio do Pages; commit e push ficam por sua conta). `robots.txt` e `sitemap.xml` já apontam para o domínio.

Passo a passo manual, se preferir:

1. Crie um arquivo `CNAME` na raiz do repositório com o conteúdo `dralexfabricio.com.br` (ou em Settings → Pages → Custom domain).
2. No painel do registro.br, em "Editar zona" (DNS), crie:

   | Tipo | Nome | Valor |
   |---|---|---|
   | A | `@` (vazio) | `185.199.108.153` |
   | A | `@` | `185.199.109.153` |
   | A | `@` | `185.199.110.153` |
   | A | `@` | `185.199.111.153` |
   | AAAA | `@` | `2606:50c0:8000::153`, `2606:50c0:8001::153`, `2606:50c0:8002::153`, `2606:50c0:8003::153` |
   | CNAME | `www` | `allbele.github.io.` |

3. Espere a propagação (até algumas horas), marque "Enforce HTTPS" nas configurações do Pages.
4. Se for usar outro provedor de hospedagem, siga os registros que ele indicar em vez destes.

Se o e-mail `contato@dralexfabricio.com.br` for hospedado à parte (Zoho, Google Workspace etc.), adicione também os registros MX/TXT do provedor de e-mail na mesma zona.

## 4. Verificar
Abra `index.html` no navegador ou gere as capturas com Chrome headless (Node 22+, sem dependências), a partir desta pasta:

```sh
node _capturas/capturar.mjs
```

Gera em `_capturas/`: `desktop-full.png` (1440x900, página inteira), `desktop-hero.png`, `mobile-full.png` (390x844, página inteira), `mobile-hero.png`, `mobile-contato.png`, `privacidade-desktop.png` e `privacidade-mobile.png`.

Observação: aberto por `file://`, o Chrome não aplica a `mask-image` do hero (a placa sai vazia). Para ver o vitruviano nas capturas, sirva a pasta por HTTP (`python3 -m http.server 8765`) e capture `http://127.0.0.1:8765/index.html`; no GitHub Pages renderiza normalmente.

Captura simples de uma tela, sem o script:

```sh
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --screenshot=_capturas/desktop-hero.png --window-size=1440,900 "file://$PWD/index.html"
```

## 5. Prévia em PDF
O PDF "05 - Prévia do site" do pacote é o próprio `index.html` impresso pelo Chrome (as regras `@media print` de `css/estilo.css` fazem a paginação em A4):

```sh
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --no-pdf-header-footer \
  --print-to-pdf="../Pacote-Alex-28-08/05 - Prévia do site (primeira versão).pdf" "file://$PWD/index.html"
```
