# Development Environment

## Supported workflow

NovaLab Platform is designed for Git-based infrastructure work from VS Code. The primary workstation workflow is Windows with PowerShell and WSL Ubuntu. Commands that target infrastructure must be run from the environment documented by the relevant component.

Expected tools include Git, VS Code, Windows PowerShell 5.1 or PowerShell 7, WSL Ubuntu, Terraform, Docker with Compose, and `kubectl`. Component-specific requirements belong in their component documentation.

## Opening the repository

Open the repository root as the VS Code workspace. VS Code detects `.vscode/tasks.json` and may require Workspace Trust and permission to run automatic tasks.

The task selects behavior by execution environment:

- Native Windows invokes Windows PowerShell directly and displays a Windows Forms reminder. Select **Continue**, press Enter, or press Escape to dismiss it.
- VS Code Remote WSL invokes the Bash launcher, detects WSL, translates the workspace and script paths with wslpath -w, and starts Windows PowerShell through WSL interoperability.
- Native Linux invokes PowerShell 7 and uses terminal output. If PowerShell 7 is unavailable, the launcher prints a minimal terminal reminder.

All modes continue passing the workspace root and reading `config/repository-bootstrap.json`. The repository name, window title, reminder heading and items, closing text, and Continue button label are configuration-driven.

Run it manually from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./scripts/bootstrap/Show-RepositoryBootstrap.ps1 -RepositoryRoot .
```

PowerShell 7 users can replace `powershell.exe` with `pwsh`.

## Daily workflow

Start with [`START-HERE.md`](START-HERE.md). Inspect Git status, preserve unrelated work, select the correct infrastructure target, read applicable standards and runbooks, protect secrets and generated state, and review validation output or plans before applying changes.

## Troubleshooting

If no reminder appears:

1. Confirm the workspace is trusted.
2. Allow automatic tasks when prompted.
3. Run `Repository Bootstrap: Today's Reminder` from **Tasks: Run Task**.
4. Confirm PowerShell is available on `PATH`.
5. Validate the paths in `config/repository-bootstrap.json`.

For Remote WSL, also confirm that wslpath and powershell.exe are available inside the WSL session. Windows executable interoperability must be enabled.

A reminder failure does not block VS Code startup or modify repository files.
