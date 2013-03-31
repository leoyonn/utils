#coding=utf-8
'''
Created on 2012-7-18
读入url文件，将其中的每一条url发送访问请求

@author: liuyang
'''

import urllib   
import datetime
import sys 
import threading

def worker(pid, urls):
    count = 0
    for url in urls:
        time = datetime.datetime.now();
        urllib.urlopen(url);
        time = datetime.datetime.now() - time;
        print 'pid.', pid, ': [', count, ', ', time, '], url: ', url;
        count = count + 1;

def run(urlfile, nworker):
    lines = open(urlfile, 'r').readlines();
    count = 0;
    worker_urls = []
    for i in range(0, nworker):
        worker_urls.append([])
    for line in lines:
        worker_urls[count % nworker].append(line)
        count = count + 1
    
    time = datetime.datetime.now();
    tworkers = []
    for i in range(0, nworker):
        tworker = threading.Thread(target = worker, args = (i, worker_urls[i]))
        tworkers.append(tworker)
        tworker.start()

    for i in range(0, nworker):
        threading.Thread.join(tworkers[i])
        
    time = datetime.datetime.now() - time
    print 'all: [', time, '] seconds.'

run(sys.argv[1], int(sys.argv[2]))
