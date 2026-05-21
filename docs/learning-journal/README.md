## WSL vs Windows Filesystem Realization

One major realization during GitHub Actions and platform repository setup was understanding the distinction between:

- Windows-native filesystem paths
- WSL-mounted Windows paths
- Linux-native WSL filesystem paths

Examples:

Windows path:
C:\NovaLab

WSL-mounted Windows path:
/mnt/c/NovaLab

Linux-native WSL path:
/home/msmalling/novalab-platform

Key realization:

VS Code can accidentally point to the Windows-side copy of a project while Git and Linux tooling operate against the Linux-native repository inside WSL.

This can create confusion where:
- files appear missing in VS Code
- `ls` in WSL shows different contents
- Git repositories appear inconsistent
- Docker and automation tooling behave differently

Operational lesson learned:

For Linux-native infrastructure workflows, repositories should be opened directly from WSL using:

```bash
cd ~/novalab-platform
code .
```

This ensures:
- Linux-native Git behavior
- consistent Docker behavior
- correct filesystem visibility
- better compatibility with Terraform, CI/CD runners, and Kubernetes workflows

Broader realization:

Modern platform engineering environments increasingly operate as layered systems:

- Windows = desktop/UI layer
- WSL Linux = engineering/runtime layer
- Docker = application runtime layer
- GitHub Actions = automation/orchestration layer

Understanding which layer owns the workload is critical for troubleshooting and operational clarity.
CI/CD Realizations
Git push triggers automation
runners execute jobs
workflows → jobs → steps model
pipelines validate infrastructure before deployment
GitHub Actions runners are ephemeral Linux workers
Terraform Realizations
declarative vs imperative infrastructure
desired state reconciliation
drift detection
Terraform state as infrastructure memory
infrastructure reproducibility
Terraform ≠ backups/DR
persistent data must still be protected separately
Operational Realizations
IaC standardizes infrastructure
reduces configuration drift
governance through code
Git becomes infrastructure history
CI/CD becomes automated governance enforcement
emergency restore workflows still matter
Terraform import critical for DR reconciliation

Those notes are EXTREMELY valuable later for:

your website
architecture discussions
leadership interviews
modernization strategy conversations