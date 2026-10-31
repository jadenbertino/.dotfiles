# Codex

- `AGENTS.md` is for Codex only, which I use for non-coding work.
  - Codex reads it from `~/.codex/AGENTS.md` (`.codex` is a symlink to this folder).
  - Keep coding rules out of it. Those live in the root `AGENTS.md`, which Claude Code reads.
- Don't add an `AGENTS.override.md` here. Codex would load it instead of `AGENTS.md`.
