---
name: markitdown
description: Convert any local document or media file to clean Markdown using Microsoft's markitdown. Use when the user hands over a PDF, Word/PowerPoint/Excel file (docx/pptx/xlsx), image, audio file, HTML, CSV/JSON/XML, EPUB, or ZIP and wants its content read, extracted, summarized, or turned into markdown — i.e. "convert this", "read this PDF", "extract the text from", "what's in this file", "turn this doc into markdown".
---

# markitdown — files → Markdown

Microsoft's [markitdown](https://github.com/microsoft/markitdown) converts almost
any document or media file into clean Markdown that's easy to read and reason
about. Installed as an isolated CLI at `~/.local/bin/markitdown` (via pipx, with
the `[all]` extras for PDF/Office/image/audio support).

## When to use it

Whenever the user provides a **local file** (not a URL) and wants its content —
to read it, extract text, summarize it, quote from it, or save it as markdown.
Reach for this before trying to parse binary formats by hand.

Supported inputs include: **PDF, DOCX, PPTX, XLSX/XLS, images** (EXIF + OCR-style
metadata), **audio** (EXIF + speech transcription where available), **HTML, CSV,
JSON, XML, EPUB, ZIP** (iterates contents), Outlook `.msg`, and plain text.

For **web pages / URLs**, prefer the `firecrawl-scrape` skill instead — markitdown
is for files on disk.

## How to run it

The binary lives in `~/.local/bin`, which may not be on PATH in a fresh shell, so
call it by full path or export PATH first:

```bash
export PATH="$HOME/.local/bin:$PATH"

# To a file:
markitdown report.pdf -o report.md

# To stdout (then read it):
markitdown slides.pptx

# From stdin (give an extension hint):
cat data.xlsx | markitdown -x xlsx
```

Then read the resulting markdown to answer the user's question.

## Options worth knowing

- `-o FILE` — write to a file instead of stdout. Use for anything large so it
  doesn't flood the conversation; then Read the file.
- `--keep-data-uris` — keep base64 image data inline (truncated by default).
- `-d --use-docintel -e ENDPOINT` — use **Azure Document Intelligence** for
  scanned/image-only PDFs that have no embedded text. Needs an Azure endpoint;
  the default offline mode does NOT OCR scanned pages.
- `-p --use-plugins` / `--list-plugins` — enable 3rd-party converter plugins.

## Notes

- Default conversion is **offline and free** — no API calls, nothing leaves the
  machine. Prefer it over API-based parsers for local files.
- A scanned PDF (pure images, no text layer) will come back nearly empty in
  offline mode. If that happens, say so and offer the Document Intelligence path
  or an OCR tool rather than pretending the file was empty.
- Reinstall / upgrade: `pipx upgrade markitdown` (or `pipx install 'markitdown[all]'`).
