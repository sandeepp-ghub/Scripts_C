################################################################################
# proc add_welltap_to_inst_list
################################################################################

proc add_welltap_to_inst_list {welltap_cell inst_list_file} {

  if {[get_db base_cells $welltap_cell] == ""} {
          puts "\n\n*** Error : Cell $welltap_cell does not exist in Library ***\n\n"
          return
  }
  
  if {[get_db [get_db base_cells $welltap_cell] .is_macro]} {
          puts "\n\n*** Error : Cell $welltap_cell is not of type STD CELL ***\n\n"
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
  set welltap_width [get_db [get_db base_cells $welltap_cell] .bbox.width]

  set ctr 0
  set fp [ open $inst_list_file r ]
  gui_deselect -all
  
  foreach line [split [read $fp] \n ] {
    ### Skip comments ###
    if { [regexp {^\s*#} $line ] } {continue}
    ## Skip blank lines ###
    if { [regexp {^\s*$} $line ] } {continue}
  
    ### add welltaps to Clock buffers/inverters ###
    if { [regexp {^\s*(\S+)} $line xx clkbuf] } {
   	set x1 [get_db [get_db insts $clkbuf] .bbox.ll.x]
   	set y1 [get_db [get_db insts $clkbuf] .bbox.ll.y]
   	set x2 [get_db [get_db insts $clkbuf] .bbox.ur.x]
   	set y2 [get_db [get_db insts $clkbuf] .bbox.ur.y] 
    set xloc [expr $x1 - 1.836]
  
       # set mid_x [ expr  $x1 - $welltap_width + (($x2 - ($x1 - $welltap_width)) /2.0) # ]
       incr ctr
       puts "\n\n$ctr : Adding welltap cell $welltap_cell near inst $clkbuf location \"$x1 $y1 $x2 $y2\"  ..."
  
      set clkbuf_orient [get_db [get_db insts $clkbuf] .orient]
      if {[get_db insts ${clkbuf}_CLK_WELLTAP] == ""}  {
        if { $clkbuf_orient == "MX" || $clkbuf_orient == "R180" } {
#		puts "create_inst -physical -base_cell $welltap_cell -name ${clkbuf}_CLK_WELLTAP -location [ expr $x1 - $welltap_width ] $y1"
          create_inst -physical -base_cell $welltap_cell -name ${clkbuf}_CLK_WELLTAP_R -location [ expr $x1 - $welltap_width ] $y1 -place_status placed
          create_inst -physical -base_cell $welltap_cell -name ${clkbuf}_CLK_WELLTAP_L -location [ expr $xloc - $welltap_width ] $y1 -place_status placed          
        } else {
#		puts "create_inst -physical -base_cell $welltap_cell -name ${clkbuf}_CLK_WELLTAP -location $x2 $y1"
          create_inst -physical -base_cell $welltap_cell -name ${clkbuf}_CLK_WELLTAP_R -location $x2 $y1 -place_status placed
          create_inst -physical -base_cell $welltap_cell -name ${clkbuf}_CLK_WELLTAP_L -location $xloc $y1 -place_status placed          

        }
        select_obj $clkbuf
      }
    }
  }

  close $fp

  puts "\n\nLegalizing Placement ...[exec date]"
  # Legalize placement giving priority to the welltap cells:
  set_instance_placement_status -name *_CLK_WELLTAP* -status fixed
  place_detail

  # Legalize placement giving priority to the clock tree cells:
  set_instance_placement_status -name *_CLK_WELLTAP* -status placed
  place_detail

  # Legalize placement with clock cells placed to resolve any remaining violations:
    foreach clk_cell [get_db [get_db clock_trees .insts] .name] {
    set_db [get_db insts $clk_cell] .place_status placed
  }
  foreach clock_sink [get_db [get_db clock_trees .sinks] inst.name] {
    set_db [get_db insts $clock_sink] .place_status placed
  }
  place_detail

  # Fix clock cells and welltap cells:
    foreach clk_cell [get_db [get_db clock_trees .insts] .name] {
    set_db [get_db insts $clk_cell] .place_status fixed
  }
  foreach clock_sink [get_db [get_db clock_trees .sinks] inst.name] {
    set_db [get_db insts $clock_sink] .place_status fixed
  }
  set_instance_placement_status -name *_CLK_WELLTAP* -status fixed

  reset_db eco_refine_place 
  reset_db eco_update_timing
  reset_db eco_honor_fixed_status

  gui_deselect -all
  check_place cp.rpt
}
