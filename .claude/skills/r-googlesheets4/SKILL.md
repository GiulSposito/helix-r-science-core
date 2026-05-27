---
name: r-googlesheets4
description: |
  Reference and code generation for the googlesheets4 R package (Google Sheets integration).
  Use when user asks about "googlesheets4", "google sheets", "gs4_read", "read_sheet",
  "write_sheet", "gs4_create", "gs4_auth", "gs4_find", "sheet_write", "range_write",
  "sheet_append", "gs4_deauth", "spreadsheet", "planilha google", or discusses reading,
  writing, creating, or modifying Google Sheets from R.
allowed-tools: Read, Bash
version: 1.0.0
---

# r-googlesheets4 — Google Sheets Integration for R

googlesheets4 permite ler, escrever, criar e modificar planilhas Google Sheets a partir do R.
Usa `gargle` para auth e integra com `googledrive` para operações de arquivo.
É a versão moderna e mantida do antigo `googlesheets`.

## Corpus disponível

Base: `/Users/gsposito/Projects/HelixDS/cases/forecast/docs/googlesheets4/`

| Arquivo | Conteúdo |
|---------|----------|
| `index.md` | Visão geral, instalação, funcionalidades principais |
| `news.md` | Changelog completo (v0.1.0–v1.1.2) |
| `articles/googlesheets4.md` | Introdução: ler, escrever, metadata, operações de sheet |
| `articles/auth.md` | gs4_auth(), gs4_deauth(), scopes, OOB, service accounts |
| `articles/read-sheets.md` | Leitura: worksheets, A1 ranges, ranges nomeados, tipos de coluna |
| `articles/write-sheets.md` | Escrita: gs4_create(), sheet_write(), sheet_append(), range_write(), formulas |
| `articles/find-identify-sheets.md` | URLs, Sheet IDs, as_sheets_id(), gs4_find(), integração googledrive |
| `articles/range-specification.md` | Notação A1, cell_limits, classe range_spec, integração API |
| `articles/dates-and-times.md` | UTC-only do Google Sheets, force_tz() workarounds |
| `articles/drive-and-sheets.md` | Auth dupla com googledrive (duas abordagens), tabela de escopos |
| `articles/fun-with-googledrive-and-readxl.md` | CSV → Sheet → Excel → readxl workflow |
| `articles/googlesheets4-reprex.md` | 4 métodos para reprex com auth |
| `articles/function-class-names.md` | Prefixos gs4_, sheet_, range_ — tabela de migração de googlesheets |
| `articles/example-sheets.md` | 6 Sheet IDs de exemplo: gs4_examples(), gs4_example() |
| `articles/messages-and-errors.md` | Verbosidade, cli, erros comuns |
| `reference/overview.md` | Índice completo por categoria + docs detalhadas das funções principais |

## Workflow de consulta

1. **Ler planilha** → `articles/read-sheets.md` + `reference/overview.md`
2. **Escrever / criar** → `articles/write-sheets.md`
3. **Auth (incluindo service account)** → `articles/auth.md`
4. **Usar com googledrive juntos** → `articles/drive-and-sheets.md`
5. **Especificar range** → `articles/range-specification.md`
6. **Datas e fusos horários** → `articles/dates-and-times.md`
7. **Migrar do googlesheets antigo** → `articles/function-class-names.md`

## Quick Reference — Padrões de código

```r
library(googlesheets4)

# ── Autenticação ──────────────────────────────────────────────────────────────
gs4_auth(email = "user@domain.com")
gs4_auth(path = "service-account.json")   # service account (CI/CD)
gs4_deauth()                               # acesso público (sem auth)

# ── Leitura ───────────────────────────────────────────────────────────────────
# Por URL ou ID
df <- read_sheet("https://docs.google.com/spreadsheets/d/SHEET_ID/")
df <- read_sheet(as_sheets_id("SHEET_ID"))

# Com opções
df <- read_sheet(ss, sheet = "Sheet2", range = "A1:D50")
df <- read_sheet(ss, col_types = "cddD")   # character, double, double, Date

# ── Metadados ─────────────────────────────────────────────────────────────────
meta <- gs4_get(ss)
sheet_names(ss)
gs4_find()                                 # buscar planilhas no Drive

# ── Criação ───────────────────────────────────────────────────────────────────
ss <- gs4_create("minha-planilha", sheets = list(dados = mtcars))

# ── Escrita ───────────────────────────────────────────────────────────────────
sheet_write(df, ss = ss, sheet = "Sheet1")      # substitui aba inteira
sheet_append(df, ss = ss, sheet = "Sheet1")     # adiciona linhas
range_write(ss, data = df, range = "B2")        # escreve em range específico

# ── Operações de sheet (abas) ─────────────────────────────────────────────────
sheet_add(ss, sheet = "Nova Aba")
sheet_delete(ss, sheet = "Aba Antiga")
sheet_rename(ss, sheet = "Sheet1", new_name = "Dados")
sheet_reorder(ss, order = c("Dados", "Resumo"))

# ── Fórmulas ─────────────────────────────────────────────────────────────────
range_write(ss, data = data.frame(formula = gs4_formula("=SUM(A1:A10)")), range = "B1")

# ── Limpeza ───────────────────────────────────────────────────────────────────
range_clear(ss, range = "A1:Z100")
```

## Notas importantes

- `read_sheet()` e `range_read()` são aliases — prefira `read_sheet()` para clareza
- Google Sheets armazena datas como números seriais UTC — use `articles/dates-and-times.md` para workarounds com fusos
- Para usar googlesheets4 + googledrive juntos sem pedir auth duas vezes, veja `articles/drive-and-sheets.md`
- Para leituras rápidas de planilhas públicas sem auth: `gs4_deauth()` antes de ler
