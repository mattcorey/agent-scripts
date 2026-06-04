---
name: create-pr
description: Commit current work, push a branch, create a GitHub pull request, and open it for review. Use when the user asks to create a PR, commit and PR, ship a branch, open a pull request, or open the PR in Safari.
argument-hint: "Optional PR title/body/branch guidance"
---

# Create PR

Package the current worktree into a GitHub pull request with minimal disruption.

## Workflow

1. Inspect state with `git status --short --branch` and `git diff --stat`.
2. If detached or on an unsuitable branch, create a branch named `codex/<short-purpose>`.
3. Stage only the intended work. Do not revert unrelated user changes.
4. Run focused verification when practical. At minimum run `git diff --check`.
5. Commit with a concise imperative message.
6. Push with upstream tracking.
7. Create a draft PR by default unless the user asks for a ready PR.
8. Open the PR in Safari when requested, or when the user's phrasing includes "open".
9. Final response: PR URL, branch, commit, and verification.

## Defaults

- Branch prefix: `codex/`.
- PR base: `main`, unless repo context says otherwise.
- PR mode: draft.
- PR body sections: Summary and Verification.
- Prefer `gh pr create`; use another GitHub tool only if repo context requires it.

## Guardrails

- Never force push.
- Never amend already-pushed commits unless explicitly allowed by repo instructions.
- If `git status` shows surprising unrelated changes, keep them out of the commit or call them out before proceeding.
- If verification cannot run, state exactly why in the PR body and final response.
