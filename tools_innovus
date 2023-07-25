
alias gs "get_db selected"
alias ds "deselect_obj -all"
alias ss "set_db selected"

proc mx_rect {rect} {
  lassign $rect llx lly urx ury
  lassign [get_rect -center [get_db designs .boundary.bbox]] cx cy
  #puts "SETH rect($llx $lly $urx $ury cx: $cx cy: $cy"
  set new_y [lsort -real [list [expr 2*$cy - $lly] [expr 2*$cy-$ury]]]
  lassign $new_y mx_lly mx_ury
  return [list $llx $mx_lly $urx $mx_ury]
}


proc dr {rect {color red}} {
  set_layer_preference GUI_LAYER_$color -color $color -stipple Slash
  create_gui_shape -layer GUI_LAYER_$color -rect $rect
}

proc drr {} { global region_area; dr $region_area }

proc rr {args} {
  delete_obj [get_db gui_shapes -if { [regexp {GUI_LAYER} .gui_layer_name]}]
}

proc get_drivers {pin_obj} {
  puts [get_db $pin_obj .net.drivers.name]
}

#proc ss {args} {
  #set_db selected $args
#}

proc mint_print_list { args } {
  foreach i {*}$args {
    puts $i
  }
}

proc mint_print_collection { args } {
  foreach_in_collection i $args {
    puts [get_object_name $i]
  }
}

proc mint_flatten_list list {
  for {set old {}} {$old ne $list} {} {
    set old $list
    set list [join $list]
  }
  return $list
}

proc mint_compress_numeric_list { args } {
  set procname [lindex [info level [info level]] 0]
  set idx 0
  set working_list [lsort -uniq -decreasing -integer $args]
  set length [llength working_list]
  set compress_bucket [list]
  set bucket_idx 0

  foreach curr_val $working_list {
    if { $idx } {
      set prev_idx [expr $idx - 1]
      set prev_val [lindex $working_list $prev_idx]
      if { [expr $prev_val - $curr_val] != 1 } {
        incr bucket_idx
      }
    }

    lset compress_bucket $bucket_idx end+1 $curr_val 

    incr idx
  }
  set idx 0
  foreach bucket $compress_bucket {
    if { [llength $bucket] > 1 } {
      lset compress_bucket $idx "[lindex $bucket 0]:[lindex $bucket end]"
    }
    incr idx
  }

  return [join $compress_bucket ","]
}

proc mint_compress { args } {
  set procname [lindex [info level [info level]] 0]
  set uncompressed_list [lsort -uniq {*}$args]
  set compressed_list [list]
  #global compress_dict
  set compress_dict [dict create]
  set split_dict [dict create]
  foreach item $uncompressed_list {
    #Break out verilog []
    regsub -all {([\[\]])} $item {\\\1} regexp_str
    #puts $item
    #set item cpri_top0_cpri_dma0_cpri_txd0_u_cpri_dma_rp3_tx_mem_m_m_a_0_0
    regsub -all {\d\d*} $regexp_str {(\d\d*)} regexp_str
    set val_list [lassign [regexp -all -inline $regexp_str $item] match]
    #puts $val_list
    if { ! [dict exists $compress_dict $regexp_str] } {
      dict set compress_dict $regexp_str $val_list
      #dict set compress_dict $regexp_str {*}$val_list
      #Negative match to get alpha characters between numberic characters
      dict set split_dict $regexp_str [regexp -all -inline {[^0-9][^0-9]*} $item]
    } else {
      set val_container [dict get $compress_dict $regexp_str]
      if { [llength $val_container] != [llength $val_list] } {
        puts "Error: ($procname) val_container length ([llength $val_container]) NOT equal to number of integers extracted from $item ([llength $val_list])"
        return
      }
      set i 0
      foreach val $val_list {
        lset val_container $i end+1 $val 
        incr i
      }
      dict set compress_dict $regexp_str $val_container
    }
  }
  #pdict $compress_dict
  #pdict $split_dict
  #puts ""
  #puts ""

  dict for {regexp_key val_container} $compress_dict {
    set char_list [dict get $split_dict $regexp_key]
    set compressed_str ""
    set min_max_str ""
    set i 0
    foreach all_vals_of_single_position $val_container {
      set char [lindex $char_list $i]
      set numeric_compressed [mint_compress_numeric_list {*}$all_vals_of_single_position]
      set compressed_str $compressed_str$char$numeric_compressed
      incr i
    }
    #Grab the last character
    if { $i < [llength $char_list] } {
      set compressed_str $compressed_str[lindex $char_list end]
    }
    lappend compressed_list $compressed_str
  }

  return $compressed_list
}


