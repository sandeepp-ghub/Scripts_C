#!/bin/tcsh

if ( `echo $argv | grep sort_by_ep` != "" ) then
    set SORT_COL=2
else
    set SORT_COL=1
endif

if ( `echo $1 | grep .gz$` != "" ) then
    set CAT_CMD = "zcat"
else 
    set CAT_CMD = "cat"
endif

$CAT_CMD $1 | sed -n -e '/Startpoint/p' -e '/Endpoint/p' -e '/slack (VIOLATED)/p' -e '/slack (MET)/p' -e '/clocked by/p' -e '/removal check/p' -e '/for clock/p' \
    | sed -e 's/(//' -e 's/)//' \
    | sed -e 's/rising edge-triggered flip-flop/ Rising_FF/' -e 's/falling edge-triggered flip-flop/ Falling_FF/' -e 's/rising clock gating-check/ Rising_CG/' -e 's/falling clock gating-check/ Falling_CG/' -e 's/output port/ OUT/' -e 's/input port/ IN/' -e 's/removal check against rising-edge clock/Rising_Removal clocked by/' -e 's/removal check against falling-edge clock/Falling_Removal clocked by/' -e 's/for clock/clocked by/'  \
    | awk '{if ($0~/slack/){printf "%s\n", $NF} else if ($0~/clocked by/){printf " (%s:%s) --> ", $1, $NF} else {printf "%s ", $NF}}' \
    | sort -n -k 7 \
    | awk '{print NR, $0}' 

#    | sort -d -k $SORT_COL
#    | sort -r -k 5 \
