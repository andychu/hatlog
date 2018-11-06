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

    case $py in 
      */pathjoin.py|*/inc3.py)
        # This doesn't work yet
        echo "*** Skipping $py"
        continue
        ;;
    esac

    local out=_tmp/$(basename $py .py).pl
    ./gen_prolog.py $py > $out
    ls -l $out
  done
}

# Use SWI Prolog.
#
# NOTE: On Ubuntu, I get GNU Prolog 1.3.0 from 2007!  It doesn't even support
# shebang lines!!!
#
# http://www.gprolog.org/manual/html_node/gprolog007.html#sec11
# Since version 1.4.0 it is possible to use a Prolog source file as a Unix
# script-file (shebang support). A PrologScript file should begin as follows:
#!/usr/bin/gprolog --consult-file

# Run prolog and show inferred signature
infer-sig() {
  rm -f -v _tmp/*.txt
  for pl in _tmp/*.pl; do
    echo --- $pl ---
    # Keep going after failure
    if ! swipl -s $pl > _tmp/$(basename $pl .pl).txt; then
      echo
      echo "*** failed to infer a type for $pl ***"
      echo
    fi
    echo
  done
  head _tmp/*.txt
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

example() {
  local name=${1:-fib}
  ./gen_prolog.py examples/$name.py > _tmp/$name.pl

  # This just prints warnings and no output?
  swipl -s _tmp/$name.pl
}

pathjoin() {
  ./gen_prolog.py examples/pathjoin.py > _tmp/pathjoin.pl

  # This just prints warnings and no output?
  swipl -s _tmp/pathjoin.pl
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
