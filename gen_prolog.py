#!/usr/bin/env python3
#
# Given a Python function, parse it and generate a Prolog program to infer its
# type.  The rules are specified in pythonTypeSystem.pl.

import ast
import re
import sys
from collections import defaultdict


def log(msg, *args):
    if args:
        msg = msg % args
    print(msg, file=sys.stderr)


def to_snake_case(label):
    return re.sub(r'([a-z])([A-Z])', r'\1_\2', label).lower()


class Env:
    def __init__(self, values=None, parent=None):
        self.values = values or {}
        self.parent = parent

    def __getitem__(self, label):
        current = self
        while current is not None:
            if label in current.values:
                return current.values[label]
            current = current.parent

    def __setitem__(self, label, value):
        self.values[label] = value


NOT_SUPPORTED = defaultdict(set,
    FunctionDef={'keywords', 'starargs', 'kwargs'},
    BinOp={'op'},
    UnaryOp={'op'},
    AugAssign={'op'},
    Call={'keywords', 'starargs', 'kwargs'},
    For={'orelse'},
    Attribute={'ctx'}
)


class Flattener:
    def __init__(self, nodes):
        """
        Args:
          nodes: output list to append to
        """
        self.nodes = nodes 
        self.type_index = -1  # generate unique Prolog variables
        self.env = Env()

        # These three are used for recurisve calls.  Set in flatten_functiondef
        # and used in flatten_call.
        # TODO: Should they also be output params?  To hook up to main?
        self.args = []
        self.return_type = None
        self.function = ''

    def new_type(self):
        self.type_index += 1
        return 'Z%d' % self.type_index

    def flatten(self, node):
        if isinstance(node, list):
            return [self.flatten(e) for e in node]
        elif node is None:
            return 'v'
        else:
            # Dispatch to flatten_* function, based on node name.
            sub = getattr(
                self,
                'flatten_%s' % type(node).__name__.lower(),
                self.default)
            return sub(node)

    def default(self, node):
        f = [
            self.flatten(getattr(node, f))
            for f in node._fields
            if f not in NOT_SUPPORTED[type(node).__name__]
        ]

        node_type = self.new_type()
        self.nodes.append(
            ('z_%s' % to_snake_case(type(node).__name__), f, node_type))
        return node_type

    def _FlattenRecursiveCall(self, node):
        '''
        we know that functions return the same value
        prolog terms cant be rec so we =
        '''
        if len(node.args) != len(self.args):
            raise ValueError("%s expected %d args" % (len(self.args)))
        for a, (_, b) in zip(node.args, self.args):
            c = self.flatten(a)
            self.nodes.append(('=', [c], b))
        return self.return_type

    def flatten_call(self, node):
        if isinstance(node.func, ast.Name) and node.func.id == self.function:
            return self._FlattenRecursiveCall(node)

        elif isinstance(node.func, ast.Attribute):
            return self.flatten_method_call(node)

        else:
            function = self.flatten(node.func)
            args = [self.flatten(e) for e in node.args]
            return_type = self.new_type()

            if (isinstance(node.func, ast.Name) and
                node.func.id not in self.env.values): # named
                self.nodes.append(('z_call', [node.func.id, args], return_type))
            else:
                self.nodes.append(('z_fcall', [function, args], return_type))

            return return_type

    def flatten_subscript(self, node):
        value = self.flatten(node.value)
        node_type = self.new_type()

        if isinstance(node.slice, ast.Index):
            index = self.flatten(node.slice.value)
            self.nodes.append(('z_index', [value, index], node_type))

        else:
            lower = self.flatten(node.slice.lower) if node.slice.lower else None
            upper = self.flatten(node.slice.upper) if node.slice.upper else None
            if lower and upper is None:
                upper = lower
            elif lower is None and upper:
                lower = upper
            else:
                raise ValueError(
                    'hatlog expects only slice like [:x], [x:] or [x:y]')
            self.nodes.append(('z_slice', [value, lower, upper], node_type))
        return node_type

    def flatten_num(self, node):
        if isinstance(node.n, int):
            return 'int'
        else:
            return 'float'

    def flatten_str(self, node):
        return 'str'

    def flatten_compare(self, node):
        if len(node.comparators) != 1:
            raise ValueError("hatlog supports only 1 comparator")
        if isinstance(node.ops[0], ast.Eq):
            op = 'z_eq'
        else:
            op = 'z_cmp'
        a = self.flatten(node.left)
        b = self.flatten(node.comparators[0])
        node_type = self.new_type()
        self.nodes.append((op, [a, b], node_type))
        return node_type

    def flatten_list(self, node):
        if len(node.elts) == 0:
            sub_types = [self.new_type()]
        else:
            sub_types = [self.flatten(a) for a in node.elts]
        node_type = self.new_type()
        self.nodes.append(('z_list', sub_types, node_type))
        return node_type

    def flatten_method_call(self, node):
        '''
        A call with an attribute as func
        '''
        receiver = self.flatten(node.func.value)
        args = [self.flatten(arg) for arg in node.args]
        node_type = self.new_type()
        self.nodes.append(
            ('z_method_call', [receiver, node.func.attr, args], node_type))
        return node_type

    def flatten_dict(self, node):
        if len(node.keys) == 0:
            sub_types = [self.new_type(), self.new_type()]
        else:
            sub_types = zip([self.flatten(a) for a in node.keys],
                            [self.flatten(b) for b in node.values])
        node_type = self.new_type()
        self.nodes.append(('z_dict', sub_types, node_type))
        return node_type

    def flatten_assign(self, node):
        if len(node.targets) != 1:
            raise ValueError("assignment normal")
        node.targets = node.targets[0]
        return self.default(node)

    def flatten_name(self, node):
        if node.id in ('True', 'False'):
            return 'bool'
        elif node.id == 'None':
            return 'void'
        else:
            name_type = self.env[node.id]
            if not name_type:
                name_type = self.new_type()
                self.env[node.id] = name_type
            return name_type

    def flatten_functiondef(self, node):
        self.args = [(arg.arg, self.new_type()) for arg in node.args.args]
        self.return_type = 'X'
        self.function = node.name
        self.env[node.name] = node.name
        self.env = Env(dict(self.args), self.env)
        for child in node.body:
            self.flatten(child)
        self.env = self.env.parent

        arg_types = [prolog_type for _, prolog_type in self.args]
        self.nodes.append(('z_function', arg_types, self.return_type))

        return self.env[node.name]

    def flatten_expr(self, node):
        return self.flatten(node.value)

    def flatten_return(self, node):
        v = self.flatten(node.value)
        self.nodes.append(('=', [v], self.return_type))
        return v

