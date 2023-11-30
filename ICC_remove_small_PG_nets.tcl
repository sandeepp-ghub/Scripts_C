##################################################
# remove small shapes of metal from pg to remove # 
# unconnected pg metals between rams             #
#                                                #
# Lior Allerhand 16.12.12                        #
##################################################

proc remove_small_pg_nets {args} {
    unset -nocomplain all_metals2
    unset -nocomplain all_metals5
    set maxMetal2L 1.5
    set maxMetal5L 1.5
    parse_proc_arguments -args $args results
    if {[info exists results(-maxMetal2L)]} {set maxMetal2L $results(-maxMetal2L) }
    if {[info exists results(-maxMetal5L)]} {set maxMetal5L $results(-maxMetal5L) }

    set vdd2 [get_net_shape -filter "owner_net==VDD AND layer==metal2"]
    set vss2 [get_net_shape -filter "owner_net==VSS AND layer==metal2"]
    set vdd5 [get_net_shape -filter "owner_net==VDD AND layer==metal5"]
    set vss5 [get_net_shape -filter "owner_net==VSS AND layer==metal5"]
    
    append_to_collection all_metals2 [list $vdd2 $vss2] 
    append_to_collection all_metals5 [list $vdd5 $vss5]
    set metal2list [collection_to_list -name_only -no_braces $all_metals2]
    set metal5list [collection_to_list -name_only -no_braces $all_metals5]
    foreach m $metal2list {
        set mLength [get_attr [get_net_shape $m] length] 
        if {$mLength<=$maxMetal2L} {
            if {[info exists results(-highlight_only)]} {
                change_selection -add [get_net_shape $m]                
            } else {
                remove_objects [get_net_shape $m] 
                puts "removing metal2 shape  $m $mLength ..."
                    
            }
        }
    }
    foreach m $metal5list {
        set mLength [get_attr [get_net_shape $m] length] 
        if {$mLength<=$maxMetal5L} {
            if {[info exists results(-highlight_only)]} {
                change_selection -add [get_net_shape $m]
            } else {
                puts "removing metal5 shape  $m $mLength ..."
                remove_objects [get_net_shape $m]
            }
        }
    }

    if {[info exists results(-highlight_only)]} { gui_change_highlight -add -color red  -collection [get_selection] }

    puts "Done..."
    return ""


}

define_proc_attributes remove_small_pg_nets \
    -info "remove small metals from pg network. used to remove metals from narrow channel between rams -help" \
    -define_args {
         {-maxMetal2L float "remove all metal2 smaller than val ,default is 1u "  float optional}
         {-maxMetal5L float "remove all metal5 smaller than val ,default is 1u"   float optional}
         {-highlight_only     ""           "" boolean optional}

        
}

