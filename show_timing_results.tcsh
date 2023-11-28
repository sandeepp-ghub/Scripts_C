#!/bin/tcsh

# Grep the  pt.signoff/timing_rundir/reports/*qor.csv files; 
# Ignore the I/O timing
# Replace the ":" with ','
# Columnize the data with "," as the field separator
# Use the 'Path_group' text as a record separator
#grep -e WNS -e max -e min pt.signoff/timing_rundir/reports/*func*qor.csv \
grep -e WNS -e max -e min pt.signoff/timing_rundir/reports/*qor.csv \
    | sed -e 's/reports\// /' -e 's/_qor.csv/_failing_reg2reg_paths.rpt.gz/' -e 's/_func/ func/' -e 's/_scan/ scan/' | awk '{printf "%sreports/%s\n", $1, $3}' \
    | grep -v PUTS \
    | sed 's/:/ /' \
    | sed 's/,/ /g' \
    | awk '{print $1, $2, $3, $7, $8, $9}' | sed 's/ / | /g' \
#    | awk '{for (i=1; i<10; i++) {printf "%s | ", $i}; print ""; }' \
    | column -t \
    | awk '{if($0~/Path_group/){print "###"; print $0} else {print $0}}' \
    | awk 'BEGIN {RS="###";} {printf "%s\n", $0}'
