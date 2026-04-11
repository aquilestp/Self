# Fix WhatsApp scroll picker: Edit button behavior & bubble width

**Changes:**

1. **Edit option only activates on tap** — Currently, scrolling to "Edit" triggers the edit action automatically. The fix will make "Edit" a tappable button instead — scrolling past it won't trigger anything, only an explicit tap will open the text editor.

2. **Fix bubble width to match text** — Currently the green capsule background stretches to a fixed width (180pt) regardless of text length. The fix will make each item use `.fixedSize()` so the green capsule hugs the text content, and items will be right-aligned in the scroll area.