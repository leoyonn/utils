#!/bin/env python
# -*- coding: utf-8 -*-

#Utility for outweb deploying

#Author: Weng Cijie 
#Contact: wengcj@rd.netease.com ext 8956
#Date: Fri Jun  8 09:52:29 CST 2007

#Modified by caofx 2010-01-04 10:23:56
import sys, os
resin_path = "../resin-3.0.21"
code_path = "."
war_file = "build/silmaril.war"
resin_args = "-J-Xmx8000M -J-Xms4000M" # -Dorg.apache.commons.logging.simplelog.defaultlog=info"

def usage (argv):
    print argv[0] + " {start|stop|restart|ant [ant-args]|svnup|log} (ant-args such as '-Divy.bypass=true')"

def svnup():
    return os.system("cd %s && svn up && cd -" % code_path)

def ant(arg = ""):
    ret = os.system("cd %s && ant war %s && cp %s/%s %s/webapps/ROOT.war && cd -" % (code_path, arg, code_path, war_file, resin_path))
    if ret == 0:
        ret = restart()
    return ret

def start():
    print "starting web..."
    cmdstr="%s/bin/httpd.sh start %s" % (resin_path, resin_args)
    print cmdstr
    return os.system(cmdstr)

def stop():
    print "stopping web..."
    cmdstr="%s/bin/httpd.sh stop" % resin_path
    print cmdstr
    return os.system(cmdstr)

def restart():
    ret = stop()
    if ret == 0:
        ret = start()
    return ret

def log():
    cmdstr="tail -F %s/log/stdout.log" % resin_path
    print cmdstr
    return os.system(cmdstr)

def main(argv):
    if len(argv) < 2:
        usage(argv)
        return 1
    if argv[1] in ('start', 'stop', 'restart', 'log', 'ant', 'svnup', 'vmup'):
        if sys.argv[1] == "restart":
            return restart()
        if sys.argv[1] == "start":
            return start()
        if sys.argv[1] == "stop":
            return stop()
        if sys.argv[1] == "ant":
            if len(argv) == 2:
                return ant()
            else:
                return ant(argv[2])
        if sys.argv[1] == "log":
            return log()
        if sys.argv[1] == "svnup":
            return svnup()
    else: 
        usage(sys.argv)
        return 1

if __name__ == "__main__":
    sys.exit(main(sys.argv))
