proc report_macro_area_per_module {args} {
  parse_proc_arguments -args $args options
  set filename "$options(-file)"
  if {[info exists options(-sort)]} {
    set sort "$options(-sort) "
    puts "CDNAE-INFO: sorting option not implemented yet"
  } else {set sort ""}
set file [open $filename w]
set macros [get_db insts -if { .base_cell.base_class == block} ]
array set module ""
#######################
foreach i $macros {
set hinst [get_db $i .parent.name]
lappend module($hinst) $i
}
puts $file "Number of macros\t\tArea of macros\t\tModule name"
foreach i [array names module] {
  set area 0
   foreach inst $module($i) {
     set area [expr $area + [get_db $inst .area]]
   }
  puts $file "[llength $module($i)]\t\t$area\t\t$i"
}
array unset module
close $file
}

define_proc_arguments report_macro_area_per_module  \
-info "Report the macro area per logical hierarchy (LEF baseClass block)\n"  \
-define_args {
    {-file "file name" "none" string {required}}
    {-sort "sort key " "area|number" string {optional}}
  }


