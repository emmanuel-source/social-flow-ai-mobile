# GitHub Setup

## Repository
Recommended repository name: `social-flow-ai-mobile`.

## Initial push
From the project root:

```bash
git init
git add .
git commit -m "chore: initialize Social Flow AI Flutter foundation"
git branch -M main
git remote add origin <YOUR_GITHUB_REPOSITORY_URL>
git push -u origin main
```

## Collaborator
Invite the remote developer from GitHub repository settings/collaborators.

## Protect main
After the first push, configure a branch protection rule/ruleset for `main` with at least:
- require pull request before merging;
- require at least one approval when practical;
- require status checks to pass;
- block force pushes/deletion.

## CODEOWNERS
Edit `.github/CODEOWNERS` and replace examples with real GitHub usernames before requiring code-owner reviews.

## Suggested first labels
- feature
- bug
- technical
- design
- qa
- blocked
- backend-dependency
