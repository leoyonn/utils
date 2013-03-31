#!/bin/env python
# -*- coding: utf-8 -*-

# Extract (user, rest, vote) data from log
# caofx 2011-06-01 17:25:22

import sys, re

re_user = re.compile(r"\[userid=(.*?)\]");
re_rests = re.compile(r"rests=\[(.*?)\]");
re_rest = re.compile(r"\{\"id\":\"(.*?)\",\"vote\":(.*?)\}");
for line in sys.stdin:
    if line.find("callback=test") >= 0:
        continue
    m = re_user.search(line)
    if m == None: continue
    userid = m.group(1)
    m = re_rests.search(line)
    if m == None: continue
    m = re_rest.findall(m.group(1))
    for r in m:
        if r != None and len(r) == 2:
            print userid + "," + r[0] + "," + r[1]
