# docx build pipeline

Generate `.docx` deliverables from the Markdown sources for customer
hand-off.

## Prerequisites

- [pandoc](https://pandoc.org/installing.html)
- (Optional) a `reference.docx` in this folder to brand the output
  (fonts, headers, table styles). Generate a starter with:

```bash
pandoc -o docs/_build/reference.docx --print-default-data-file reference.docx
```

## Build

```bash
# All customer-facing guides
./docs/_build/build_docx.sh

# A single file
./docs/_build/build_docx.sh single active-directory/01-identity-connector-ad.md
```

Output lands in `docs/_build/out/` (gitignored).
