---
name: r-googledrive
description: |
  Reference and code generation for the googledrive R package (Google Drive integration).
  Use when user asks about "googledrive", "google drive", "drive_upload", "drive_download",
  "drive_find", "drive_get", "drive_create", "drive_share", "drive_rm", "drive_mv",
  "drive_cp", "dribble", "shared drives", "mime type", or discusses uploading, downloading,
  listing, sharing, or managing files on Google Drive from R.
allowed-tools: Read, Bash
version: 1.0.0
---

# r-googledrive — Google Drive Integration for R

googledrive permite criar, listar, baixar, mover, compartilhar e deletar arquivos
no Google Drive diretamente do R. Usa `gargle` para autenticação. Todas as operações
retornam um `dribble` — tibble com metadados do Drive.

## Corpus disponível

Base: `/Users/gsposito/Projects/HelixDS/cases/forecast/docs/googledrive/`

| Arquivo | Conteúdo |
|---------|----------|
| `index.md` | Visão geral, instalação, guia rápido, todas as operações |
| `news.md` | Changelog completo (v0.1.1–v2.1.2) |
| `articles/googledrive.md` | Guia introdutório: listar, fazer upload, navegar, mover, deletar |
| `articles/multiple-files.md` | Trabalho com múltiplos arquivos usando purrr (map, map2_dfr) |
| `articles/file-identification.md` | Sistema de IDs, dribble, drive_find vs drive_get |
| `articles/permissions.md` | Gerenciamento de permissões e compartilhamento |
| `articles/bring-your-own-client.md` | OAuth client e API key próprios |
| `articles/example-files.md` | Arquivos de exemplo do pacote |
| `articles/messages-and-errors.md` | Verbosidade, integração CLI, erros comuns |
| `reference/overview.md` | Índice completo de funções por categoria + referência rápida por tarefa |
| `reference/drive_find.md` | Buscar arquivos por nome, tipo, query |
| `reference/drive_get.md` | Obter arquivo por ID ou URL |
| `reference/drive_ls.md` | Listar conteúdo de pasta |
| `reference/drive_upload.md` | Upload de arquivo local → Drive |
| `reference/drive_download.md` | Download de arquivo Drive → local |
| `reference/drive_create.md` | Criar documento Google nativo vazio |
| `reference/drive_mkdir.md` | Criar pasta |
| `reference/drive_cp.md` | Copiar arquivo |
| `reference/drive_mv.md` | Mover/renomear arquivo |
| `reference/drive_put.md` | Upsert: upload ou atualização condicional |
| `reference/drive_update.md` | Atualizar conteúdo de arquivo existente |
| `reference/drive_rm.md` | Deletar arquivo(s) |
| `reference/drive_share.md` | Compartilhar e gerenciar permissões |
| `reference/drive_publish.md` | Publicar na web |
| `reference/drive_reveal.md` | Abrir arquivo no browser |
| `reference/drive_auth.md` | Configurar autenticação |
| `reference/drive_mime_type.md` | Tabela de MIME types do Drive |
| `reference/dribble.md` | Estrutura do objeto dribble |
| `reference/shared_drives.md` | Shared Drives (drives compartilhados) |

## Workflow de consulta

1. **Listar / buscar arquivos** → `reference/drive_find.md` ou `reference/drive_ls.md`
2. **Upload / download** → `reference/drive_upload.md` ou `reference/drive_download.md`
3. **Múltiplos arquivos** → `articles/multiple-files.md`
4. **Compartilhar** → `reference/drive_share.md` + `articles/permissions.md`
5. **Identificar arquivos** → `articles/file-identification.md` + `reference/dribble.md`
6. **Guia completo** → `articles/googledrive.md`
7. **Auth** → `reference/drive_auth.md` (ou skill r-gargle para detalhes)

## Quick Reference — Padrões de código

```r
library(googledrive)

# ── Autenticação ──────────────────────────────────────────────────────────────
drive_auth(email = "user@domain.com")

# ── Listar arquivos ───────────────────────────────────────────────────────────
drive_find(n_max = 20)
drive_find(type = "spreadsheet")
drive_find("relatorio", n_max = 10)
drive_ls("pasta-nome/subpasta")

# ── Upload ────────────────────────────────────────────────────────────────────
drive_upload("dados.csv", name = "dados-2024", type = "spreadsheet")
drive_upload("relatorio.pdf", path = as_id("FOLDER_ID"))

# ── Download ──────────────────────────────────────────────────────────────────
drive_download(as_id("FILE_ID"), path = "local/arquivo.csv", overwrite = TRUE)
drive_download(as_id("SHEETS_ID"), type = "csv")  # exportar como CSV

# ── Operações em múltiplos arquivos (purrr) ───────────────────────────────────
files <- drive_find(type = "csv")
purrr::walk(files$id, ~ drive_download(as_id(.x), overwrite = TRUE))

# ── Organização ───────────────────────────────────────────────────────────────
drive_mkdir("nova-pasta")
drive_mv(arquivo, path = "pasta-destino")
drive_cp(arquivo, name = "copia-arquivo")
drive_rm(arquivo)

# ── Compartilhar ─────────────────────────────────────────────────────────────
drive_share(arquivo, role = "reader", type = "anyone")
drive_share(arquivo, role = "writer", type = "user", emailAddress = "user@domain.com")

# ── Upsert (criar ou atualizar) ───────────────────────────────────────────────
drive_put("dados.csv", name = "dados-producao")  # cria na 1a vez, atualiza depois
```

## Notas importantes

- Todas as funções retornam um `dribble` (tibble com colunas `name`, `id`, `drive_resource`)
- Use `as_id("URL_ou_ID")` para converter URLs do Drive em identificadores
- Para converter Google Sheets → Excel/CSV no download, use o argumento `type`
- Shared Drives exigem configuração extra: veja `reference/shared_drives.md`
