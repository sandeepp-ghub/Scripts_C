alias gon get_object_name
alias gs dbget selected.name -e
alias dh dehighlight
alias gon get_object_name
alias gc get_cells
alias si selectInst
alias ds deselectAll

proc checkGrp {} {
	dh
	set pin [lsort -dic [gon [get_pins -of [gs] -filter "(is_data == true) && (full_name !~ */RS*)"]]]
	set opPin [get_pins -quiet  -of [get_nets -of $pin] -filter "direction == out"]
	set fanouts [gc -of [all_fanout -from $opPin -end]]
	ds ; si [gon $fanouts]
	highlight -index 1
}
checkGrp
	
