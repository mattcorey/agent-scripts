---
name: monitor-pr
description: Watch an existing GitHub pull request for CI failures, review comments, requested changes, or merge readiness, and handle actionable items. Use when the user asks to monitor, watch, keep an eye on, start a timer for, or automatically handle a PR.
argument-hint: "PR URL/number and optional interval/quiet-window"
---

# Monitor PR

Watch a PR and act on new actionable signals without disrupting unrelated work.

## Resolve Target

- Use the PR URL/number from the prompt when provided.
- Otherwise infer the PR from the current branch with `gh pr view`.
- Record the PR number, branch, current HEAD, and current labels/check state before watching.

## Default Watch Policy

- Poll every 3 minutes unless the user specifies another interval.
- Stop after at least 1 hour with no new actionable PR activity, unless the user specifies another quiet window.
- Treat new failing CI, requested changes, review comments, and maintainer comments as actionable candidates.

## Poll Loop

Each poll:

1. Read PR state: `gh pr view --json number,title,url,state,isDraft,reviewDecision,mergeStateStatus,comments,reviews,latestReviews,statusCheckRollup,headRefName`.
2. Read checks: `gh pr checks` and, for failures, `gh run list` / `gh run view` as needed.
3. Compare against already-seen activity. Ignore stale signals already handled.
4. Pick one actionable item at a time.

## Handling Actionable Items

- CI failure: inspect logs, reproduce locally if feasible, implement a focused fix, verify, commit, push, and comment with what changed.
- Review comment/requested changes: inspect the code and thread, implement if correct and safe, verify, commit, push, and reply/comment with what changed.
- Needs human input or unsafe to fix: comment with the blocker/question and stop or continue only if other independent items remain.
- Merge-ready/no action: keep watching until the quiet window completes.

## Guardrails

- Never force push.
- Do not rewrite PR history unless explicitly requested and allowed.
- Do not batch unrelated fixes into one commit just because they arrived during the same watch window.
- Do not leave long-running shell sessions active at final response.
- Final response should summarize handled items, commits pushed, comments posted, and whether the watch window completed or stopped on a blocker.
