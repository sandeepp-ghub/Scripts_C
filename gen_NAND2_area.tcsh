#!/bin/tcsh

# Generic script to summarize design data for different blocks in the project using the latest release

set release_area = /proj/$MRVL_PROJECT/release

echo "#$release_area"

#set designs = `ls -1 $release_area | grep -v work | grep -e pem -e fpide`
set designs = `ls -1 $release_area | grep -v work`

foreach design ( $designs )
    #echo $design
    set latest_release = `ls -1 $release_area/$design | tail -n 1`
    set dc_dir = $release_area/$design/$latest_release/dc.syn/report
    if ( -e $dc_dir ) then;
	echo ""
	echo -n "$design/$latest_release | "
	cd $dc_dir

	echo -n "$dc_dir/*qor.rpt.gz | "

	# Get the VT ratios from the invcui.post.opt design
	zgrep "Cell Area:" *qor.rpt.gz | awk '{printf "%s / 0.03213 = %.0f\n",   $0, $NF / 0.03213}'
	cd -
    endif
end
