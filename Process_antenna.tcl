proc create_diode_cui {antenna_viols_rpt diodeCellName} {

## Getting all the instances in the design
set all_insts [get_db insts .name]

## Opening the Antenna Violation File created by check_process_antenna
set fpr [open $antenna_viols_rpt r]
      foreach line [split [read $fpr] \n] {
        if {[regexp {\s*[0-9a-zA-Z\/\(\)\s]*} $line match]} {
            if {[lsearch $all_insts [lindex $line 0]] >= 0} {
              set instName [lindex $line 0]
              set instPin [lindex $line 2]
              set inst_llx [get_db inst:$instName .bbox.ll.x]
              set inst_lly [get_db inst:$instName .bbox.ll.y]
              create_diode -prefix user_diode\
                                 -diode_cell $diodeCellName\
                                 -pin $instName $instPin\
                                 -loc ${inst_llx} ${inst_lly}
            }
        }
    }
close $fpr

set_db eco_refine_place true
set_db place_detail_preserve_routing true
place_detail ; route_eco

puts "User Added Diodes Are:"
set user_diodes [get_db [get_db insts -if {.name==*user_diode*}] .name]
      foreach user_diode $user_diodes {
           puts "$user_diode ([get_db inst:$user_diode .base_cell.name]) is added at [get_db inst:$user_diode .bbox.ll]"
      }    
}

#End of the Script
#=========================================================================================

