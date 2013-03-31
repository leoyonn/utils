#!/bin/bash
# 去除svn st 中的+
svn up
echo ------------------------------before-------------------------
svn st > tmp
cat tmp
echo ---------------------------processing------------------------
awk '{
    if(NF == 3 && $2 == "+") {
        print "remove + of "$3;
        system("svn revert " $3);
        system("svn add " $3);
    }
}' tmp
rm tmp
echo -----------------------------after---------------------------
svn st
echo done!
