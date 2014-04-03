#!/usr/bin/awk -f

# Time-stamp: <2014-01-21 16:20:06 Tuesday by ahei>

BEGIN {
    FS = "\t"
    OFS = "\t"
}

{
    module = $1
    num = $2
    exception = $3

    if (module != preModule)
    {
        printf "Error logs of module `%s':\n", module
    }

    print "", num, exception
    
    preModule = module
}
