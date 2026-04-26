# Guardrails

Agent failure modes — things to stop re-proposing. Short by design.

- **shared** — When promoting docs at issue close, read the actual shipped source files. Do not draft from conversation memory or the issue README's `## Done` summaries. Why: conversation memory is lossy and framing-dependent; specs drafted that way are wrong on day one (#12).
- **shared** — Before drafting a new `spool/docs/<subsystem>.md`, scan existing docs for content the issue may have superseded. Why: the user often forgets what already exists; stale docs survive close otherwise (#12).
