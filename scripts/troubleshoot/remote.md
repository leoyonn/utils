简介
=========

我们调查问题时, 经常需要到多台机器上执行同一条命令, 比如grep日志, 手工一台一台机器的ssh然后grep非常麻烦, remote.sh就是用来解决此烦恼的. 它可以自动的到多台机器上执行同一条命令, 或者把某文件拷贝到多台机器上.

用法
===

批量执行命令
-----------
<pre>
remote.sh -f HOST-FILE COMMAND
</pre>
HOST-FILE为要去执行的机器列表文件, 每行一个机器名或者ip, COMMAND为要执行的命令.

下面这条命令到所有的机器上执行date命令:
<pre>
remote.sh -f xmpush-hosts date
</pre>

默认情况下,　是并行去所有机器上执行命令,　如果需要串行执行的话,　使用"-g"选项.
直接运行remote.sh可以查看更多选项.

向多台机器拷贝文件
---------------
<pre>
remote.sh -f HOST-FILE -F LOCAL-FILE -d DST-FILE
</pre>
LOCAL-FILE为本机文件,　DST-FILE为远程机器上的目标文件.

下面这条命令拷贝当前机器上的/usr/bin/remote.sh到远程机器上/usr/bin目录下:
</pre>
remote.sh -f xmpush-hosts -F /usr/bin/remote.sh -d /usr/bin
</pre>

几个快捷命令
==========
<pre>
xmpush-remote.sh COMMAND
</pre>
到所有xmpush机器上执行命令COMMAND
grep所有registration模块日志:
<pre>
xmpush-remote.sh "fgrep 50010000444 /data/soft/xmpush-services/logs/registration/registration.log"
</pre>

<pre>
ejabberd-remote.sh COMMAND
</pre>
到所有ejabberd机器上执行命令COMMAND
grep所有ejabberd的日志:
<pre>
ejabberd-remote.sh "cd /data/scribe/ && fgrep 50010000444 thisisoverwritten-2013-12-26_00080"
</pre>
