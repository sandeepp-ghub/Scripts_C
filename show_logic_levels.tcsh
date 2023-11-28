#!/bin/tcsh

# Generic script to summarize design data for different blocks in the project using the latest release

set release_area = /proj/$MRVL_PROJECT/release

echo "#$release_area"

set designs = `ls -1 $release_area | grep -v work`

foreach design ( $designs )
    set latest_release = `ls -1 $release_area/$design | tail -n 1`
    set dc_dir = $release_area/$design/$latest_release/dc.syn/report
    if ( -e $dc_dir ) then;
	echo ""
	echo "-------"
	echo "$design $latest_release "
	cd $dc_dir
        \zgrep -e "Timing Path Group" -e "Levels of Logic:" *qor.rpt.gz | sed -e 's/Levels of Logic:/Levels_of_Logic:/' -e 's/Timing Path Group/Timing_Path_Group/' | awk '{if($0~/Group/){printf "%s ", $0} else {print $0}}'
	cd -
    endif
end
