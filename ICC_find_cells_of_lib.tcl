proc find_cell_of_lib {} {
    set liblist ""
    set refname_list ""
    set libscc [get_lib_cells m9szd_clklib_slow0p945v125_ccstn/*]
    foreach_in_collection lcel $libscc {
        lappend liblist [get_object_name $lcel]
    }
    foreach lib $liblist {
        set llib [split $lib "/"]
        lappend refname_list [lindex $llib 1]
    }
    puts "cells with the current lib:"
    puts "___________________________"
    foreach ref_name $refname_list {
        puts [get_cells * -hier -filter "ref_name==$ref_name"]

    }

}