# BinOp(2, BinOp(b, a))

# bin_op(X1, X2, X3)
# bin_op(int, X3, X4)



def generate_arg(arg):
    if isinstance(arg, str):
        return arg
    else:
        return '[%s]' % ', '.join(generate_arg(a) for a in arg)


def generate_fun(other_nodes):
    n = len(other_nodes)
    # pred_name is something like z_assign, z_method_call, or even '=' for
    # return?
    for i, (pred_name, args, b) in enumerate(other_nodes):
      args_code = ', '.join(generate_arg(x) for x in args + [b])

      # Last statement needs a period; others have cmomas.
      punct = '.' if i == n-1 else ','

      print('    %s(%s)%s' % (pred_name, args_code, punct))

    print('')


def generate_prolog(nodes, name, out_file):
    print('''\
:- initialization main.

:- use_module(pythonTypeSystem).
:- use_module(prettyTypes).
''')

    # As a result of flattening, the last node is the root.
    other_nodes, func_node = nodes[:-1], nodes[-1]

    print('f(%s, [%s], %s) :-' % (name, ', '.join(func_node[1]), func_node[-1]))

    generate_fun(other_nodes)
    log('nodes %s', nodes)

    # NOTE: There is some spurious output I hvaen't tracked down for
    # examples/map.py.
    # I commented out writeln() call but can't find another.

    # NOTE: Why is the function type Z2 -> Z3?  Prettified to Y -> Z.
    # I guess in the ast walker we know those are and the second and third
    # thign.

    # This could be structured in a different way, where Z0 is node.args and Z1
    # is node.rets, or something.

    print('''main :-
        f(%s, Z0, Z1),
        unvar(Z0, Z1, Z2, Z3, Z4), %% replace free vars with names
        pretty_args(Z2, Y),
        pretty_type(Z3, Z),
        pretty_generic(Z4, X),
        format('~a::', [X]),
        write(Y),
        write(' -> '),
        write(Z),
        write('\\n'),
        halt.
main :-
    halt(1).
''' % name, end='')


def main(argv):
    py_path = argv[1]
    with open(py_path) as f:
        source = f.read()

    root = ast.parse(source)

    # TODO: Can we relax this?
    if len(root.body) != 1 or not isinstance(root.body[0], ast.FunctionDef):
        raise ValueError("hatlog expects a single function")

    nodes = []
    fl = Flattener(nodes)
    func_body = root.body[0]
    fl.flatten_functiondef(func_body)

    generate_prolog(nodes, func_body.name, py_path)


if __name__ == '__main__':
  main(sys.argv)
