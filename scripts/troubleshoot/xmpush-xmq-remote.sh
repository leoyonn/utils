#!/usr/bin/env bash

# Time-stamp: <2014-02-17 11:20:37 Monday by ahei>

# @file ejabberd-remote.sh
# @version 1.0
# @author ahei

home=`cd $(dirname "$0") && pwd`

$home/remote.sh -f $home/xmpush-xmq-hosts "$@"