proc mint_print_list_compressed { args } {
  set procname [lindex [info level [info level]] 0]
  mint_print_list [mint_compress [mint_flatten_list $args]]
}

proc mint_print_collection_compressed { args } {
  set procname [lindex [info level [info level]] 0]
  mint_print_list [mint_compress [mint_flatten_list [get_object_name $args]]]
}

alias pl mint_print_list
alias pc mint_print_collection
alias plc mint_print_list_compressed
alias pcc mint_print_collection_compressed

alias sc sizeof_collection

#report_timing -output_format gtd -max_paths 10000 -max_slack 0.75 -path_exceptions all -late > top.mtarpt
#report_timing -group blk2reg -path_type full_clock -output_format gtd > top.mtarpt
#read_timing_debug_report top.mtarpt -max_path_num 1000 -update_category 0
#read_timing_debug_report -name default_report top.mtarpt -max_path_num 10000 -update_category 0
#write_to_gif
#report_timing -group blk2reg -path_type endpoint -max_paths 20
#set_db selected [get_db [get_db  [all_fanout -endpoints_only -from ssn_bus_clock_in] -if {.obj_type == pin}] .inst]

################
## This proc takes up the "report_timing -options" as an arguments and can highlight datapath (by default) and launch_clock_path and capture_clock_path in GUI. 
################

proc hlpath {args} {
 
  set launch_clock_path 0
  set capture_clock_path 0
 
  set results(-help) "none"
  set results(-report_timing_args) "none"
  set results(-deselect_all) "none"
  set results(-launch_clock_path) "none"
  set results(-capture_clock_path) "none"

  parse_proc_arguments -args $args results

  if {$results(-help)==""} {
    help -verbose hlpath
    return 1
  }
  
  if {$results(-deselect_all)!="none"} {deselect_obj -all}
  if {$results(-launch_clock_path)!="none"} {set launch_clock_path 1}
  if {$results(-capture_clock_path)!="none"} {set capture_clock_path 1}
  if {$results(-report_timing_args)!="none"} {
    set report_timing_args $results(-report_timing_args)
    if {![regexp full_clock $report_timing_args]} {set timing_path [eval "$report_timing_args -collection -path_type full_clock"]} else {
      set timing_path [eval "$report_timing_args -collection"]}
    } else {
      set timing_path [eval "report_timing -collection -path_type full_clock"]
    }
  
  foreach_in_collection path $timing_path {
    if {$launch_clock_path} {set path [get_property $path launch_clock_path]}
    if {$capture_clock_path} {set path [get_property $path capture_clock_path]}
    set t_points [get_property $path timing_points]
    foreach_in_collection point $t_points {
      set pin [get_object_name [get_property $point pin]]
      select_obj $pin
      #if {[catch {[get_db $pin .obj_type] == "port"}]} {
        #catch {select_obj [dbTermInstName [dbGetTermByInstTermName $pin]]}
        #puts [dbTermInstName [dbGetTermByInstTermName $pin]]
      #}
      puts $pin
    }
  }
}

define_proc_arguments hilitePath \
 -info "Highlight the combinational logic between startpoint and endpoint" \
 -define_args {\
  {-report_timing_args "Specifies the arguments of the report_timing" "string" string optional}
  {-deselect_all "deselects all previously selected objects" "" boolean optional}
  {-launch_clock_path "Highlights the launch clock path" "" boolean optional}
  {-capture_clock_path "Highlights the capture clock path" "" boolean optional}
}

