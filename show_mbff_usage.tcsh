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
	echo -n "$design $latest_release | "
	cd $post_opt_dir
	if ( -e invcui.post.opt.mbff.rpt.gz ) then
	    # Get the Count of instances from the invcui.post.opt report
	    zgrep : invcui.post.opt.mbff.rpt.gz | \grep -v flip-flop | sed 's/: /:/' | sed 's/ /_/g' | sed 's/__*/_/g' | sed 's/_:/:/g' | awk '{printf "%s ", $0}' 
	endif
	cd -
    endif
end
