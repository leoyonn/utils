#!/usr/bin/env python
#coding=utf-8

import yaml, os, sys, commands, socket
from time import sleep

# WIDTH = commands.getoutput("resize | head -n 1 | awk 'BEGIN{FS=\"=|;\"} {print $2}'")
WIDTH = commands.getoutput("stty size| awk '{print $2}'")
BAR1 = ''.join(['-' for i in range(int(WIDTH) - 1)])
BAR2 = ''.join(['=' for i in range(int(WIDTH) - 1)])

def p(o) :
    print BAR2
    print o 

def p1(o) :
    print BAR1
    print o 

'''
@param dir: which directory to compile
@param env: which environment to compile to (onebox/staging/sandbox/production)
@param U: should use -U in mvn?
'''
def compile(module, dir, env, U, loglevel):
    U = '-U' if U else ''
    cmd = (('cd %(dir)s && mvn %(U)s' if module == 'xmpush-frontend' else 'mvn %(U)s -pl %(module)s') \
        + ' -am clean package install -Dmaven.test.skip=true' \
        + ' -P%(env)s -D%(env)s=true -Dloglevel=%(loglevel)s' \
        + ' | grep -i --color error') % locals() 
    p('compiling by cmd:[%s]\n' % cmd)
    ok = 0 != os.system(cmd) # grep -i: success if has error-output
    os.system('rm -f %(dir)s/target/library/libthrift*.jar;' % locals())
    if not ok:
        p('compile erorr! check compile result for more detail...\n')
        sys.exit(1)
    return cmd
    
def load_yaml(path):
    file = open(path)
    content = yaml.load(file)
    file.close()
    return content

def sleep_count(n):
    if n > 0:
        p('First host released, will sleep [%.2f] for you to watch results!\n' % n)
        while n > 0:
            print n,'...',
            sleep(1)
            n = n - 1
            sys.stdout.flush()
        print '0! What a sound sleep!!!\n'
    return n

def git_v():
    return commands.getoutput('git log -1 HEAD --pretty=format:"%h"')

def localhost():
    return socket.gethostname()

def run(cmd, desc = ''):
    p('Excuting [%s] by following command: \n%s\n%s\n%s\n' % (desc, BAR1, cmd, BAR1))
    os.system(cmd)

# get full-path of $path
def full_path(path):
    if not path.startswith('/'):
        path = os.getcwd() + '/' + path
    return path