proc compress_eps {tpaths} {
  #foreach_in_collection path $timing_path {
  #}
  set eps [get_object_name [get_property $tpaths endpoint]]
  plc $eps
}

proc graph_dist {tpaths} {
  set data [list]
  foreach_in_collection path $tpaths {
    set sp [get_property $path startpoint]
    set ep [get_property $path endpoint]

    set sp_inst [get_db $sp .inst]
    set ep_inst [get_db $ep .inst]

    set sp_loc [get_db $sp_inst .location]
    set ep_loc [get_db $ep_inst .location]

    lassign {*}$sp_loc sp_x sp_y
    lassign {*}$ep_loc ep_x ep_y

    set manhattan_dist [expr abs($sp_x - $ep_x) + abs($sp_y - $ep_y)]
    lappend data $manhattan_dist
  }
  #mortar::numeric_histogram -data $data -step 50 -min 850 -max 1250
  mortar::numeric_histogram -data $data
}

proc star_indices { args } {
  set ret_list [list]
  foreach item [mint_flatten_list $args] {
    lappend ret_list [regsub -all {\d\d*[\d:,][\d:,]*\d\d*} $item "*"]
  }
  return $ret_list
}


set ::Colors [list \
  yellow \
  orange \
  red \
  blue \
  green \
  purple \
  light_orange \
  light_red \
  light_blue \
  light_green \
  light_purple \
]

proc ::GetNextColor { args } {
  global color_idx
  if { ! [info exists color_idx] } {
    set color_idx 0
  } else {
    incr color_idx
  }
  return [lindex $::Colors [expr $color_idx % [llength $::Colors]]]
}


proc inn_fi {objs} {
  set ret_list [list]
  foreach a [get_object_name [all_fanin -startpoints_only -trace_through all -to $objs]] {
    set port [get_db ports $a]
    set pin [get_db pins $a]
    if {[llength $port]} { lappend ret_list $port }
    if {[llength $pin]} { lappend ret_list $pin }
  }
  return $ret_list
}

proc ::HighlightFanin { {coll ""} {max_level 1} } {
  set procname [lindex [info level [info level]] 0]
  set seen_coll ""

  if { ! [sizeof_collection $coll] } {
    set coll [gs]
  }

  if { [array exists ::hlfin] } {
    unset ::hlfin
  }

  gui_change_highlight -remove -all_colors

  set inp_pins ""
  foreach_in_collection item $coll {
    if { [get_property $item object_class] == "port" } {
      set item [get_ports $item]
      append_to_collection inp_pins [filter_collection $item {direction=~"out"}]
    } elseif { [get_property $item object_class] == "cell" } {
      #append_to_collection inp_pins [get_pins -quiet -of $item -filter {direction=~"in"&&is_clock_pin==false}]
      set item [get_cells $item]
      append_to_collection inp_pins [get_pins -quiet -of $item -filter {direction=~"in"}]
    } elseif { [get_property $item object_class] == "pin" } {
      #append_to_collection inp_pins [filter_collection $item {direction=~"in"&&is_clock_pin==false}]
      set item [get_pins $item]
      append_to_collection inp_pins [filter_collection $item {direction=~"in"}]
    }
  }

  set fanin_pins [remove_from_collection [all_fanin -trace_through all -start -to [filter_collection $inp_pins is_clock_pin==false]] $seen_coll]
  set clk_inp_pins [filter_collection $inp_pins is_clock_pin==true]
  #append_to_collection fanin_pins [remove_from_collection [filter_collection [all_fanin -flat -trace_arcs all -to $inp_pins] direction=~"out"] $seen_coll]
  set inp_fgcg_cells [filter_collection [all_fanin -flat -trace_arcs all -only_cells -to $clk_inp_pins] is_integrated_clock_get_propertyting_cell==true]
  append_to_collection fanin_pins [filter_collection [get_pins -quiet -of $inp_fgcg_cells] {direction=~"in"&&(is_clock_get_propertyting_clock==true)}]
  for {set curr_level 1} {$curr_level <= $max_level} {incr curr_level} {
    set seen_coll [add_to_collection $seen_coll $fanin_pins]
    set ports_at_level [filter_collection $fanin_pins object_class=~"port"]
    set cells_at_level [get_cells -quiet -of [filter_collection $fanin_pins object_class=~"pin"]]

    set curr_color [::GetNextColor]
    set hlcoll [add_to_collection $ports_at_level $cells_at_level]
    set ::hlfin($curr_level) $hlcoll
    gui_change_highlight -color $curr_color -collection $hlcoll
    puts "Level $curr_level ($curr_color) Cells: [sc $cells_at_level] Ports: [sc $ports_at_level]"

    if { $curr_level < $max_level } {
      #set inp_pins [get_pins -quiet -of $cells_at_level -filter {direction=~"in"&&is_clock_pin==false}]
      set inp_pins [get_pins -quiet -of $cells_at_level -filter {direction=~"in"}]
      set fanin_pins [remove_from_collection [afst [filter_collection $inp_pins is_clock_pin==false]] $seen_coll]
      set clk_inp_pins [filter_collection $inp_pins is_clock_pin==true]
      set inp_fgcg_cells [filter_collection [all_fanin -flat -trace_arcs all -only_cells -to $clk_inp_pins] is_integrated_clock_get_propertyting_cell==true]
      append_to_collection fanin_pins [filter_collection [get_pins -of $inp_fgcg_cells] {direction=~"in"&&(is_clock_get_propertyting_clock==true)}]
    }
  }
}

