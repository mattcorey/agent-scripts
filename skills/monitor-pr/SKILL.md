---
name: monitor-pr
description: Watch an existing GitHub pull request for review comments, requested changes, maintainer comments, or merge readiness, and handle actionable items. Use when the user asks to monitor, watch, keep an eye on, start a timer for, or automatically handle a PR.
argument-hint: "PR URL/number and optional interval/quiet-window"
---

# Monitor PR

Watch a PR and act on new actionable signals without disrupting unrelated work.

## Resolve Target

- Use the PR URL/number from the prompt when provided.
- Otherwise infer the PR from the current branch with `gh pr view`.
- Record the PR number, branch, current HEAD, original committer identity, including GitHub login/author association when available, labels/check state, existing comments, reviews, and inline review-comment/thread IDs before watching.

## Default Watch Policy

- Poll every 3 minutes unless the user specifies another interval.
- Stop after at least 15 minutes with no new actionable PR activity, unless the user specifies another quiet window.
- Treat requested changes, review comments, and maintainer comments as actionable candidates.

## Poll Loop

Each poll:

1. Read PR state: `gh pr view --json number,title,url,state,isDraft,reviewDecision,mergeStateStatus,comments,reviews,latestReviews,statusCheckRollup,headRefName`.
2. Read enough PR activity to capture comments, reviews, inline review comments, and requested changes without assuming a single command includes every actionable signal.
3. Compare against already-seen activity. Ignore stale signals already handled.
4. Pick one actionable item at a time.

## Handling Actionable Items

- Review comment/requested changes: inspect the code and thread, implement if correct and safe, verify, commit, push, reply directly to the original review comment, address the specific commenter if they differ from the original committer, otherwise address '@codex', summarize what changed, and request a full re-review.
- Needs human input or unsafe to fix: comment with the blocker/question and stop or continue only if other independent items remain.
- Positive review/no action: if the latest-head review signal is clearly approving or reports no major issues, including a thumbs-up reaction, treat monitoring as complete after confirming there is no newer actionable activity.
- Merge-ready/no action without an explicit positive review signal: keep watching until the quiet window completes.

## Guardrails

- Never force push.
- Do not rewrite PR history unless explicitly requested and allowed.
- Do not batch unrelated fixes into one commit just because they arrived during the same watch window.
- Do not leave long-running shell sessions active at final response.
- Final response should summarize handled items, commits pushed, comments posted, and whether the watch window completed or stopped on a blocker.
