################################################################################
#  DISCLAIMER: The following code is provided for Cadence customers to use at  #
#   their own risk. The code may require modification to satisfy the           #
#   requirements of any user. The code and any modifications to the code may   #
#   not be compatible with current or future versions of Cadence products.     #
#   THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, INCLUDING WITHOUT     #
#   LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED WARRANTIES OF MERCHANTABILITY #
#   OR FITNESS FOR A PARTICULAR USE.                                           #
################################################################################
##
## Purpose     : To add decap cells next to CTS inserted bufs/invs. 
##               Clock tree must be built by CCOpt

################################################################################
# proc add_clk_decap
################################################################################

proc add_clk_decap { decap_cell } {

  if {  [get_db base_cells $decap_cell] == ""  } { 
    puts "\n\n*** Error : Cell $decap_cell does not exist in Library ***\n\n" 
    return
  }

  if {[get_db [get_db base_cells $decap_cell] .is_macro]} { 
    puts "\n\n*** Error : Cell $decap_cell is not of type STD CELL ***\n\n" 
    return
  }

  ### Fix registers and clock instances ###
  foreach clk_cell [get_db [get_db clock_trees .insts] .name] {
    set_db [get_db insts $clk_cell] .place_status fixed
  }
  foreach clock_sink [get_db [get_db clock_trees .sinks] inst.name] {
    set_db [get_db insts $clock_sink] .place_status fixed
  }

  set_db eco_refine_place false 
  set_db eco_update_timing false 
  set_db eco_honor_fixed_status true

  set dcap_width [get_db [get_db base_cells $decap_cell] .bbox.width]

  set ctr 0
  gui_deselect -all

  # Foreach clock buffer/inverter inserter a decap cell next to it:
  foreach clkbuf [get_db [get_db [get_db clock_trees] .insts. -if {.cts_node_type == buffer || .cts_node_type == inverter || .cts_node_type == clock_gate}] .name] {
 
    ### add decaps to Clock buffers/inverters ###
   set x1 [get_db [get_db insts $clkbuf] .bbox.ll.x]
   set y1 [get_db [get_db insts $clkbuf] .bbox.ll.y]
   set x2 [get_db [get_db insts $clkbuf] .bbox.ur.x]
   set y2 [get_db [get_db insts $clkbuf] .bbox.ur.y]
   set x1_new [expr $x1 -$dcap_width]
    incr ctr
    puts "\n\n$ctr : Adding Decap cell $decap_cell near inst $clkbuf location \"$x1 $y1 $x2 $y2\"  ..."
    set clkbuf_orient [get_db [get_db insts $clkbuf] .orient]
    if {[get_db insts ${clkbuf}_CLK_DECAP] == ""}  { 
      if { $clkbuf_orient == "MX" || $clkbuf_orient == "R180" } {
#	      puts "create_inst -physical -base_cell $decap_cell -name ${clkbuf}_CLK_DECAP -location $x1_new $y1"
        create_inst -physical -base_cell $decap_cell -name ${clkbuf}_CLK_DECAP -location "[expr $x1 - $dcap_width] $y1" -place_status placed
      } else {
#	      puts "create_inst -physical -base_cell $decap_cell -name ${clkbuf}_CLK_DECAP -location $x2 $y1"
        create_inst -physical -base_cell $decap_cell -name ${clkbuf}_CLK_DECAP -location "$x2 $y1" -place_status placed
      }
      select_obj $clkbuf
    }
  }

  puts "\n\nLegalizing Placement ...[exec date]"
  # Legalize placement giving priority to the decap cells:
  set_instance_placement_status -name *_CLK_DECAP -status fixed
  place_detail

  # Legalize placement giving priority to the clock tree cells:
  set_instance_placement_status -name *_CLK_DECAP -status placed
  place_detail

  # Legalize placement with clock cells placed to resolve any remaining violations:
  foreach clk_cell [get_db [get_db clock_trees .insts] .name] {
    set_db [get_db insts $clk_cell] .place_status placed
  }
  foreach clock_sink [get_db [get_db clock_trees .sinks] inst.name] {
    set_db [get_db insts $clock_sink] .place_status placed
  }
  place_detail

  # Fix clock cells and decap cells:
  foreach clk_cell [get_db [get_db clock_trees .insts] .name] {
    set_db [get_db insts $clk_cell] .place_status fixed
  }
  foreach clock_sink [get_db [get_db clock_trees .sinks] inst.name] {
    set_db [get_db insts $clock_sink] .place_status fixed
  }
  set_instance_placement_status -name *_CLK_DECAP -status fixed

  reset_db eco_refine_place 
  reset_db eco_update_timing
  reset_db eco_honor_fixed_status

  gui_deselect -all
  check_place cp.rpt
}

