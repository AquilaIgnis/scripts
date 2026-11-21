#!/usr/bin/env bash
# Remove older installonly kernel packages, but never the customized release.
# Preview with: ./clean-kernels-protected.sh --dry-run
set -euo pipefail

protected_kernel='7.3.3-200.fc44.x86_64'

dry_run=false
case "${1:-}" in
    '') ;;
    --dry-run) dry_run=true ;;
    *) echo "Usage: $0 [--dry-run]" >&2; exit 2 ;;
esac

# Fail closed: do not run cleanup if the kernel we want to preserve is missing.
if ! rpm -q --quiet "kernel-core-${protected_kernel}"; then
    echo "Protected kernel ${protected_kernel} is not installed; refusing cleanup." >&2
    exit 1
fi

# Preserve the original script's selection: all but the newest installed
# version of each installonly package type.
if ! query_output=$(dnf repoquery --installonly --latest-limit=-1 -q); then
    echo 'Failed to query old kernels; nothing removed.' >&2
    exit 1
fi

old_kernels=()
protected_found=()
while IFS= read -r package; do
    [[ -z "$package" ]] && continue
    if [[ "$package" == *"${protected_kernel}" ]]; then
        protected_found+=("$package")
    else
        old_kernels+=("$package")
    fi
done <<< "$query_output"

printf 'Protected kernel release: %s\n' "$protected_kernel"
if ((${#protected_found[@]})); then
    printf 'Excluded from removal:\n'
    printf '  %s\n' "${protected_found[@]}"
fi

if ((${#old_kernels[@]} == 0)); then
    echo 'No other old kernels found.'
    exit 0
fi

if "$dry_run"; then
    printf 'Would request removal of:\n'
    printf '  %s\n' "${old_kernels[@]}"
    echo 'No packages were removed.'
    exit 0
fi

printf 'Requesting removal of:\n'
printf '  %s\n' "${old_kernels[@]}"
echo "Review DNF's complete transaction and CANCEL if it lists ${protected_kernel}."

# Prevent automatic cleanup of newly orphaned dependencies, and provide an
# additional transaction-level exclusion for the protected kernel release.
if ! dnf --exclude="*${protected_kernel}" remove --no-autoremove "${old_kernels[@]}"; then
    echo 'Failed to remove old kernels (or transaction was cancelled).' >&2
    exit 1
fi

echo 'Removed selected old kernels; protected kernel was excluded.'
