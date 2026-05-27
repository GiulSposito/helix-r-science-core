---
name: r-googleAuthR
description: |
  Reference and code generation for the googleAuthR R package (build Google API clients in R).
  Use when user asks about "googleAuthR", "gar_auth", "gar_api_generator", "gar_set_client",
  "gar_auth_service", "google api client R", "build google api R", "Discovery API R",
  "batching google api", "gar_batch", "googleAuthR shiny", or discusses creating custom
  Google API wrapper functions or R packages that call Google APIs.
allowed-tools: Read, Bash
version: 1.0.0
---

# r-googleAuthR — Build Google API Clients in R

googleAuthR é a base para criar funções R que chamam APIs do Google.
Enquanto gargle gerencia tokens, googleAuthR gera as funções de endpoint automaticamente.
É usado por pacotes como `searchConsoleR`, `googleAnalyticsR`, `bigQueryR`.

## Corpus disponível

Base: `/Users/gsposito/Projects/HelixDS/cases/forecast/docs/googleAuthR/`

| Arquivo | Conteúdo |
|---------|----------|
| `index.md` | Metadados CRAN, versão, autores, dependências |
| `news.md` | Changelog completo (v0.1–v1.4.0.9000) |
| `vignettes/setup.md` | Configuração inicial, credenciais locais e Shiny |
| `vignettes/google-authentication-types.md` | Todos os tipos de auth com exemplos completos de código R |
| `vignettes/building.md` | gar_api_generator() em profundidade, Discovery API, exemplos goo.gl e Google Calendar |
| `vignettes/advanced-building.md` | Paginação, skip parsing, batching (gar_batch / gar_batch_walk), cache com memoise |
| `vignettes/troubleshooting.md` | Diagnóstico, erros comuns e soluções |
| `articles/setup.md` | (equivalente às vignettes — extraído do site pkgdown) |
| `articles/google-authentication-types.md` | Idem |
| `articles/building-google-api-functions.md` | Idem |
| `articles/advanced-building.md` | Idem |
| `articles/troubleshooting.md` | Idem |
| `reference/index.md` | Todas as funções por categoria + assinaturas completas de gar_auth() e gar_api_generator() + tabela de opções |

## Workflow de consulta

1. **Criar função de API** → `vignettes/building.md`
2. **Auth (todos os tipos)** → `vignettes/google-authentication-types.md`
3. **Configurar credenciais** → `vignettes/setup.md`
4. **Paginação / batching** → `vignettes/advanced-building.md`
5. **Auth em Shiny** → `vignettes/setup.md` (seção Shiny) + `vignettes/google-authentication-types.md`
6. **Problemas** → `vignettes/troubleshooting.md`
7. **Assinatura de função** → `reference/index.md`

## Quick Reference — Padrões de código

```r
library(googleAuthR)

# ── Configurar credenciais ────────────────────────────────────────────────────
gar_set_client(
  web_json   = "client_secret.json",  # ou path para JSON OAuth
  scopes     = "https://www.googleapis.com/auth/calendar"
)

# ── Auth interativa ───────────────────────────────────────────────────────────
gar_auth(email = "user@domain.com")

# ── Auth service account ──────────────────────────────────────────────────────
gar_auth_service(json_file = "service-account.json")

# ── Criar função de API com gar_api_generator() ───────────────────────────────
# Padrão: gar_api_generator(url, http_method, path_args, pars_args, data_parse_function)
list_events <- gar_api_generator(
  baseURI        = "https://www.googleapis.com/calendar/v3/calendars/{calendarId}/events",
  http_header    = "GET",
  path_args      = list(calendarId = "primary"),
  pars_args      = list(maxResults = 10),
  data_parse_function = function(x) x$items
)

# Chamar a função gerada:
events <- list_events()

# ── Paginação automática ──────────────────────────────────────────────────────
all_events <- gar_api_page(
  f          = list_events,
  page_f     = function(x) x$nextPageToken,
  limit_hits = 1000
)

# ── Batching (múltiplas requisições em uma) ───────────────────────────────────
gar_batch(list(list_events(), list_events(calendarId = "other@group.calendar.google.com")))
gar_batch_walk(ids, f = delete_event, .progress = TRUE)

# ── Auth em Shiny ─────────────────────────────────────────────────────────────
# No UI:
googleAuthR::googleAuthUI("auth_module")
# No Server:
accessToken <- callModule(googleAuth, "auth_module")
with_shiny(list_events, shiny_access_token = accessToken)
```

## Opções globais importantes

```r
options(
  googleAuthR.client_id     = "seu-client-id.apps.googleusercontent.com",
  googleAuthR.client_secret = "seu-client-secret",
  googleAuthR.scopes.selected = "https://www.googleapis.com/auth/calendar",
  googleAuthR.verbose       = 3   # 0=silencioso, 3=debug
)
```

## Notas importantes

- googleAuthR é para **construir** clientes de API, não para usar APIs prontas — se uma API já tem pacote (googledrive, googlesheets4), use-o diretamente
- A Discovery API do Google documenta todos os endpoints: `https://developers.google.com/discovery/v1/getting_started`
- Use `vignettes/building.md` para ver exemplos completos com goo.gl e Google Calendar
- Para apps Shiny com auth Google, este é o pacote de referência
