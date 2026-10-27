# SEO do site dralexfabricio.com.br

Estado em 27/10/2026. O site é uma página só (mais o aviso de privacidade), o que é adequado para um consultório
de uma especialidade numa cidade: concentra toda a autoridade numa URL. O que está feito, o que depende do Mateus
e o que fica para uma segunda fase.

## Feito na página (27/10)

| Item | Como ficou |
|---|---|
| `<title>` | "Psiquiatra em Ubá/MG · Dr. Alex Fabrício de Oliveira" (palavra-chave principal primeiro, 56 caracteres) |
| Meta description | 1 frase com especialidade, cidade, formato (1 hora, presencial ou vídeo), motivos de consulta e chamada para o WhatsApp (~230 caracteres; o Google corta em ~160, o começo é o que importa) |
| H1 | Nome do médico + "Psiquiatra em Ubá/MG" dentro do H1 (visual igual ao anterior) |
| H2 | 7 seções com intenção de busca: quando procurar, o médico, por que uma hora, como funciona, formação, dúvidas, marcar consulta |
| H3 | 8 situações (ansiedade, tristeza, insônia, atenção, humor, momentos difíceis, medicação, segunda opinião), 6 princípios, 3 etapas, 3 públicos |
| Dados estruturados | `Physician` completo (@id, CRM/RQE, endereço, telefone, horário, mapa, áreas de atuação, serviços, redes, aceita novos pacientes) + `FAQPage` com as 9 perguntas da seção Dúvidas |
| Open Graph / Twitter | título, descrição, imagem 1200x630 (`assets/og.png`, refeita sem fundo preto), alt, dimensões |
| Local | `geo.region`, `geo.placename`, endereço idêntico ao da ficha do Google (NAP: nome, endereço, telefone iguais em site, ficha e Instagram) |
| Canonical, robots, sitemap | canonical na raiz; `robots.txt` liberando tudo e apontando o sitemap; `sitemap.xml` com lastmod 2026-10-27 |
| Imagens | retrato com alt descritivo; arte do vitruviano é decorativa (aria-hidden) |
| Velocidade | sem fontes externas, sem framework, CSS de 20 KB, imagens com lazy loading; GitHub Pages com HTTP/2 e HTTPS |
| Conversão | WhatsApp em 5 pontos (hero, apresentação, dúvidas, contato, barra fixa no celular), todos com texto pré-preenchido |

Conformidade: nada de preço, depoimento de paciente, "antes e depois", promessa de resultado ou superlativo
(Resolução CFM 2.336/2023). Listar áreas de atuação e descrever o funcionamento da consulta é permitido.

## Depende do Mateus (fora do código)

1. **Google Search Console**: adicionar a propriedade `dralexfabricio.com.br` (verificação por DNS: registro TXT no
   registro.br, zona em modo avançado), enviar o sitemap, pedir indexação da raiz. É aqui que se vê por quais
   buscas o site aparece.
2. **Ficha do Google** (Mateus já é gerente): site preenchido; depois da mudança, trocar endereço, telefone e
   horário no mesmo dia do vídeo de verificação. Adicionar as fotos da fachada e da recepção, categoria principal
   Psiquiatra, secundária Médico, serviços "Consulta psiquiátrica" e "Teleconsulta", atributos de acessibilidade do
   endereço novo. Pedir ao Alex que responda às avaliações novas. A ficha pesa mais que o site para "psiquiatra em
   Ubá" no Maps.
3. **Instagram e Facebook**: colocar o link do site na bio dos dois e o endereço novo; o `sameAs` do JSON-LD já
   aponta para ambos.
4. **E-mail contato@**: quando existir, `COM_EMAIL=1 sh lancar.sh` liga os elementos de e-mail e o campo no JSON-LD.
5. **Citações locais** (uma tarde de trabalho): Doctoralia, Apple Maps, Bing Places, guias de Ubá, UNNA Medicina
   (pedir que a clínica linke o site), UNIFAGOC (página do docente). Sempre o mesmo nome, endereço e telefone.
6. **Google Ads** (Leony): a página já serve como destino. Palavras sugeridas: "psiquiatra ubá", "psiquiatra em
   ubá mg", "psiquiatra perto de mim" (raio Ubá/Visconde do Rio Branco/Tocantins/Guidoval), "psiquiatra online
   minas", "consulta psiquiatra particular ubá". Conversão a medir: clique no WhatsApp (os 5 links têm
   `data-fill="whatsapp"`; basta uma tag de evento no GTM ou no gtag quando o Mateus decidir instalar).

## Segunda fase (quando houver conteúdo do Alex)

- **Páginas por intenção**, uma por assunto, só se tiverem texto próprio do Alex (não vale duplicar a home):
  `/teleconsulta/`, `/ansiedade/`, `/depressao/`, `/insonia/`, `/tdah-adulto/`, `/segunda-opiniao/`,
  `/psiquiatra-idoso/`. Cada uma com 600 a 900 palavras, uma pergunta frequente por parágrafo, link para o WhatsApp
  e `BreadcrumbList`. Texto do Alex gravado em áudio e transcrito é o caminho mais rápido.
- **Artigos curtos** assinados por ele (ele já dá aula de comunicação clínica): "como é a primeira consulta com
  psiquiatra", "o que levar", "remédio ou terapia". Um por mês já é muito para o nível de concorrência local.
- **Vídeo de 1 minuto** na ficha do Google e no site (apresentação do consultório).
- **Analytics** com consentimento (LGPD): só depois de atualizar o aviso de privacidade.

## Como conferir

- Dados estruturados: https://search.google.com/test/rich-results (colar a URL).
- Pré-visualização de compartilhamento: https://www.opengraph.xyz/ ou enviar o link num WhatsApp de teste.
- Velocidade: https://pagespeed.web.dev/ (meta: acima de 90 no celular).
- Resultado real: Search Console, a partir de 2 a 4 semanas após o envio do sitemap.
