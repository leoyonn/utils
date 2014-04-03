#!/usr/bin/env python
#coding=utf-8
#
# @author leo [liuy@xiaomi.com]
# @date 2013-12-04
# generate from a template and parameters to a new config file.
#################################################################################

import os, sys, string
from release_utils import p1 as p, load_yaml, full_path

def gen_conf(args):
    # check input validation
    if type(args) != list or len(args) < 2:
        f = full_path(__file__)
        p(('Usage: (%s)? ${template-file-path} ${output-file-path} ${parameters}\n\t' +
            'but your input is %s') % (f, args))
        sys.exit(1)

    # read parameters as x=123 y=456...
    params = {}
    for pair in args[2:]:
        param = pair.split('=')
        params[param[0]] = param[1]

    p('All parameters for configure file: %s' % params)

    # read template-file with variable ${x} ${y} inside
    input = open(args[0], 'r')
    lines = string.Template(''.join(input.readlines()))
    input.close()

    lines = lines.substitute(params)
    output = open(args[1], 'w')
    output.writelines(lines)
    output.close()

    p('Done! generate new configure file into %s.' % full_path(args[1]))
    p('')

if __name__ == '__main__':
    gen_conf(sys.argv[1:])
