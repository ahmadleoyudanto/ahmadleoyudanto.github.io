#!/bin/bash
# Builds docs/ (served by GitHub Pages): index.html + cv.pdf
set -euo pipefail
cd "$(dirname "$0")"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
mkdir -p docs

# 1. CV PDF from src/cv.html
"$CHROME" --headless=new --disable-gpu --no-pdf-header-footer \
  --virtual-time-budget=5000 \
  --print-to-pdf="$PWD/docs/cv.pdf" "file://$PWD/src/cv.html" 2>/dev/null
cp docs/cv.pdf src/cv.pdf

# 1b. Social preview image (LinkedIn/WhatsApp thumbnail) 1200x627
"$CHROME" --headless=new --disable-gpu --hide-scrollbars --window-size=1200,627 \
  --virtual-time-budget=5000 \
  --screenshot="$PWD/docs/og-image.png" "file://$PWD/src/og.html" 2>/dev/null

# 2. Wrap each page fragment in a full HTML document for static hosting
SITE="https://ahmadleoyudanto.github.io"
DESC="Senior backend engineer in Jakarta. Kafka fix that cut pods from 200 to 30, test coverage 0-15% to 90%+, and a promo that gave out 6.5M free gifts in year one."
wrap() { # $1 = source fragment, $2 = output file, $3 = page path, $4 = og title, $5 = description
  {
    echo '<!doctype html>'
    echo '<html lang="en"><head><meta charset="utf-8">'
    echo '<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">'
    echo "<meta name=\"description\" content=\"$5\">"
    echo "<meta property=\"og:type\" content=\"website\">"
    echo "<meta property=\"og:url\" content=\"$SITE/$3\">"
    echo "<meta property=\"og:title\" content=\"$4\">"
    echo "<meta property=\"og:description\" content=\"$5\">"
    echo "<meta property=\"og:image\" content=\"$SITE/og-image.png\">"
    echo "<meta property=\"og:image:width\" content=\"1200\"><meta property=\"og:image:height\" content=\"627\">"
    echo "<meta name=\"twitter:card\" content=\"summary_large_image\">"
    echo '<style>[hidden]{display:none!important}body{margin:0}img{max-width:100%}</style>'
    grep -m1 '<title>' "$1"
    echo '</head><body>'
    grep -v '<title>' "$1"
    echo '</body></html>'
  } > "$2"
}
wrap src/index.html docs/index.html "" "Ahmad Leo Yudanto · Senior Backend Engineer" "$DESC"
wrap src/apps.html docs/apps.html "apps.html" "Apps · Ahmad Leo Yudanto" "Side projects: Road to N3, a JLPT study app that explains why you miss, and Court Psywar, a padel and badminton session app with fair matchmaking and trash talk."

# 3. Images used by the pages
mkdir -p docs/img && cp src/img/*.png docs/img/

echo "Built: docs/index.html, docs/apps.html, docs/cv.pdf"