################################################################################
# proc add_decap_to_inst_list
################################################################################

proc add_decap_to_inst_list {decap_cell inst_list_file} {

  if {[get_db base_cells $decap_cell] == ""} {
          puts "\n\n*** Error : Cell $decap_cell does not exist in Library ***\n\n"
          return
  }
  
  if {[get_db [get_db base_cells $decap_cell] .is_macro]} {
          puts "\n\n*** Error : Cell $decap_cell is not of type STD CELL ***\n\n"
          return
  }
  
  ### Fix registers and clock instances ###
  foreach clk_cell [get_db [get_db clock_trees .insts] .name] {
    set_db [get_db insts $clk_cell] .place_status fixed
  }
  foreach clock_sink [get_db [get_db clock_trees .sinks] inst.name] {
    set_db [get_db insts $clock_sink] .place_status fixed
  }

  set_db eco_refine_place false 
  set_db eco_update_timing false 
  set_db eco_honor_fixed_status true 
  
  ### Get a list of clock bufs/invs
  set dcap_width [get_db [get_db base_cells $decap_cell] .bbox.width]

  set ctr 0
  set fp [ open $inst_list_file r ]
  gui_deselect -all
  
  foreach line [split [read $fp] \n ] {
    ### Skip comments ###
    if { [regexp {^\s*#} $line ] } {continue}
    ## Skip blank lines ###
    if { [regexp {^\s*$} $line ] } {continue}
  
    ### add decaps to Clock buffers/inverters ###
    if { [regexp {^\s*(\S+)} $line xx clkbuf] } {
   	set x1 [get_db [get_db insts $clkbuf] .bbox.ll.x]
   	set y1 [get_db [get_db insts $clkbuf] .bbox.ll.y]
   	set x2 [get_db [get_db insts $clkbuf] .bbox.ur.x]
   	set y2 [get_db [get_db insts $clkbuf] .bbox.ur.y] 
  
       # set mid_x [ expr  $x1 - $dcap_width + (($x2 - ($x1 - $dcap_width)) /2.0) # ]
       incr ctr
       puts "\n\n$ctr : Adding Decap cell $decap_cell near inst $clkbuf location \"$x1 $y1 $x2 $y2\"  ..."
  
      set clkbuf_orient [get_db [get_db insts $clkbuf] .orient]
      if {[get_db insts ${clkbuf}_CLK_DECAP] == ""}  {
        if { $clkbuf_orient == "MX" || $clkbuf_orient == "R180" } {
#		puts "create_inst -physical -base_cell $decap_cell -name ${clkbuf}_CLK_DECAP -location [ expr $x1 - $dcap_width ] $y1"
          create_inst -physical -base_cell $decap_cell -name ${clkbuf}_CLK_DECAP -location [ expr $x1 - $dcap_width ] $y1 -place_status placed

        } else {
#		puts "create_inst -physical -base_cell $decap_cell -name ${clkbuf}_CLK_DECAP -location $x2 $y1"
          create_inst -physical -base_cell $decap_cell -name ${clkbuf}_CLK_DECAP -location $x2 $y1 -place_status placed
        }
        select_obj $clkbuf
      }
    }
  }

  close $fp

  puts "\n\nLegalizing Placement ...[exec date]"
  # Legalize placement giving priority to the decap cells:
  set_instance_placement_status -name *_CLK_DECAP -status fixed
  place_detail

  # Legalize placement giving priority to the clock tree cells:
  set_instance_placement_status -name *_CLK_DECAP -status placed
  place_detail

  # Legalize placement with clock cells placed to resolve any remaining violations:
    foreach clk_cell [get_db [get_db clock_trees .insts] .name] {
    set_db [get_db insts $clk_cell] .place_status placed
  }
  foreach clock_sink [get_db [get_db clock_trees .sinks] inst.name] {
    set_db [get_db insts $clock_sink] .place_status placed
  }
  place_detail

  # Fix clock cells and decap cells:
    foreach clk_cell [get_db [get_db clock_trees .insts] .name] {
    set_db [get_db insts $clk_cell] .place_status fixed
  }
  foreach clock_sink [get_db [get_db clock_trees .sinks] inst.name] {
    set_db [get_db insts $clock_sink] .place_status fixed
  }
  set_instance_placement_status -name *_CLK_DECAP -status fixed

  reset_db eco_refine_place 
  reset_db eco_update_timing
  reset_db eco_honor_fixed_status

  gui_deselect -all
  check_place cp.rpt
}
