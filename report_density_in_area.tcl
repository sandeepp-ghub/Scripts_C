proc report_density_in_area {x0 y0 x1 y1} {
    set fx0 [expr double(${x0})] 
    set fy0 [expr double(${y0})] 
    set fx1 [expr double(${x1})] 
    set fy1 [expr double(${y1})] 
    set box_area [expr (${x1} -${x0})*(${y1} -${y0})]

    puts "X0: ${fx0}"
    puts "Y0: ${fy0}"
    puts "X1: ${fx1}"
    puts "Y1: ${fy1}"
    set insts [get_obj_in_area -areas "${fx0} ${fy0} ${fx1} ${fy1}" -obj_type inst]
    set total_insts_area 0
    foreach inst $insts {
        set inst_area [get_db $inst .area]
        set inst_name [get_db $inst .name]
        if {[regexp {SPAREORFILL} $inst_name]} {continue}
        set total_insts_area [expr $total_insts_area + $inst_area]
    }
    set density [expr $total_insts_area / $box_area]
    puts "Box area:         $box_area"
    puts "Total insts area: $total_insts_area"
    puts "Density:          $density "
}
