#!/bin/bash
# import-logs.sh
# Imports markdown logs from a source directory and adds Jekyll front matter
#
# Usage: ./scripts/import-logs.sh [source_dir]
# Default source: ~/logs

# set -e  # Disabled - handled per-operation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SOURCE_DIR="${1:-$HOME/logs}"
POSTS_DIR="$REPO_DIR/_posts"
SESSIONS_DIR="$REPO_DIR/_sessions"

# Ensure target directories exist
mkdir -p "$POSTS_DIR" "$SESSIONS_DIR"

# Counters
posts_imported=0
sessions_imported=0
skipped=0

echo "Importing logs from: $SOURCE_DIR"
echo "Posts directory: $POSTS_DIR"
echo "Sessions directory: $SESSIONS_DIR"
echo ""

# Process each markdown file
for file in "$SOURCE_DIR"/*.md; do
  [ -f "$file" ] || continue

  filename=$(basename "$file")

  # Skip non-daily files
  if [[ ! "$filename" =~ daily ]]; then
    continue
  fi

  # Check if file already has front matter
  if head -1 "$file" | grep -q "^---$"; then
    echo "Skipping (has front matter): $filename"
    skipped=$((skipped + 1))
    continue
  fi

  # Determine file type and extract date
  if [[ "$filename" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2})T([0-9]{2})-([0-9]{2})-([0-9]{2})-daily-github-summary\.md$ ]]; then
    # Timestamped session log: YYYY-MM-DDTHH-MM-SS-daily-github-summary.md
    date="${BASH_REMATCH[1]}"
    hour="${BASH_REMATCH[2]}"
    min="${BASH_REMATCH[3]}"
    sec="${BASH_REMATCH[4]}"
    timestamp="${date}T${hour}:${min}:${sec}"
    title="Session Log - ${timestamp}"
    target_dir="$SESSIONS_DIR"
    category="session-log"
    sessions_imported=$((sessions_imported + 1))

  elif [[ "$filename" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2})T([0-9]{2})-([0-9]{2})-([0-9]{2})-daily-summary\.md$ ]]; then
    # Timestamped summary: YYYY-MM-DDTHH-MM-SS-daily-summary.md
    date="${BASH_REMATCH[1]}"
    hour="${BASH_REMATCH[2]}"
    min="${BASH_REMATCH[3]}"
    sec="${BASH_REMATCH[4]}"
    timestamp="${date}T${hour}:${min}:${sec}"
    title="Session Summary - ${timestamp}"
    target_dir="$SESSIONS_DIR"
    category="session-log"
    sessions_imported=$((sessions_imported + 1))

  elif [[ "$filename" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2})-daily-summary\.md$ ]]; then
    # Canonical daily summary: YYYY-MM-DD-daily-summary.md
    date="${BASH_REMATCH[1]}"
    timestamp="$date"
    title="Daily Summary - ${date}"
    target_dir="$POSTS_DIR"
    category="daily-summary"
    posts_imported=$((posts_imported + 1))

  else
    echo "Skipping (unknown format): $filename"
    skipped=$((skipped + 1))
    continue
  fi

  # Create file with front matter prepended
  target_file="$target_dir/$filename"
  {
    printf '%s\n' "---"
    printf '%s\n' "title: \"$title\""
    printf '%s\n' "date: $timestamp"
    printf '%s\n' "categories: [$category]"
    printf '%s\n' "tags: [commits, github]"
    printf '%s\n' "---"
    printf '\n'
    cat "$file"
  } > "$target_file"

  echo "Imported: $filename -> $(basename "$target_dir")/"
done

echo ""
echo "Import complete!"
echo "  Posts imported: $posts_imported"
echo "  Sessions imported: $sessions_imported"
echo "  Skipped: $skipped"
