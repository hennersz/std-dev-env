#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
TEMPLATES=(base nix python)

for template in "${TEMPLATES[@]}"; do
	echo "==> testing template: ${template}"
	tmpdir=$(mktemp -d)
	trap 'rm -rf "${tmpdir:?}"' EXIT

	cd "$tmpdir"
	nix flake init -t "path:${REPO_ROOT}#${template}"

	nix develop \
		--override-input std-dev-env "path:${REPO_ROOT}" \
		-c check

	cd - >/dev/null
	trap - EXIT
	rm -rf "$tmpdir"
done

echo "all templates passed"
