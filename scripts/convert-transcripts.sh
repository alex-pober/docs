#!/bin/bash

# Script to convert a single .vtt transcript file to properly formatted MDX
# Parses VTT (WebVTT) format and creates LLM-friendly transcripts
#
# Usage: ./convert-transcripts.sh <path-to-vtt-file>
# Example: ./convert-transcripts.sh classes/torts/transcripts/Class01.vtt

# Check if file path is provided
if [ -z "$1" ]; then
  echo "Error: Please provide a path to a .vtt file"
  echo "Usage: ./convert-transcripts.sh <path-to-vtt-file>"
  echo "Example: ./convert-transcripts.sh classes/torts/transcripts/Class01.vtt"
  exit 1
fi

VTT_FILE="$1"

# Check if file exists
if [ ! -f "$VTT_FILE" ]; then
  echo "Error: File not found: $VTT_FILE"
  exit 1
fi

# Check if it's a .vtt file
if [[ ! "$VTT_FILE" =~ \.vtt$ ]]; then
  echo "Error: File must have .vtt extension"
  exit 1
fi

# Extract the directory and filename
DIR_PATH=$(dirname "$VTT_FILE")
FILENAME=$(basename "$VTT_FILE" .vtt)

# Create output filename (convert Class01 to session-01)
if [[ "$FILENAME" =~ ^Class([0-9]+)$ ]]; then
  SESSION_NUM="${BASH_REMATCH[1]}"
  # Pad with leading zero if needed
  SESSION_NUM=$(printf "%02d" $((10#$SESSION_NUM)))
  MDX_FILE="${DIR_PATH}/session-${SESSION_NUM}.mdx"
else
  # If not in ClassXX format, just replace .vtt with .mdx
  MDX_FILE="${DIR_PATH}/${FILENAME}.mdx"
fi

# Extract class name from path (e.g., "torts" from "classes/torts/transcripts")
if [[ "$DIR_PATH" =~ classes/([^/]+)/transcripts ]]; then
  CLASS_NAME="${BASH_REMATCH[1]}"
  # Capitalize first letter
  CLASS_NAME_CAPITALIZED="$(tr '[:lower:]' '[:upper:]' <<< ${CLASS_NAME:0:1})${CLASS_NAME:1}"
else
  CLASS_NAME="Class"
  CLASS_NAME_CAPITALIZED="Class"
fi

echo "=========================================="
echo "Converting VTT to MDX"
echo "=========================================="
echo "Input:  $VTT_FILE"
echo "Output: $MDX_FILE"
echo ""

# Create MDX file with frontmatter
cat > "$MDX_FILE" << EOF
---
title: "Session ${SESSION_NUM}"
description: "${CLASS_NAME_CAPITALIZED} class session ${SESSION_NUM} transcript"
---

# ${CLASS_NAME_CAPITALIZED} - Session ${SESSION_NUM}

## Transcript

EOF

# Parse VTT file and extract only speaker dialogue
# Remove: WEBVTT header, numeric IDs, timestamps, keep only "Speaker: dialogue" lines
# First convert Windows line endings to Unix
tr -d '\r' < "$VTT_FILE" | awk '
  BEGIN {
    in_entry = 0
    prev_blank = 0
  }
  # Skip WEBVTT header
  /^WEBVTT/ { next }
  # Skip timestamp lines (contain -->)
  /-->/ { next }
  # Skip numeric entry IDs (lines that are only digits)
  /^[0-9]+$/ { next }
  # Empty lines - track but only output one between entries
  /^[[:space:]]*$/ {
    if (in_entry) {
      print ""
      in_entry = 0
      prev_blank = 1
    }
    next
  }
  # Lines with content (Speaker: dialogue)
  {
    in_entry = 1
    prev_blank = 0
    print $0
  }
' | \
  # Remove non-breaking spaces
  LC_ALL=C sed 's/\xC2\xA0/ /g' | \
  # Escape dollar signs for LaTeX
  sed 's/\$/\\$/g' | \
  # Clean up multiple consecutive blank lines
  cat -s \
  >> "$MDX_FILE"

echo "=========================================="
echo "✓ Conversion complete!"
echo "=========================================="
echo ""
echo "Created: $MDX_FILE"
