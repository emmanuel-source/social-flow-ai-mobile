# Sprint 1 — Foundation

Goal: establish a reliable base before social-network integrations.

| ID | Task | Primary role | Depends on |
|---|---|---|---|
| SFA-001 | Verify Flutter project/bootstrap and baseline CI | Flutter Core | none |
| SFA-002 | Finalize Social Flow design tokens and core components | UI/UX Design | SFA-001 |
| SFA-003 | Validate five-tab application shell/navigation | Flutter Core + Design | SFA-001, SFA-002 |
| SFA-004 | Finalize onboarding flow | Identity | SFA-002, SFA-003 |
| SFA-005 | Implement login domain/presentation skeleton | Identity | SFA-001 |
| SFA-006 | Implement registration domain/presentation skeleton | Identity | SFA-005 |
| SFA-007 | Implement session persistence abstraction with Hive | Identity + Core | SFA-005 |
| SFA-008 | Finalize Workspace model/repository contracts | Identity | SFA-001 |
| SFA-009 | Implement active Workspace selector state/UI | Identity + Design | SFA-008 |
| SFA-010 | QA baseline and contribution workflow | QA | SFA-001..009 |

## Parallel work recommendation
Wave 1:
- SFA-001
- SFA-002

Wave 2:
- SFA-003
- SFA-005
- SFA-008

Wave 3:
- SFA-004
- SFA-006
- SFA-007

Wave 4:
- SFA-009
- SFA-010

Do not start more than three coding tasks simultaneously.
