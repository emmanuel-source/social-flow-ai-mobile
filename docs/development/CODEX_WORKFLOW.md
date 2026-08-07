# Codex Workflow — Social Flow AI

## Before asking Codex to code
Always provide or reference:
- task ID
- goal
- acceptance criteria
- assigned role
- allowed module/file scope
- dependencies
- validation commands

Codex must read `AGENTS.md` first.

## Recommended orchestration
Use one Orchestrator thread/task to plan work, then isolated coding tasks for implementation.

Default parallelism: maximum three coding tasks.

Each coding task must have distinct module/file ownership.

## Prompt pattern
```text
Read AGENTS.md and docs/development/CODEX_WORKFLOW.md.

Implement SFA-XXX.
Assigned role: <role>.
Goal: <goal>.
Allowed scope: <paths>.
Acceptance criteria:
- ...

Do not modify files outside the allowed scope unless strictly required.
If a shared contract must change, stop and explain why before expanding scope.
Run formatting, flutter analyze and relevant tests before finishing.
Return a concise summary of files changed, tests run and remaining risks.
```

## Review pattern
```text
Act as the QA & Review Agent.
Read AGENTS.md and codex/roles/qa.md.
Review the current diff for SFA-XXX.
Do not rewrite the feature first.
Report BLOCKER/HIGH/MEDIUM/LOW findings with file references.
Then run available format/analyze/tests and report results.
```

## Design review pattern
```text
Act as the UI/UX Design Agent.
Read AGENTS.md, codex/roles/ui_ux_design.md and docs/design/.
Review the current screen/flow for consistency, usability, responsive behavior and shared-component reuse.
Do not change business logic.
```
