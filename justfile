# The tutorial through smallwikiapp, in timewalk. Run `just` to see the list.
#
# `just setup` clones the project into repo/, and timewalk keeps its copy in worktree/. Git ignores both.

project := "smallwikiapp"
upstream := "rahuldave"
# Tutorials are on timewalk's branch `walks` until a release has them. TIMEWALK names another source
timewalk := env("TIMEWALK", "git+https://github.com/rahuldave/timewalk@walks")
tw := "uvx -q --refresh-package timewalk --from " + quote(timewalk)

[private]
default:
    @just --list --unsorted

# Open the tutorial: just present do (you make the moves), or just present (they are shown)
present walk="show" *args: setup
    {{ tw }} timewalk repo --replay worktree --toc toc.toml --walk {{ walk }} --discard-edits {{ args }}

# Clone the project into repo/: your own fork if you have one, or else the upstream. Then fetch the tags of the steps
setup url="":
    #!/usr/bin/env bash
    set -euo pipefail
    export GIT_TERMINAL_PROMPT=0
    upstream_url="https://github.com/{{ upstream }}/{{ project }}.git"
    if [ ! -d repo/.git ]; then
        url="{{ url }}"
        if [ -z "$url" ]; then
            url="$upstream_url"
            owner="$(git remote get-url origin 2>/dev/null | sed -nE 's#.*github\.com[:/]([^/]+)/.*#\1#p')"
            mine="https://github.com/$owner/{{ project }}.git"
            if [ -n "$owner" ] && [ "$owner" != "{{ upstream }}" ] && git ls-remote --exit-code "$mine" HEAD >/dev/null 2>&1; then
                url="$mine"
            fi
        fi
        echo "setup: cloning $url into repo/"
        git clone --quiet "$url" repo
    fi
    if ! git -C repo remote get-url upstream >/dev/null 2>&1; then
        git -C repo remote add upstream "$upstream_url"
    fi
    git -C repo fetch --quiet --tags --force upstream 2>/dev/null \
        || echo "setup: could not fetch the tags from {{ upstream }}/{{ project }}; using the ones repo/ has"
    echo "setup: repo/ is $(git -C repo remote get-url origin), with $(git -C repo tag -l 'step-*' | wc -l | tr -d ' ') steps"
    command -v quarto >/dev/null 2>&1 || echo "setup: Quarto is not on this machine; step 08 needs it: https://quarto.org/docs/get-started/"

# Check the notes and slides against the steps and moves of the project
check: setup
    {{ tw }} timewalk-check repo --replay worktree --toc toc.toml

# Make build/walk.pdf: the slides, one page each. The notes are for the page, `just present`
pdf:
    mkdir -p build
    {{ tw }} timewalk-pdf --toc toc.toml --walk show --title {{ project }} -o build/walk.pdf
