---
name: create-and-monitor-pr
description: Create a GitHub pull request for current work, open it, then monitor it for CI and review activity. Use when the user asks to create a PR and watch it, PR this and start a timer, or commit/push/open a PR and keep monitoring.
argument-hint: "Optional PR title/body plus monitoring interval/quiet-window"
---

# Create and Monitor PR

This is an orchestration skill. Use the Create PR workflow first, then immediately use the Monitor PR workflow on the created PR.

## Workflow

1. Create the PR using the same behavior as `/create-pr`:
   - inspect state
   - branch if needed
   - stage intended work
   - verify
   - commit
   - push
   - create draft PR by default
   - open in Safari when requested or implied
2. Start monitoring the created PR using the same behavior as `/monitor-pr`:
   - default interval: 3 minutes
   - default quiet window: 1 hour
   - handle CI failures and review feedback one item at a time
   - comment on the PR after each handled item or blocker

## Defaults

- Draft PR unless user says ready/non-draft.
- Open in Safari unless user says not to.
- Poll every 3 minutes.
- Stop after 1 quiet hour with no new actionable activity.

## Final Response

Include:

- PR URL
- Branch and commit(s)
- Verification run before PR creation
- Monitoring outcome, including fixes pushed or blockers found
