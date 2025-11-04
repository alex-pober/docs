Convert the specified law school class transcript into organized outline class notes.

  Ask the user for:
  1. Subject (Contracts, Torts, Property, etc.)
  2. Session number

  Then:
  1. Read: classes/{subject}/transcripts/session-{number}.mdx
  2. Extract and organize substantive legal content into clean outline format
  3. Structure with hierarchical headings, bullet points, key terms bolded
  4. Preserve: legal principles, cases, statutes, definitions, illustrative examples, exam tips
  5. Remove: casual conversation, attendance, tangential stories
  6. Save to: classes/{subject}/notes/session-{number}.mdx
  7. Update docs.json navigation to include the new notes file

  Format as study-friendly MDX optimized for exam prep and review.
