#!/bin/bash

# 将当前文件夹中svn状态为A或M的文件/文件夹传输到如下host位置：
todir=$1
svn up
ST_NULL=-1
ST_IGNORE=0
ST_UP=1
st=$ST_IGNORE

for line in `svn st`; do
    if [ "$line" = "A" -o "$line" = "M" ]; then
        st=$ST_UP ;
    elif [ "$st" = "$ST_UP" ] ; then
        echo cp  $line $host$line ;
        if [ "${line:(-5)}" != ".java" ] ; then
            echo this is a dir, do not scp.
        else
            cp $line $todir$line ;
        fi
        st="$ST_NULL"
    fi
done

echo done!
