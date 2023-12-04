
proc sel_inst { inst_name} {
select_obj [get_db insts $inst_name]
}
alias si sel_inst

proc all_macro_cells {} {
return [get_db [get_db insts -if {.base_cell.base_class == block}] .name]
}

proc get_sel {} {
    foreach cell [get_db [get_db selected -if { .obj_type == inst} ] .name] {
	   # lappend instNames $cell
	   puts "$cell"
    }
}

## Selects the output terms of a selected instance.
proc select_inst_outs {} {
    foreach cell [get_db [get_db selected -if { .obj_type == inst} ] .name] {
           foreach outpins [get_db [get_db insts $cell] .pins -if { .direction==out }] {
                puts  [get_db $outpins .name ]
            }
        }
}

## Selects the input terms of a selected instance.
proc select_inst_ins {} {
    foreach cell [get_db [get_db selected -if { .obj_type == inst} ] .name] {
           foreach inpins [get_db [get_db insts $cell] .pins -if { .direction==in }] {
                puts  [get_db $inpins .name ]
            }
        }
}


proc buff_io {port buffer} {
    set loc [get_db [get_db ports $port] .location]
    set port [get_db port $port ]
    set x  [lindex $loc 0]
    set y [lindex $loc 1]
    set net_name [get_db [get_db ports $port] .net.name ]
    puts "eco_add_repeater -net $net_name -cells $buffer -location $x $y"
    #puts "addBuffer -net $net_name -buf $buffer -cutWires -loc $x $y"

}


proc location { } {
set f [open "location.tcl"]
#set f [open "location.tcl" "a+"]
foreach inst_name [get_db [get_db selected -if { .obj_type == inst} ] .name] {
set loc [get_db [get_db insts $inst_name] .location]
set xloc [lindex $loc 0]
set yloc [lindex $loc 1]
puts $f "place_inst $inst_name $xloc $yloc "
}
close $f
}

proc del_selinst_nets {} {
	foreach inst_name [get_db [get_db selected -if { .obj_type == inst} ] .name] {
		foreach net_name [get_db [get_db insts $inst_name] .pins.net.name  ] {
			puts  "delete_routes -net $net_name"
		}
	}


} 


proc fix_selinsts {} {
#set_db [get_db selected ] .place_status fixed
puts "###Fixing the selected instances......."
	foreach inst_name [get_db [get_db selected -if { .obj_type == inst} ] .name] {
	set_db [get_db insts $inst_name ] .place_status fixed
	}

puts "Done fixing" 
} 

proc unfix_selinsts {} {
    
	foreach inst_name [get_db [get_db selected -if { .obj_type == inst} ] .name] {
	set_db [get_db insts $inst_name ] .place_status unplaced
	}


}
 



