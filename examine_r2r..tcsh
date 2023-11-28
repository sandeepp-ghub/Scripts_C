#!/bin/tcsh

alias fp = "perl -pe 's/^/###JUNK/g;' | perl -pe 'chomp; s/Startpoint/\n Startpoint/g;' | !* | perl -pe 's/###JUNK/\n/g;'"

zcat $1 | fp egrep -v 'COMB' | fp egrep -v '_IN' | fp egrep -v '_OUT' | less
