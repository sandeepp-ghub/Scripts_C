#!/bin/tcsh

cat *cts_report_tree_structure.clock_tree_structure.rpt | \grep -A 2 'Clock tree' | awk '{if($0~/--/){printf "\n"} else {printf "%s | ", $0}}' | column -t | less