#proc ::HighlightFanout { {coll ""} {max_level 1} } {
#  set procname [lindex [info level [info level]] 0]
#  set seen_coll ""
#
#  if { ! [sc $coll] } {
#    set coll [gs]
#  }
#
#  if { [array exists ::hlfout] } {
#    unset ::hlfout
#  }
#
#  gui_change_highlight -remove -all_colors
#
#  #set output_pins [get_pins -quiet -of [gs] -filter {direction=~"out"&&is_clock_pin==false}]
#
#  set output_pins ""
#  foreach_in_collection item $coll {
#    if { [ga $item object_class] == "port" } {
#      append_to_collection output_pins [filter_collection $item {direction=~"in"}]
#    } elseif { [ga $item object_class] == "cell" } {
#      #append_to_collection output_pins [get_pins -quiet -of $item -filter {direction=~"out"&&is_clock_pin==false}]
#      append_to_collection output_pins [get_pins -quiet -of $item -filter {direction=~"out"}]
#    } elseif { [ga $item object_class] == "pin" } {
#      #append_to_collection output_pins [filter_collection $item {direction=~"out"&&is_clock_pin==false}]
#      append_to_collection output_pins [filter_collection $item {direction=~"out"}]
#    }
#  }
#
#  set fanout_pins [remove_from_collection [afef $output_pins] $seen_coll]
#  for {set curr_level 1} {$curr_level <= $max_level} {incr curr_level} {
#    set seen_coll [add_to_collection $seen_coll $fanout_pins]
#    set ports_at_level [filter_collection $fanout_pins object_class=~"port"]
#    set cells_at_level [gc -of [filter_collection $fanout_pins object_class=~"pin"]]
#
#    set curr_color [::GetNextColor]
#    set hlcoll [add_to_collection $ports_at_level $cells_at_level]
#    set ::hlfout($curr_level) $hlcoll
#    gui_change_highlight -color $curr_color -collection $hlcoll
#    puts "Level $curr_level ($curr_color) Cells: [sc $cells_at_level] Ports: [sc $ports_at_level]"
#
#    if { $curr_level < $max_level } {
#      #set output_pins [get_pins -quiet -of $cells_at_level -filter {direction=~"out"&&is_clock_pin==false}]
#      set output_pins [get_pins -quiet -of $cells_at_level -filter {direction=~"out"}]
#      set fanout_pins [remove_from_collection [afef $output_pins] $seen_coll]
#    }
#  }
#}


