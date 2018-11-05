#!/bin/bash
#
# Usage:
#   ./run.sh <function name>
#
# Example:
#   ./run.sh all   # generate prolog, run it, and show inferred signature


set -o nounset
set -o pipefail
set -o errexit

deps() {
  # for 'swipl'
  sudo apt install swi-prolog-nox
}

# OLD
demo() {
  for py in examples/*.py; do
    echo ---
    echo $py
    bin/hatlog $py
  done
  ls -l examples
}

# Generate prolog source from Python
gen-prolog() {
  mkdir -p _tmp
  for py in examples/*.py; do
    echo ---
    echo $py
    #bin/hatlog $py

    local out=_tmp/$(basename $py).pl
    PYTHONPATH=. hatlog/prolog.py $py > $out
    ls -l $out
  done
}

# Run prolog and show inferred signature
infer-sig() {
  rm -f -v examples/*.txt
  for pl in _tmp/*.pl; do
    echo --- $pl ---
    swipl -s $pl
    echo
  done
  head examples/*.txt
}

all() {
  gen-prolog
  infer-sig
}

count() {
  # Only 278 lines
  find hatlog -name '*.py' | xargs wc -l | sort -n

  echo

  # Only 161 lines
  wc -l *.pl
}

"$@"
