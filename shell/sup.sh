#!/bin/bash
####################################################################
## 将当前文件夹中svn本地改动(如A/A+/M/D)传输到host指定的位置 
## 会改动：
## 1. 去除svn st 中A+的+号；
## 2. 将 A/A+/M/R 文件传输到host，如果A为目录，则会创建目录；
## 3. 将D标识的文件在host上删除；
##
## @author liuyang
####################################################################

host="nc009x.corp.youdao.com"
dir="/disk1/liuyang/silmaril/"

svn up
svn st > tmp
awk -v host=$host -v dir=$dir '
function isDir(file) {
    r = system(" if [ -d "file" ]; then return 1; else return 0; fi");
    return r;
}

function A(file) {
    if (isDir(file)) {
        cmd = "ssh "host" \"mkdir "dir""file"\"";
        print cmd;
        system(cmd);
    } else {
        cmd = "scp "file" "host":"dir""file;
        print cmd;
        system(cmd);
    }
}

function Aplus(file) {
    printf("remove + of "file": ");
    system("svn revert "file);
    system("svn add "file);
    A(file);
}

function M(file) {
    if (isDir(file)) {
        print "Ignore dir modification: "file;
        return;
    }
    file = $2;
    cmd = "scp "file" "host":"dir""file;
    print cmd;
    system(cmd);
}

function D(file) {
    file = $2;
    cmd = "ssh "host" \"rm -rf "dir""file"\"";
    print cmd;
    system(cmd);
}

{
    printf($0": \n\t");

    ## 1. 删除A+中的+，并scp
    if(NF == 3 && $2 == "+") {
        Aplus($3);
    }

    ## 2. 创建A的目录
    else if($1 == "A") {
        A($2);
    }

    ## 3. 将A/M/R的文件 scp上去
    else if($1 == "M" || $1 == "R") {
        M($2);
    }

    ## 4. 将D的文件或文件夹在host上删除
    else if($1 == "D") {
        D($2);
    } 

    ## 5. 其它
    else {
        print "svn status ignored: "$0;
    }
}' tmp
rm tmp
echo done!
