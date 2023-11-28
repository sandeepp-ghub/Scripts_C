#!/bin/ksh

# Run this script from $USER/impl/<design_dir>/.

vt_groups="baseline only_svt only_lvt only_ulvt dc_lvtll_inv_lvtll_lvt_svt dc_lvtll_inv_lvtll_lvt_svt_ulvt"

for vt_group in $vt_groups
do
    for fname in $(ls ./track.${vt_group}/invcui.post/logfiles/*inv.log)
    do
	# Check for a sufficently high filesize to avoid capturing interactive logs
	if [[ `ls -trl $fname | awk '{if($5 > 1000000){print $0}}'` != "" ]]; then
	    echo "-------------------------------------------------------------------------------------------------------------------------"
	    echo $fname
	    DRC_EXPR=`grep -i "number of DRC violations" $fname | tail -n 1 | awk -F# '{print $2}'`
	    #echo $DRC_EXPR
	    grep "$DRC_EXPR" $fname -A 20
	fi
    done
done
