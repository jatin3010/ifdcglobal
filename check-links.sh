#!/usr/bin/env bash
# Run before uploading: fails if a page or stylesheet points at a local file that does not exist.
cd "$(dirname "$0")" || exit 1
fail=0
for f in *.html; do
  for p in $(perl -0pe 's/<!--.*?-->//gs' "$f" | grep -oE '(src|href)="[^"#?]*' | sed -E 's/^(src|href)="//' | grep -vE '^(https?:|mailto:|tel:|javascript:|$)'); do
    [ -e "$p" ] || { echo "$f -> $p"; fail=1; }
  done
done
for f in assets/css/*.css; do
  for p in $(grep -oE 'url\([^)]*\)' "$f" | sed -E "s/url\(['\"]?//; s/['\"]?\)$//; s/[?#].*//" | grep -vE '^(data:|https?:|$)'); do
    [ -e "assets/css/$p" ] || { echo "$f -> $p"; fail=1; }
  done
done
[ $fail = 0 ] && echo "All local links OK"
exit $fail
