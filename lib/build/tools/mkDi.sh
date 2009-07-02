#!/bin/bash
# copies the .di files of the given module paths from the runtime into the "main" tango

die() {
    echo "$1"
    exit $2
}

tango_home=`dirname $0`/../..
DC_SHORT=
while [ $# -gt 0 ]
do
    case $1 in
        --help)
            echo "usage: mkDi.sh [--help] [--tango-dir tango/base/dir] [--dc dc] path/to/module/without/extension [module2...]"
            echo "copies the .di files of the given module paths from the runtime into the main tango"
            echo "directory dir excluding the given patterns."
            echo "The result is outputted as a make compatible assignement to the"
            echo "variable named var_name"
            echo "default: tango-dir=$tango_home"
            exit 0
            ;;
        --tango-dir)
            shift
            tango_home=$1
            ;;
        --dc)
            shift
            DC_SHORT=$1
            ;;
        *)
            break
            ;;
    esac
    shift
done

DC_SHORT=`$tango_home/lib/build/tools/guessCompiler.sh $DC_SHORT`

while [ $# -gt 0 ]
do
    found=
    for d in lib/common lib/compiler/${DC_SHORT} lib/compiler/shared lib/gc/basic ; do
        if [ -e "$tango_home/$d/${1}.d" ] ; then
            echo "$d/${1}.d -> ${1}.di"
            dirN=`dirname $tango_home/${1}`
            mkdir -p "$dirN"
            cp "$tango_home/$d/${1}.d" "$tango_home/${1}.di"
            found=1
            break
        elif [ -e "$tango_home/$d/${1}.di" ] ; then
            echo "$d/${1}.di -> ${1}.di"
            dirN=`dirname $tango_home/${1}`
            mkdir -p "$dirN"
            cp "$tango_home/$d/${1}.di" "$tango_home/${1}.di"
            found=1
            break
        fi
    done
    if [ -z "$found" ] ; then
        die "did not find source for $1" 1
    fi
    shift
done
