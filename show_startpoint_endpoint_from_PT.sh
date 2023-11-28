#!/bin/tcsh

if ( `echo $argv | grep sort_by_ep` != "" ) then
    set SORT_COL=2
else
    set SORT_COL=1
endif

alias fp  "perl -pe 's/^/###JUNK/g;' | perl -pe 'chomp; s/Startpoint/\n Startpoint/g;' | !* | perl -pe 's/###JUNK/\n/g;'"
alias fpr "perl -pe 's/^/###JUNK/g;' | perl -pe 'chomp; s/Startpoint/\n Startpoint/g;' | egrep -v 'COMB' | egrep -v '_IN' | egrep -v '_OUT' | perl -pe 's/###JUNK/\n/g;'"


set filename = `echo $1 | sed 's/sum.gz/rpt.gz/'`

# NOTE: The 1st awk is required to account for lines that have the clock information on the same line as the startpoint
zcat $filename | fpr | awk '{if(($0~/input port/)&&($3!~/clocked/)){print $1, $2; for (i=3;i<=NF;i++){printf "%s ", $i}; printf "\n"; } else {print $0}}' \
    | sed -n -e '/Startpoint/p' -n -e '/Endpoint/p' -n -e '/slack (VIOLATED)/p' -n -e '/clocked by/p' -n -e '/removal check/p' \
    | sed -e 's/(//' -e 's/)//' \
    | sed -e 's/rising edge-triggered flip-flop/ Rising_FF/' -e 's/falling edge-triggered flip-flop/ Falling_FF/' -e 's/rising clock gating-check/ Rising_CG/' -e 's/falling clock gating-check/ Falling_CG/' -e 's/output port/ OUT/' -e 's/input port/ IN/' -e 's/removal check against rising-edge clock/Rising_Removal clocked by/' -e 's/removal check against falling-edge clock/Falling_Removal clocked by/'  \
    | awk '{if($0!=prev){print $0}; prev=$0}' \
    | awk '{if($3~/OUT/){print $1, $2; print $3, $4, $5, $6, $7} else {print $0}}' \
    | awk '{if ($0~/slack/){printf "%s\n", $NF} else if ($0~/clocked by/){printf " (%s:%s) --> ", $1, $NF} else {printf "%s ", $NF}}' \
    | awk '{print NR, $0}' 

#    | sort -d -k $SORT_COL
#    | sort -r -k 5 \


#| awk '{if($0~prev){print $0; prev=$0} else {prev=$0}}'
#| awk '{if($0!=prev){print $0; prev=$0}'
