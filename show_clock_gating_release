#!/bin/tcsh

# Generic script to summarize design data for different blocks in the project using the latest release

set release_area = /proj/$MRVL_PROJECT/release

echo "#$release_area"

set designs = `ls -1 $release_area | grep -v work`

foreach design ( $designs )
    #echo $design
    set latest_release = `ls -1 $release_area/$design | tail -n 1`
    set dc_syn_dir = $release_area/$design/$latest_release/dc.syn/report
    if ( -e $dc_syn_dir ) then;
	echo ""
	echo -n "$design $latest_release | "
	cd $dc_syn_dir

	zgrep -e "Number of Clock gating elements" -e "Number of Gated registers" -e "Number of Ungated registers" dc.syn.finish.setup.func:max*.clock_gating.rpt.gz | sed 's/|//g' | sed -e 's/Number of /Number_of_/g' -e 's/Clock gating elements/Clock_Gating_elements/' -e 's/Gated registers/Gated_registers/' -e 's/Ungated registers/Ungated_registers/' |  awk '{printf "| %s ", $0}'

	cd -
    endif
end
