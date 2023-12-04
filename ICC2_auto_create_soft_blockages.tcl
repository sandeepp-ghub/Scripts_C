proc auto_create_soft_blockages {args} {

    set proc_name [regsub -all {:} [lindex [info level 0] 0] {}]
    set results(-channel_width)      25
    set results(-prefix)             $proc_name
    parse_proc_arguments -args ${args} results
    # skip proc if there are no rams at all
    if { [sizeof_collection [get_flat_cells -filter "design_type==macro"]] == 0 } {
        puts "${proc_name} Info: No hard macros found in design, skipping this proc!"
        return
    }

    # cleanup previous blockages with the give prefix
    if {[get_placement_blockages "$results(-prefix)*" -quiet] ne ""} {
        remove_placement_blockage "$results(-prefix)*"
    }
    set other_blockages [get_placement_blockages * -quiet]
     echo "${proc_name} INFO: Calculating blockages. May take some time..."
    #-- set sliver size
    set old_value [get_app_option_value -name place.floorplan.sliver_size]
    set_app_options -name place.floorplan.sliver_size -value  ${results(-channel_width)}u
#-- run command
    derive_placement_blockages -hierarchical -force
    set all_blockages [get_placement_blockages * -quiet]
    set new_blockages [remove_from_collection $all_blockages $other_blockages]
    set i 0
    foreach_in_collection nb $new_blockages {
        set_attr  $nb name ${results(-prefix)}_${i}
        echo "[get_object_name $nb ]  [get_attr $nb blockage_type]"
        incr i;
    }
    set_app_options -name place.floorplan.sliver_size -value $old_value
    return

}


define_proc_attributes auto_create_soft_blockages  \
    -info "Create soft placement blockages inside rams arrays and also between rams and die boundary." \
    -define_args {
        {-channel_width      "Max width between rams/boundary to fill with soft blockage. Default 25." "" float optional }
    }

#define_proc_attributes auto_create_soft_blockages  \
#    -info "Create soft placement blockages inside rams arrays and also between rams and die boundary." \
#    -define_args {
#        {-channel_width      "Max width between rams/boundary to fill with soft blockage. Default 25." "" float optional }
#        {-prefix             "Prefix used as the created blockages name (will be followed by e.g. '_#1'). Default 'sig_auto_create_soft_blockages'." "" string optional }
#        {-type               "Type of blockages to create. 'soft' by default. Allowed" "" one_of_string {optional value_help {values {soft hard partial}}}}
#        {-blocked_percentage "Blocked percentage for partial blockages." "" int optional }
#    }


