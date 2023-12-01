proc cellArea {cell_name} {
	Puts "==============================="
	set y [dbGetObjByName $cell_name]
	set Area 0
 	if {[dbGet $y.objType] == "topCell"} {
 		set hinsts [dbGet -e $y.hInst.allInsts]
  		foreach x $hinsts {
  			set name [dbGet $x.name]
 			set cellname [dbGet $x.cell.name]
   			if {[dbGet $x.objType] == "hInst"} {
   				set ca [hinst $x]
   				#Puts "==============================="
   				#Puts "Cell: $cellname - Top ( $cell_name ) level hInst: $name - Area: $ca"
   				#Puts "==============================="
   			} else {
   				set ca [get_property [get_cells $name] area]
   				#Puts "Cell: $cellname - Top ( $cell_name ) Inst: $name - Area: $ca"
  		 	}
  			set Area [expr $Area + $ca]
  		}
 		Puts "Queried Cell $cell_name - Area $Area"
 		} elseif {[dbGet $y.objType] == "hInst"} {
 			set Area [hinst $y]
 			Puts "Queried Cell $cell_name - Area $Area"
 			} else {
 			Puts "$cell_name is not a H Inst or not in Design"
 		}
		Puts "==============================="
}

proc hinst {arg} {
	set Area 0
	set name [dbGet $arg.name]
 	foreach x [dbGet -e $arg.allInsts] {
 		set cname [dbGet $x.name]
 		set cellname [dbGet $x.cell.name]
  		if {[dbGet $x.objType] == "hInst"} {
  			set ca [hinst $x]
  			#Puts "==============================="
  			#Puts "Cell: $cellname - $name level hInst: $cname - Area: $ca"
  			#Puts "==============================="
  		} else {
  			set ca [get_property [get_cells $cname] area]
  			#Puts "Cell: $cellname - $name level Inst: $cname - Area: $ca"
  		}
 		set Area [expr $Area + $ca]
 	}
	return $Area
}

