#!/bin/bash

# Universal script to convert Class*.txt transcripts to properly formatted MDX files
# Works for any class: Contracts, Torts, Property, etc.
#
# Usage: ./convert-transcripts.sh <class-name>
# Example: ./convert-transcripts.sh contracts
#          ./convert-transcripts.sh torts
#          ./convert-transcripts.sh property

# Check if class name is provided
if [ -z "$1" ]; then
  echo "Error: Please provide a class name"
  echo "Usage: ./convert-transcripts.sh <class-name>"
  echo "Example: ./convert-transcripts.sh contracts"
  exit 1
fi

CLASS_NAME=$(echo "$1" | tr '[:upper:]' '[:lower:]')
TRANSCRIPT_DIR="../classes/${CLASS_NAME}/transcripts"

# Check if directory exists
if [ ! -d "$TRANSCRIPT_DIR" ]; then
  echo "Error: Directory not found: $TRANSCRIPT_DIR"
  echo "Please create the directory first or check the class name"
  exit 1
fi

echo "=========================================="
echo "Converting $CLASS_NAME transcripts"
echo "=========================================="
echo ""

cd "$TRANSCRIPT_DIR" || exit 1

converted_count=0

for i in {01..20}; do
  txt_file="Class${i}.txt"
  mdx_file="session-${i}.mdx"

  # Check if the txt file exists
  if [ ! -f "$txt_file" ]; then
    continue
  fi

  echo "Converting $txt_file to $mdx_file..."

  # Create MDX file with frontmatter
  cat > "$mdx_file" << EOF
---
title: "Session ${i}"
description: "${CLASS_NAME^} class session ${i} transcript"
---

# ${CLASS_NAME^} - Session ${i}

## Transcript

EOF

  # Append the transcript content with all cleaning steps
  cat "$txt_file" | \
    # Remove non-breaking spaces (char 160)
    LC_ALL=C sed 's/\xC2\xA0/ /g' | \
    # Escape dollar signs for LaTeX
    sed 's/\$/\\$/g' | \
    # Add two trailing spaces to preserve line breaks in Markdown
    awk 'NF > 0 { print $0 "  " } NF == 0 { print }' \
    >> "$mdx_file"

  echo "  ✓ Created $mdx_file"
  converted_count=$((converted_count + 1))
done

echo ""
echo "=========================================="
echo "Conversion complete!"
echo "Converted $converted_count transcript(s)"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Update docs.json navigation to include all session files"
echo "   Location: classes/${CLASS_NAME}/transcripts/session-*.mdx"
echo ""
echo "2. Add to docs.json navigation:"
echo "   {"
echo "     \"group\": \"Class Transcripts\","
echo "     \"pages\": ["
echo "       \"classes/${CLASS_NAME}/transcripts/index\","
for i in {01..20}; do
  if [ -f "session-${i}.mdx" ]; then
    echo "       \"classes/${CLASS_NAME}/transcripts/session-${i}\","
  fi
done | sed '$ s/,$//'
echo "     ]"
echo "   }"
echo ""
echo "3. Test in Mintlify to ensure proper rendering"