# Buffers an input/output pin.
proc buffer_pin {pinName refName {prefix ""}} {
  set term  [get_db [get_db pin $pinName] .name]
  if { [llength $term]  == "0"} {
    puts "Error: Couldn't find pin $pinName!"
    return
  }
  set cell [get_db base_cell $refName]
  if {[ llength $cell ] == "0"} {
    puts "Error: Couldn't find base_cell $refName!"
    return
  }
  if {[ [get_db [get_db pins $term] .direction] == "in" } {
    return [bufferInPin $pinName $refName $prefix]
  } else {
    return [bufferOutPin $pinName $refName $prefix]
  }
}

# Procedure that adds a buffer to an output pin.
proc bufferOutPin {pinName refName {prefix ""}} {
  set term  [get_db [get_db pin $pinName] .name]

  if { [llength $term]  == "0"} {
    puts "Error: Couldn't find pin $pinName!"
    return
  }
  set cell [get_db base_cell $refName]
  if {[ llength $cell ] == "0"} {
    puts "Error: Couldn't find base_cell $refName!"
    return
  }
  if {[ [get_db [get_db pins $term] .direction] != "in" } {
    puts "Error: $pinName is not an input!"
  }
  set_db -eco_prefix [genPrefix $prefix]
  
  set netName [get_db [get_db pins $term] .net.name]
  set loc     [get_db [get_db pins $term] .location] 
  set x       [lindex $loc 0]
  set y       [lindex $loc 1]

  puts "eco_add_repeater -net $netName -location $x $y -cells $refName"
  return [eco_add_repeater -net $netName -location $x $y -cells $refName]
}

# Procedure that buffers an input pin.
proc bufferInPin {pinName refName {prefix ""}} { 
  set term  [get_db [get_db pin $pinName] .name]
  if { [llength $term]  == "0"} {
    puts "Error: Couldn't find pin $pinName!"
    return
  }
  set cell [get_db base_cell $refName]
  if {[ llength $cell ] == "0"} {
    puts "Error: Couldn't find base_cell $refName!"
    return
  }
  if {[ [get_db [get_db pins $term] .direction] != "out" } {
    puts "Error: $pinName is not an output!"
  }
  set_db -eco_prefix [genPrefix $prefix]

  
  set netName [get_db [get_db pins $term] .net.name]
  set loc     [get_db [get_db pins $term] .location] 
  set x       [lindex $loc 0]
  set y       [lindex $loc 1]



  puts "eco_add_repeater -location $x $y -cells $refName -pins $term"
  return [eco_add_repeater -location $x $y -cells $refName -pins $term]
}


# Generates a prefix for setEcoMode.
proc genPrefix {{prefix {}}} {
 if {![regexp {^_} $prefix]} {set prefix _$prefix}
 if {![regexp {_$} $prefix]} {set prefix ${prefix}_}
 return _[clock format [clock seconds] -format {%d%m%Y}]${prefix}
}



proc is_instplaced {inst} {
	if { [get_db [get_db insts $inst ] .place_status] != "unplaced" } {
		return 1 
 	} else {
		return 0 
	}
}

proc is_objinst {inst} {
	if { [get_db [get_db insts $inst ] .obj_type] == "inst" } {
		return 1 
 	} else {
		return 0 
	}
}

proc get_inststatus {inst} {
#return placement status
	return [get_db [get_db insts $inst ] .place_status] 
 
}


#usage :
# array set inst_status {}
# get_inst_placement_status inst_status
# restore_inst_placement_status inst_status
#
proc get_inst_placement_status {up_inst_array} {
    upvar $up_inst_array inst_array
    foreach inst_ptr [get_db [get_db insts ] .name]  {
        if [is_instplaced $inst_ptr] {
            set inst_array([get_db [get_db insts $inst_ptr] .name]) [get_inststatus $inst_ptr]
        }
    }
}


#####
proc restore_inst_placement_status {up_inst_array} {
    upvar $up_inst_array inst_array
    puts "Restoring instance placement status..."
    foreach inst [array names inst_array] {
        if {[set inst_ptr [get_db [get_db insts $inst] .name]]} {
            if {[is_objinst $inst_ptr]} {
                set_db [get_db insts $inst_ptr] $inst_array($inst)
	    } else {
                puts "Error: $inst isn't an instance"
            }
        } else {
            puts "Error: Unable to find $inst"
        }
    }
}


proc fix_all_insts { } {
    foreach inst_ptr [get_db [get_db insts ] .name]  {
        set_db [get_db insts $inst_ptr] .place_status fixed
    }
}


proc get_sinks {objptr} {
if { [llength [get_db nets $objptr ]] } {
	return [get_db [get_db nets $objptr ] .loads.name ]
} elseif { [llength [get_db pins $objptr ]] } {
	return [get_db [get_db pins $objptr ] .loads.name ]
} else {
	puts "$objptr doesn't exist "
}
}


proc get_driver {objptr} {
if { [llength [get_db nets $objptr ]] } {
	return [get_db [get_db nets $objptr ] .drivers.name ]
} elseif { [llength [get_db pins $objptr ]] } {
	return [get_db [get_db pins $objptr ] .drivers.name ]
} else {
	puts "$objptr doesn't exist "
}
}


