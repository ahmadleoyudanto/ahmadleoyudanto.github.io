#!/bin/bash
# Builds docs/ (ready for GitHub Pages / Vercel / Netlify): index.html + cv.pdf
set -euo pipefail
cd "$(dirname "$0")"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
mkdir -p docs

# 1. CV PDF from src/cv.html
"$CHROME" --headless=new --disable-gpu --no-pdf-header-footer \
  --virtual-time-budget=5000 \
  --print-to-pdf="$PWD/docs/cv.pdf" "file://$PWD/src/cv.html" 2>/dev/null
cp docs/cv.pdf src/cv.pdf

# 2. Wrap the page fragment in a full HTML document for static hosting
{
  echo '<!doctype html>'
  echo '<html lang="en"><head><meta charset="utf-8">'
  echo '<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">'
  echo '<style>[hidden]{display:none!important}body{margin:0}img{max-width:100%}</style>'
  echo '</head><body>'
  cat src/index.html
  echo '</body></html>'
} > docs/index.html

echo "Built: docs/index.html, docs/cv.pdf"
