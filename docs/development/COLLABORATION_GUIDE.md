# Collaboration Guide — Social Flow AI

## Source of truth
GitHub `main` is the single source of truth.

Never send project ZIPs back and forth once the repository is created.

## Daily workflow
1. Pull latest `main`.
2. Pick one GitHub issue/task.
3. Create a task branch.
4. Implement only that task.
5. Run format/analyze/tests.
6. Push the branch.
7. Open a pull request.
8. Let CI run.
9. Ask the other human or QA agent to review.
10. Merge only after checks pass.
11. Delete the branch after merge.

## Branch examples
```text
feat/SFA-001-app-foundation
feat/SFA-004-onboarding
fix/SFA-021-calendar-scroll
refactor/SFA-030-network-errors
```

## Sync before starting work
```bash
git switch main
git pull origin main
git switch -c feat/SFA-XXX-short-name
```

## Publish your branch
```bash
git add .
git commit -m "feat: implement SFA-XXX short description"
git push -u origin feat/SFA-XXX-short-name
```

## Avoid conflicts
- Do not share one working folder remotely.
- Do not both work on the same branch.
- Announce the task/feature you own.
- Use separate worktrees/isolated Codex tasks for parallel agents.
- Keep shared-core changes small and coordinated.

## Pull request review
A PR should be small enough to understand in one review session.

Check:
- acceptance criteria
- architecture
- tests
- visual consistency
- regressions
- security/secrets
