


return
puts "Color_hier Info:: First order debug"
unset plist
#-- collect info.
set lvl 2
set i 0
set plist [list ]
set all_cells [get_cells * -hierarchical  -filter "is_hierarchical==false"]
sizeof_collection [get_cells * -hierarchical  -filter "is_hierarchical==false"]
#foreach h  [get_object_name [get_cells * -hierarchical -filter "is_hierarchical==true&&hierarchical_level==${lvl}"]] {}
foreach h  [get_object_name [get_cells * -hierarchical -filter "full_name=~ dmc_core_i/u_DWC_ddr_umctl2/DWC_ddrctl_i/U_ddrc/U_ddrc_cp_top/ddrc_ctrl_inst_0__U_ddrc_cp/*&&is_hierarchical==true&&hierarchical_level==7"]] {
    if {[regexp {spr_} $h]} {continue}
#    puts "filter_collection $all_cells full_name==${h}/*"
    set insts  [filter_collection $all_cells "full_name=~${h}/*&&(ref_name!~*BUF*&&ref_name!~*INV*&&ref_name!~*DLY*&&ref_name!~*CKND*&&ref_name!~*CKBD*)"]
    # puts [format "%-35s %-10s" $h $linsts]
    set linsts [sizeof_collection  $insts]
    lappend plist [list $h $linsts]
    incr i
    if {$i > 5000 } {
        puts "Stop watch timier triged"
        break
    }
}

# getting top hier cells
lappend plist [list "dmc_core_i/u_DWC_ddr_umctl2/DWC_ddrctl_i/U_ddrc/U_ddrc_cp_top/ddrc_ctrl_inst_0__U_ddrc_cp" [sizeof_collection [get_cells  dmc_core_i/u_DWC_ddr_umctl2/DWC_ddrctl_i/U_ddrc/U_ddrc_cp_top/ddrc_ctrl_inst_0__U_ddrc_cp/* -filter "is_hierarchical==false"]]]

#-- sort info.
#puts $plist
set sorted_plist [lsort -decreasing -integer -index 1 $plist]
#puts $sorted_plist

foreach 2dl $sorted_plist {
    set ref [get_property [get_cells [lindex $2dl 0]] ref_name]
#-- print info
    puts [format "\t %-100s %10s   (ref_name: $ref)" [lindex $2dl 0] [lindex $2dl 1]] 
#
}
