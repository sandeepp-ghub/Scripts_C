#!/bin/tcsh

#~/scripts/show_diskhogs.tcsh | awk '{if($5>100000){print $0}}' | sort -k 5 -n | awk '{printf "# %15s %s\n#rm %s\n\n", $5, $NF, $NF}'

foreach fname ( `find .` )
    if ( ! -d $fname && -s $fname ) then
	# Only process files, not directories
	#echo "$fname"
	ls -l $fname | awk '{printf "%10s %2s %20s %5s %20s %5s %5s %5s %s\n", $1, $2, $3, $4, $5, $6, $7, $8, $9}'
    else
	#echo "$fname <===== skip"	
    endif

end
