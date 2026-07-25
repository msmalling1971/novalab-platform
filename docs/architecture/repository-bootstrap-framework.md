# Repository Bootstrap Framework

## Purpose

The Repository Bootstrap Framework provides a reusable entry point for engineering work through a VS Code folder-open task, dependency-free PowerShell reminder, repository configuration, and concise documentation.

It favors simplicity, convention, no third-party dependencies, no startup mutations, safe failure, and maintainable platform engineering practices.

## Flow

```text
VS Code opens repository
  -> .vscode/tasks.json
  -> Windows: scripts/bootstrap/Show-RepositoryBootstrap.ps1
scripts/bootstrap/launch-repository-bootstrap.sh
  -> Linux/WSL: scripts/bootstrap/launch-repository-bootstrap.sh
       -> WSL: wslpath -w -> Windows PowerShell
       -> Linux: PowerShell 7
  -> config/repository-bootstrap.json
  -> configuration-driven Windows Forms reminder or terminal fallback
  -> docs/START-HERE.md
```

`START-HERE.md` owns the daily checklist. `DEVELOPMENT-ENVIRONMENT.md` owns workstation setup and troubleshooting.

## Configuration convention

Configuration lives in visible `config/`, a conventional location for versioned repository configuration that can accommodate future settings without another top-level directory.

`config/repository-bootstrap.json` is the repository-specific adapter. A copied framework should normally require changes only to `repositoryName`; documentation paths need changing only if the destination rejects the standard layout.

## Contracts

The task runs on folder open, subject to Workspace Trust and automatic-task permission. Native Windows uses Windows PowerShell directly. Linux and WSL use the Bash launcher. It detects WSL, translates paths with wslpath -w, and invokes Windows PowerShell through WSL interoperability. Native Linux uses PowerShell 7 and terminal fallback.

Both launch paths pass the workspace root to the same PowerShell script. The script reads the fixed configuration path, validates configured relative paths and display text, shows the reminder, falls back safely, and performs no writes or network operations. On interactive Windows, the Windows Forms interface can be dismissed with the configuration-driven Continue button, Enter, Escape, or the window close control.

## Reuse

Copy these paths into Genesis, Azure Enterprise, or another platform repository:

```text
.vscode/tasks.json
config/repository-bootstrap.json
scripts/bootstrap/Show-RepositoryBootstrap.ps1
docs/START-HERE.md
docs/DEVELOPMENT-ENVIRONMENT.md
docs/architecture/repository-bootstrap-framework.md
```

Keep standard paths stable and change the repository name in configuration. Destination documentation can link to existing architecture, standards, and component guides without duplicating them.

## Failure model

The framework is advisory. Invalid configuration, unavailable graphical APIs, or missing documentation never prevents repository startup. It does not install tools, initialize infrastructure, alter Git state, open network connections, or persist acknowledgement state.
