---
name: r-gargle
description: |
  Reference and code generation for the gargle R package (Google API authentication).
  Use when user asks about "gargle", "google auth", "oauth", "token", "service account",
  "credentials", "gargle_options", "token_fetch", "secret_encrypt", "ADC",
  "Application Default Credentials", or discusses authentication for any Google R package
  (googledrive, googlesheets4, bigrquery, etc.). Also triggers on auth errors from
  wrapper packages like "Can't get Google credentials" or "no token".
allowed-tools: Read, Bash
version: 1.0.0
---

# r-gargle — Google API Authentication for R

gargle é a camada de autenticação compartilhada por todos os pacotes Google no R
(googledrive, googlesheets4, bigrquery, etc.). Lida com OAuth 2.0 interativo,
service accounts, ADC, workload identity e criptografia de tokens para CI/CD.

## Corpus disponível

Base: `/Users/gsposito/Projects/HelixDS/cases/forecast/docs/gargle/`

| Arquivo | Conteúdo |
|---------|----------|
| `index.md` | Visão geral, instalação, exemplos rápidos |
| `news.md` | Changelog completo (v0.1.3–v1.6.1) |
| `articles/non-interactive-auth.md` | Auth não-interativa: GCE, service accounts, ADC — **mais usada em produção** |
| `articles/auth-from-web.md` | Auth em RStudio Server, Posit Cloud, OOB |
| `articles/how-gargle-gets-tokens.md` | Internals: sequência do token_fetch() e registro |
| `articles/gargle-auth-in-client-package.md` | Guia para autores de pacotes wrapper (AuthState, drive_auth) |
| `articles/managing-tokens-securely.md` | Criptografia com secret_*() para CI/CD e GitHub Actions |
| `articles/get-api-credentials.md` | Como obter chaves de API, OAuth client, service account no GCP |
| `articles/oauth-client-not-app.md` | Migração OAuth "app" → "client" (v1.3.0+) |
| `articles/request-helper-functions.md` | request_develop(), request_build(), request_make() |
| `articles/troubleshooting.md` | Diagnóstico: verbosidade, sitrep, tokens expirados |
| `articles/google-compute-engine.md` | Auth em VMs GCE com escopos de instância |
| `reference/overview.md` | Índice completo de funções por categoria |
| `reference/token_fetch.md` | Função principal — sequência completa de credenciais |
| `reference/credentials_service_account.md` | Service account com exemplos e estrutura JSON |
| `reference/credentials_user_oauth2.md` | Token OAuth interativo do usuário |
| `reference/gargle_options.md` | Todas as opções globais (email, verbosity, oauth_cache) |
| `reference/gargle_secret.md` | 6 funções de criptografia com exemplos completos |
| `reference/request_develop.md` | Funções de construção de requests HTTP |
| `reference/AuthState.md` | Classe R6 AuthState — campos, métodos, padrão de implementação |

## Workflow de consulta

1. **Auth interativa** → `articles/non-interactive-auth.md` ou `reference/credentials_user_oauth2.md`
2. **Service account / CI/CD** → `articles/non-interactive-auth.md` + `reference/credentials_service_account.md`
3. **Criptografar token para GitHub Actions** → `articles/managing-tokens-securely.md` + `reference/gargle_secret.md`
4. **Problemas de auth** → `articles/troubleshooting.md`
5. **Construir wrapper package** → `articles/gargle-auth-in-client-package.md` + `reference/AuthState.md`
6. **Assinatura exata de função** → `reference/overview.md` ou arquivo individual em `reference/`

## Quick Reference — Padrões de código

```r
# ── Auth interativa (usuário, primeira vez) ──────────────────────────────────
gargle::token_fetch(scopes = "https://www.googleapis.com/auth/drive")

# ── Service account ──────────────────────────────────────────────────────────
gargle::credentials_service_account(
  scopes = "https://www.googleapis.com/auth/spreadsheets",
  path   = "path/to/service-account.json"
)

# ── Auth via pacote wrapper (uso mais comum) ─────────────────────────────────
googledrive::drive_auth(email = "user@domain.com")
googlesheets4::gs4_auth(path = "service-account.json")  # service account

# ── Opções globais ────────────────────────────────────────────────────────────
options(
  gargle_oauth_email = "user@domain.com",  # evita prompt interativo
  gargle_verbosity   = "debug"             # diagnóstico
)

# ── CI/CD: criptografar token ────────────────────────────────────────────────
# Uma vez, localmente:
gargle::secret_encrypt_json("service-account.json", "GARGLE_KEY")
# No CI (lê variável de ambiente):
gargle::secret_decrypt_json(Sys.getenv("GARGLE_KEY"))
```

## Notas importantes

- gargle raramente é chamado diretamente — o ponto de entrada é sempre o pacote wrapper
- Para `googledrive` + `googlesheets4` juntos, configure auth uma única vez: veja `articles/drive-and-sheets.md` no corpus do googlesheets4
- Service accounts não exigem interação humana e são a abordagem preferida para automações
