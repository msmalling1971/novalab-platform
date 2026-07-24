#!/usr/bin/env bash

set -u

repository_root="${1:-}"

if [[ -z "${repository_root}" ]]; then
    printf '%s\n' 'Repository Bootstrap Framework: workspace root was not provided.' >&2
    exit 0
fi

script_path="${repository_root}/scripts/bootstrap/Show-RepositoryBootstrap.ps1"
is_wsl=false

if [[ -n "${WSL_INTEROP:-}" ]] || grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then
    is_wsl=true
fi

if [[ "${is_wsl}" == true ]]; then
    if ! command -v wslpath >/dev/null 2>&1 || ! command -v powershell.exe >/dev/null 2>&1; then
        printf '%s\n' 'Repository Bootstrap Framework: WSL interoperability is unavailable; using terminal fallback.' >&2
    else
        windows_script_path="$(wslpath -w "${script_path}")"
        windows_repository_root="$(wslpath -w "${repository_root}")"

        if powershell.exe \
            -NoProfile \
            -ExecutionPolicy Bypass \
            -File "${windows_script_path}" \
            -RepositoryRoot "${windows_repository_root}"; then
            exit 0
        fi

        printf '%s\n' 'Repository Bootstrap Framework: Windows popup launch failed; using terminal fallback.' >&2
    fi
fi

if command -v pwsh >/dev/null 2>&1; then
    pwsh \
        -NoProfile \
        -File "${script_path}" \
        -RepositoryRoot "${repository_root}"
else
    printf '%s\n' \
        'Repository Bootstrap Framework' \
        '' \
        "Today's Reminder" \
        '' \
        '- Read START HERE' \
        "- Review today's checkpoint" \
        '- Run git status' \
        "- Confirm today's objective" \
        '' \
        'Happy Engineering.'
fi

exit 0
