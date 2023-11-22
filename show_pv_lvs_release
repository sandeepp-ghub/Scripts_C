#!/bin/tcsh

# Generic script to summarize design data for different blocks in the project using the latest release

set release_area = /proj/$MRVL_PROJECT/release

echo "#$release_area"

set designs = `ls -1 $release_area | grep -v work`

foreach design ( $designs )
    #echo $design
    set latest_release = `ls -1 $release_area/$design | tail -n 1`
    set pv_lvsq_dir = $release_area/$design/$latest_release/pv.signoff.lvsq/report
    if ( -e $pv_lvsq_dir ) then;
	echo ""
	echo -n "$design $latest_release | "
	cd $pv_lvsq_dir
	if ( -e pv.signoff.lvsq.sum ) then
	    # Get the Count of instances from the invcui.post.opt report
	    \grep -c "Open circuit" pv.signoff.lvsq.sum | awk '{printf "LVS_Opens: %s  ", $1}'
	    \grep -c "SHORT" pv.signoff.lvsq.sum | awk '{printf "LVS_Shorts: %s  ", $1}'
	endif
	cd -
    endif
end
