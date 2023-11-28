# Add blocks UP/DDWN IP
puts "\n... Add place_blockage UP/DDWN IP"
set i 0
set ncap 7
set rows [get_db rows -if ".site.name == core"]
set blocks [get_db insts -if {.base_cell==*dwc_ddrphyacx4_top_ew*}]
set cap_x [expr $ncap * [get_db [get_db base_cells dwc_ddrphy_decapvddq_ld_acx4_ew] .bbox.width]]
foreach b $blocks {
    # block
    set x0 [get_db $b .bbox.ll.x] 
    set y0 [get_db $b .bbox.ll.y]
    set x1 [get_db $b .bbox.ur.x]
    set y1 [get_db $b .bbox.ur.y]
    set or [get_db $b .orient   ]
    if {$or == "my" || $or == "r180"} {
    	set cx1 [expr $x1 + $cap_x]
    } else {
    	set cx0 [expr $x0 - $cap_x]
    }
    set ury [expr $y1 + 13]
    set above_row [get_db $rows -if {.rect.ll.y >= $ury}]
	if {[llength $above_row]} {
		set sort_rows [list ]
		foreach row $above_row {
			lappend sort_rows [list $row [get_db $row .rect.ll.y]]
		}
		set above_row [lindex [lindex [lsort -real -index 1 $sort_rows] 0 ] 0 ]
		set orient [get_db $above_row .orient] ;# {r0 r90 r180 r270 mx mx90 my my90 unknown}
		set row_sizey [get_db $above_row .rect.dy]
		if {$orient == "mx"} {
			# The above row is starting with VDD, need to enlarge the space by one row.
			set ury [expr $ury + $row_sizey]
		}
	}
	set lly [expr $y0 - 3.36]
	set lower_row [get_db $rows -if {.rect.ur.y <= $lly}]
	if {[llength $lower_row]} {
		set sort_rows [list ]
		foreach row $lower_row {
			lappend sort_rows [list $row [get_db $row .rect.ll.y]]
		}
		set lower_row [lindex [lindex [lsort -real -index 1 $sort_rows] end ] 0 ]
		set orient [get_db $lower_row .orient] ;# {r0 r90 r180 r270 mx mx90 my my90 unknown}
		if {$orient == "r0"} {
			# The lower row is starting with VDD, need to enlarge the space by one row.
			set lly [expr $lly - $row_sizey]
		}
	}	
    #UP
    set cury [expr $ury - 0.840 - (0.840 * 8) - (0.840 * 3)]
    create_place_blockage -type hard -name snps_pb_hrd_$i -rects "${x0} ${y1} ${x1} ${ury}"
    incr i
    if {$or == "my" || $or == "r180"} {
    	create_place_blockage -type hard -name snps_pb_hrd_$i -rects "${x1} ${y1} ${cx1} ${cury}"
    } else {
    	create_place_blockage -type hard -name snps_pb_hrd_$i -rects "${cx0} ${y1} ${x0} ${cury}"    
    }
    incr i
    #Down
    set clly [expr $lly + 0.84]
    create_place_blockage -type hard -name snps_pb_hrd_$i -rects "${x0} ${lly} ${x1} ${y0}"
    incr i
    if {$or == "my" || $or == "r180"} {
    	create_place_blockage -type hard -name snps_pb_hrd_$i -rects "${x1} ${clly} ${cx1} ${y0}"
    } else {
    	create_place_blockage -type hard -name snps_pb_hrd_$i -rects "${cx0} ${clly} ${x0} ${y0}"    
    }
    incr i
}

