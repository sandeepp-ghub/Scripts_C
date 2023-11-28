#!/bin/tcsh


## /proj/stc03c1m/release/IP/COMPHY_64G_PIPE6_X4_4PLL/IPREPO.rev1.1.0_02/synopsys/lib/COMPHY_64G_PIPE6_X4_4PLL_tt_0p75v_25c_typical.lib 
# /proj/stc03c1m/release/IP/COMPHY_64G_PIPE6_X4_4PLL/IPREPO.rev1.1.0_06/synopsys/lib/COMPHY_64G_PIPE6_X4_4PLL_tt_0p75v_25c_typical.lib 
set libfile = ""
set libfile = $1;

if ( ! -e $libfile ) then

    echo "(E): Invalid libfile specified: '$libfile'"

else 
    less $libfile \
	| \grep -e "  cell (" -e "  pin " -e "  related_pin" -e mode -e timing_type \
	| \grep -v "\/\*" \
	| sed -e 's/  mode/mode/' -e 's/ related_pin/related_pin/' \
	| awk '{if($0~/   pin /){printf "\n%s\n", $0} else {print $0}}' \
	| awk '{if($0~/  pin/){pin=$0; mode=""; related_pin=""; timing_type=""; rise_constraint=""; fall_constraint=""; } else if($0~/timing_type/){timing_type=$0} else if($0~/mode/){mode=$0} else if($0~/related_pin/){related_pin=$0; printf "%s %s %s %s\n", pin, mode, related_pin, timing_type} else {print $0}}' \
	| awk '{if(NF>0){print $0}}' \
	| awk '{if(($0~/related_pin/)&&($0~/timing_type/)){print $0} else if ($0~/cell/){print $0}}' \
	| column -t \
	| awk '{if($0!~/cell/){printf "  %s\n", $0} else {print $0}}' \
	| sort \
	| less
endif
