#!/usr/bin/python

# ParseAssignFlags() in word_compile.py in oilshell/oil has this structure.
#
# It looks at each character of a list of strings.
#
# hatlog infers something too abstract for this.  It gets somewhat confused
# with double quoting.

def last(flag_args):
  for arg in flag_args:
    for char in arg:
      x = char
  return x

#print(last([1, 2, 3]))
