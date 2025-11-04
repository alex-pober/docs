# Documentation Scripts

This directory contains utility scripts for managing your Mintlify law school documentation project.

## convert-transcripts.sh

Universal script to convert Zoom transcript files (Class01.txt, Class02.txt, etc.) into properly formatted MDX files for Mintlify.

### Usage

```bash
cd scripts
./convert-transcripts.sh <class-name>
```

### Examples

```bash
# Convert contracts transcripts
./convert-transcripts.sh contracts

# Convert torts transcripts
./convert-transcripts.sh torts

# Convert property transcripts
./convert-transcripts.sh property
```

### What It Does

The conversion script automatically handles all formatting issues:

1. **Creates MDX files** - Converts `Class01.txt` → `session-01.mdx` with proper frontmatter
2. **Removes non-breaking spaces** - Cleans Unicode character 160 that causes LaTeX errors
3. **Escapes dollar signs** - Converts `$` to `\$` to prevent italic/math mode rendering
4. **Preserves line breaks** - Adds two trailing spaces to each line so transcripts don't run together

### Prerequisites

Before running the script:

1. Create the transcripts directory if it doesn't exist:
   ```bash
   mkdir -p classes/<class-name>/transcripts
   ```

2. Add your Zoom transcript files (Class01.txt, Class02.txt, etc.) to the directory

### After Running the Script

The script will output the JSON you need to add to `docs.json`. You need to:

1. **Update docs.json navigation** - Copy the JSON output and add it to your navigation config
2. **Test in Mintlify** - Run your dev server and verify no errors

### Example Workflow

```bash
# 1. Add new transcript files
cp ~/Downloads/Class*.txt classes/contracts/transcripts/

# 2. Run conversion
cd scripts
./convert-transcripts.sh contracts

# 3. Update docs.json with the output provided

# 4. Test
npm run dev  # or your Mintlify dev command
```

## Troubleshooting

### Script can't find class directory

Make sure the class directory structure exists:
```bash
mkdir -p classes/<class-name>/transcripts
```

### No txt files found

Ensure your Zoom transcripts are named correctly:
- Class01.txt, Class02.txt, Class03.txt, etc.
- Place them in `classes/<class-name>/transcripts/`

### LaTeX errors still appearing

The script should handle these automatically, but if you still see errors:

**Non-breaking spaces (Unicode 160):**
```bash
cd classes/<class-name>/transcripts
for file in session-*.mdx; do
  LC_ALL=C sed -i '' 's/\xC2\xA0/ /g' "$file"
done
```

**Italicized dollar amounts:**
```bash
for file in session-*.mdx; do
  sed -i '' 's/\$/\\$/g' "$file"
done
```

**Missing line breaks:**
```bash
for file in session-*.mdx; do
  awk 'NR <= 9 { print; next } NF > 0 { print $0 "  " } NF == 0 { print }' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
done
```

## Project Structure

```
docs/
├── scripts/
│   ├── convert-transcripts.sh   # This script
│   └── README.md                 # This file
├── classes/
│   ├── contracts/
│   │   └── transcripts/
│   │       ├── Class01.txt       # Original transcript
│   │       ├── session-01.mdx    # Converted MDX
│   │       └── index.mdx         # Landing page
│   ├── torts/
│   │   └── transcripts/
│   └── property/
│       └── transcripts/
└── docs.json                     # Navigation config
```
