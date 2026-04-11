# Fix WhatsApp bubble tail & allow two-line messages in selector

**Changes:**

- **Remove the bubble tail (triangle):** Replace the custom `WhatsAppBubbleShape` (which draws a curved tail at the bottom-right) with a simple rounded rectangle. The WhatsApp message on the canvas will just be a clean rounded bubble with no tail/triangle.

- **Two-line text in the message selector:** Allow "My coach would be proud" and "Pain is temporary, PRs are forever" (and any other long messages) to wrap onto two lines in the scroll picker. Currently they are forced to a single line. Only the selector is affected — the canvas bubble stays as-is.