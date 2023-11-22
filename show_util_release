#!/bin/tcsh

# Generic script to summarize design data for different blocks in the project using the latest release

set release_area = /proj/$MRVL_PROJECT/release

echo "#$release_area"

set designs = `ls -1 $release_area | grep -v work`

foreach design ( $designs )
    #echo $design
    set latest_release = `ls -1 $release_area/$design | tail -n 1`
    set post_opt_dir = $release_area/$design/$latest_release/invcui.post.opt/report
    if ( -e $post_opt_dir ) then;
	echo ""
	echo -n "$design/$latest_release "
	cd $post_opt_dir
	# Get the VT ratios from the invcui.post.opt design
	#zgrep area invcui.post.opt.vt_groups.rpt.gz | \grep ratio | sed -e 's/design.area.vth://' -e 's/ratio /ratio:/' -e 's/exclude clockpath/exclude_clockpath/' | sort -r | awk '{printf "%s ", $0}' 

	
	#zgrep -i -e "Placement Density:"  -e "Violation:" *check*place*.gz | sed -e 's/ Density:/_Density: /' -e 's/ Violation: /_Violation:/' -e 's/Pin Access/Pin_Access/' -e 's/Vertical /Vertical_/' -e 's/Track /Track_/g' | awk '{printf "%s ", $0}'

	zgrep -i -e "Placement Density:"  *check*place*.gz | sed -e 's/ Density:/_Density: /' -e 's/%/% /' | awk '{printf "%s ", $0}'
	cd -
    endif
end
