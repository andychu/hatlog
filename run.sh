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
    ./gen_prolog.py $py > $out
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

compare-gold() {
  for gold in gold/*.pl; do
    if diff -u $gold _tmp/$(basename $gold); then
      echo OK
    else
      return 1
    fi
  done
  echo 'PASS'
}

all() {
  gen-prolog
  compare-gold
  infer-sig
}

count() {
  # Only 278 lines
  wc -l *.py
  echo

  # Only 161 lines
  wc -l *.pl
}

"$@"
