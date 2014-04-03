#!/usr/bin/awk -f

# Time-stamp: <2014-01-23 10:50:57 Thursday by ahei>

BEGIN {
    FS = "\t"
    OFS = "\t"
}

{
    module = $1
    num = $2
    exception = $3

    if (preModule != "" && (exception != preException || module != preModule))
    {
        print preModule, nums, preException
        nums = 0
    }

    nums += num
    
    preModule = module
    preException = exception
}

END {
    if (preModule)
    {
        print preModule, nums, preException
    }
}
