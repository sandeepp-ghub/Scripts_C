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
zcat $filename | fpr 

#    | sort -d -k $SORT_COL
#    | sort -r -k 5 \


#| awk '{if($0~prev){print $0; prev=$0} else {prev=$0}}'
#| awk '{if($0!=prev){print $0; prev=$0}'