set blocks [get_db insts -if {.base_cell==*dwc_ddrphydbyte_top_ew*}]
set cap_x [expr $ncap * [get_db [get_db base_cells dwc_ddrphy_decapvddq_ld_dbyte_ew] .bbox.width]]
foreach b $blocks {
    # block
    set x0 [get_db $b .bbox.ll.x] 
    set y0 [get_db $b .bbox.ll.y]
    set x1 [get_db $b .bbox.ur.x]
    set y1 [get_db $b .bbox.ur.y]
    set or [get_db $b .orient   ]
    # puts "${x0} ${y0} ${x1} ${y1} : $or"
    if {$or == "my" || $or == "r180"} {
    	set cx1 [expr $x1 + $cap_x]
    } else {
    	set cx0 [expr $x0 - $cap_x]
    }
	set ury [expr $y1 + 3.36]
    set above_row [get_db $rows -if {.rect.ll.y >= $ury}]
	if {[llength $above_row]} {
		set sort_rows [list ]
		foreach row $above_row {
			lappend sort_rows [list $row [get_db $row .rect.ll.y]]
		}
		set above_row [lindex [lindex [lsort -real -index 1 $sort_rows] 0 ] 0 ]
		set orient [get_db $above_row .orient] ;# {r0 r90 r180 r270 mx mx90 my my90 unknown}
		set row_sizey [get_db $above_row .rect.dy]
		if {$orient == "mx"} {
			# The above row is starting with VDD, need to enlarge the space by one row.
			set ury [expr $ury + $row_sizey]
		}
	}
	set lly [expr $y0 - 3.36]
	set lower_row [get_db $rows -if {.rect.ur.y <= $lly}]
	if {[llength $lower_row]} {
		set sort_rows [list ]
		foreach row $lower_row {
			lappend sort_rows [list $row [get_db $row .rect.ll.y]]
		}
		set lower_row [lindex [lindex [lsort -real -index 1 $sort_rows] end ] 0 ]
		set orient [get_db $lower_row .orient] ;# {r0 r90 r180 r270 mx mx90 my my90 unknown}
		if {$orient == "r0"} {
			# The lower row is starting with VDD, need to enlarge the space by one row.
			set lly [expr $lly - $row_sizey]
		}
	}
	#UP
	set cury [expr $ury - (0.840 * 2)]
    create_place_blockage -type hard -name snps_pb_hrd_$i -rects "${x0} ${y1} ${x1} ${ury}"
    incr i
    if {$or == "my" || $or == "r180"} {
    	create_place_blockage -type hard -name snps_pb_hrd_$i -rects "${x1} ${y1} ${cx1} ${cury}"
    } else {
    	create_place_blockage -type hard -name snps_pb_hrd_$i -rects "${cx0} ${y1} ${x0} ${cury}"    
    }
    incr i    
	#Down
    create_place_blockage -type hard -name snps_pb_hrd_$i -rects "${x0} ${lly} ${x1} ${y0}"
    incr i
    set clly [expr $lly + 0.84]
      if {$or == "my" || $or == "r180"} {
    	create_place_blockage -type hard -name snps_pb_hrd_$i -rects "${x1} ${clly} ${cx1} ${y0}"
    } else {
    	create_place_blockage -type hard -name snps_pb_hrd_$i -rects "${cx0} ${clly} ${x0} ${y0}"    
    }
    incr i
}

set blocks [get_db insts -if {.base_cell==*dwc_ddrphymaster_top*}]
set cap_x [expr $ncap * [get_db [get_db base_cells dwc_ddrphy_decapvddq_ld_master] .bbox.width]]
foreach b $blocks {
    # block
    set x0 [get_db $b .bbox.ll.x] 
    set y0 [get_db $b .bbox.ll.y]
    set x1 [get_db $b .bbox.ur.x]
    set y1 [get_db $b .bbox.ur.y]
    set or [get_db $b .orient   ]
    # puts "${x0} ${y0} ${x1} ${y1} : $or"
    if {$or == "my" || $or == "r180"} {
    	set cx1 [expr $x1 + $cap_x]
    } else {
    	set cx0 [expr $x0 - $cap_x]
    }
	set ury [expr $y1 + 3.36]
    set above_row [get_db $rows -if {.rect.ll.y >= $ury}]
	if {[llength $above_row]} {
		set sort_rows [list ]
		foreach row $above_row {
			lappend sort_rows [list $row [get_db $row .rect.ll.y]]
		}
		set above_row [lindex [lindex [lsort -real -index 1 $sort_rows] 0 ] 0 ]
		set orient [get_db $above_row .orient] ;# {r0 r90 r180 r270 mx mx90 my my90 unknown}
		set row_sizey [get_db $above_row .rect.dy]
		if {$orient == "mx"} {
			# The above row is starting with VDD, need to enlarge the space by one row.
			set ury [expr $ury + $row_sizey]
		}
	}
	set lly [expr $y0 - 3.36]
	set lower_row [get_db $rows -if {.rect.ur.y <= $lly}]
	if {[llength $lower_row]} {
		set sort_rows [list ]
		foreach row $lower_row {
			lappend sort_rows [list $row [get_db $row .rect.ll.y]]
		}
		set lower_row [lindex [lindex [lsort -real -index 1 $sort_rows] end ] 0 ]
		set orient [get_db $lower_row .orient] ;# {r0 r90 r180 r270 mx mx90 my my90 unknown}
		if {$orient == "r0"} {
			# The lower row is starting with VDD, need to enlarge the space by one row.
			set lly [expr $lly - $row_sizey]
		}
	}
	#UP
	set cury [expr $ury - 0.840]
    create_place_blockage -type hard -name snps_pb_hrd_$i -rects "${x0} ${y1} ${x1} ${ury}"
    incr i
    if {$or == "my" || $or == "r180"} {
    	create_place_blockage -type hard -name snps_pb_hrd_$i -rects "${x1} ${y1} ${cx1} ${cury}"
    } else {
    	create_place_blockage -type hard -name snps_pb_hrd_$i -rects "${cx0} ${y1} ${x0} ${cury}"    
    }
    incr i 
	#Down
#  create_place_blockage -type hard -name snps_pb_hrd_$i -rects "${x0} ${lly} ${x1} ${y0}"
    incr i
}

