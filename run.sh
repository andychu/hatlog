#!/bin/bash
#
# Usage:
#   ./run.sh <function name>

set -o nounset
set -o pipefail
set -o errexit

deps() {
  # for 'swipl'
  sudo apt install swi-prolog-nox
}

demo() {
  for py in examples/*.py; do
    echo ---
    echo $py
    bin/hatlog $py
  done
}

"$@"
