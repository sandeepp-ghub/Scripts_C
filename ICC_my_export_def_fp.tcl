# fast export the def

proc my_export_def_fp {args} {
    set DESIGN_IN "../datain"
    set DESIGN_OUT "../dataout"
    global TopModule
    parse_proc_arguments -args ${args} results
    set postfixName $results(-rev)
    if {[info exists results(-block)]} {
        if {[info exists postfixName]} {
            write_floorplan  -placement {hard_macro} -objects [add_to_collection [all_macro_cells] [get_placement_blockage *]] $DESIGN_IN/$TopModule.fp${postfixName}
            write_def -version 5.5 -pins -output $DESIGN_IN/$TopModule.def${postfixName}
        } else {
            write_floorplan  -placement {hard_macro} -objects [add_to_collection [all_macro_cells] [get_placement_blockage *]] $DESIGN_IN/$TopModule.fp
            write_def -version 5.5 -pins -output $DESIGN_IN/$TopModule.def
        }
    } else {

        if {[info exists postfixName]} {
            write_floorplan  -placement {hard_macro} -objects [all_macro_cells] $DESIGN_IN/$TopModule.fp${postfixName}
            write_def -version 5.5 -pins -output $DESIGN_IN/$TopModule.def${postfixName}
        } else {
            write_floorplan  -placement {hard_macro} -objects [all_macro_cells] $DESIGN_IN/$TopModule.fp
            write_def -version 5.5 -pins -output $DESIGN_IN/$TopModule.def
        }
    }
    
}
define_proc_attributes my_export_def_fp \
    -info "this stuff will print whan user write <porc_name> -help" \
    -define_args {
        {-rev "the iter number"         "" string    optional}
       {-block "the iter number"         "" boolean  optional}

}

# import def & FP
proc my_import_def_fp {args} {
    set DESIGN_IN "../datain"
    set DESIGN_OUT "../dataout"
    global TopModule
    parse_proc_arguments -args ${args} results
    set postfixName $results(-rev)

    if {[info exists postfixName]} {
        read_def -enforce_scaling $DESIGN_IN/$TopModule.def${postfixName}        
        read_floorplan  $DESIGN_IN/$TopModule.fp${postfixName}
    } else {
        read_def -enforce_scaling $DESIGN_IN/$TopModule.def    
        read_floorplan  $DESIGN_IN/$TopModule.fp
    }
    
}
define_proc_attributes my_import_def_fp \
    -info "this stuff will print whan user write <porc_name> -help" \
    -define_args {
       {-rev "the iter number"         "" string    optional}
       {-block "the iter number"         "" boolean  optional}
}

