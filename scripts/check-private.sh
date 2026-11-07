#!/usr/bin/env sh
# Refuses files that look like they carry personal data.
# Usage: scripts/check-private.sh [files...]   (no args = all tracked + staged files)
set -eu

if [ "$#" -gt 0 ]; then
  files="$*"
else
  files=$( (git ls-files; git diff --cached --name-only --diff-filter=AM) | sort -u)
fi

status=0
for f in $files; do
  [ -f "$f" ] || continue
  case "$f" in
    sample_data/*|scripts/check-private.sh|.githooks/*) continue ;;
  esac
  case "$f" in
    *.db|*.sqlite|*.sqlite3|*.gpx|*.kml|data/*|exports/*|backups/*)
      echo "BLOCKED  $f: data file outside sample_data/"; status=1; continue ;;
  esac
  # email addresses (noreply git identity is allowed)
  if grep -nE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' "$f" | grep -vq 'users\.noreply\.github\.com'; then
    echo "BLOCKED  $f: email address"; grep -nE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' "$f" | grep -v 'users\.noreply\.github\.com' | head -3; status=1
  fi
  # Google spreadsheet IDs, Google API keys, Dropbox tokens
  if grep -nqE 'spreadsheets/d/[A-Za-z0-9_-]{20,}|AIza[0-9A-Za-z_-]{35}|sl\.[A-Za-z0-9_-]{100,}' "$f"; then
    echo "BLOCKED  $f: looks like a Google spreadsheet ID, API key or Dropbox token"; status=1
  fi
  # GPS coordinate pairs with 4+ decimals (NZ latitudes)
  if grep -nqE '\-?(3[4-9]|4[0-7])\.[0-9]{4,},\s*1(6[6-9]|7[0-9])\.[0-9]{4,}' "$f"; then
    echo "BLOCKED  $f: GPS coordinate pair"; status=1
  fi
  # NZ-style registration plate (3 letters + 3 digits) outside sample data
  if grep -nqE '\b[A-Z]{3}[0-9]{3}\b' "$f"; then
    echo "BLOCKED  $f: possible registration plate"; status=1
  fi
done

[ "$status" -eq 0 ] && echo "privacy check: ok"
exit $status
