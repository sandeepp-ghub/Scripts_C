##################
#Helper procs
##################
proc _get_cell_w {cell} {
    return [get_db [get_db base_cells $cell] .bbox.dx]
}

proc _get_cell_h {cell} {
    return [get_db [get_db base_cells $cell] .bbox.dy]
}

proc _get_inst_orient {inst} {
    return [get_db [get_db insts [_resolve_inst $inst]] .orient]
}

proc _get_inst_w {inst} {
    return [get_db [get_db insts [_resolve_inst $inst]] .base_cell.bbox.dx]
}

proc _get_inst_h {inst} {
    return [get_db [get_db insts [_resolve_inst $inst]] .base_cell.bbox.dy]
}

proc _get_inst_llx {inst} {
    return [get_db [get_db insts [_resolve_inst $inst]] .bbox.ll.x]
}

proc _get_inst_lly {inst} {
    return [get_db [get_db insts [_resolve_inst $inst]] .bbox.ll.y]
}

proc _get_inst_urx {inst} {
    return [get_db [get_db insts [_resolve_inst $inst]] .bbox.ur.x]
}

proc _get_inst_ury {inst} {
    return [get_db [get_db insts [_resolve_inst $inst]] .bbox.ur.y]
}

proc _get_design_llx {} {
    return [get_db designs .bbox.ll.x]
}

proc _get_design_lly {} {
    return [get_db designs .bbox.ll.y]
}

proc _get_design_urx {} {
    return [get_db designs .bbox.ur.x]
}

proc _get_design_ury {} {
    return [get_db designs .bbox.ur.y]
}

proc _get_port_x {net} {
    return [get_db [get_db ports $net] .location.x]
}

proc _get_port_y {net} {
    return [get_db [get_db ports $net] .location.y]
}

proc _get_port_w {net} {
    return [get_db [get_db ports $net] .width]
}

proc _get_flop {pat} {
    return [get_db insts $pat -if {.is_flop}]
}

proc _get_latch {pat} {
    return [get_db insts $pat -if {.is_latch}]
}

proc _set_auto_fixed_status {} {
    set_db [get_db insts AUTO_*] .place_status fixed
}

proc _set_fixed_status {regs} {
    foreach reg $regs {
        set_db [get_db insts $reg] .place_status fixed
    }
}

proc _macro_regex_match {macro_inst} {
    array set m {}
    regexp {dat[_/]row(\d+)[_/]qdtm(\d+)[_/]dtm(\d+)[/_]mem(\d+)} $macro_inst match m(row) m(qdtm) m(dtm) m(mem)
    return [array get m]
}

proc _get_macro_name {pat} {
    return [get_db [get_db [get_db insts -if {.is_macro}] . $pat -regexp] .name]
}

proc _get_macro {pat} {
    return [get_db [get_db insts -if {.is_macro}] . $pat]
}

proc _resolve_inst {inst} {
    if {[regexp {inst:} $inst]} {
        return [get_db $inst .name]
    } else {
        return $inst
    }
}

proc ipbu_info {msg} {
    puts "%IPBU_INFO% : $msg"
}

proc ipbu_get_tracks {layer dir} {
    set track_defs  [get_db track_patterns -if {.layers.name == $layer && .layers.direction == $dir}]
    # not sure why M13 returns a track which is not present
    if {$layer == "M13"} {
#        set track_defs [lreplace $track_defs 0 0]
    }
    set starts      [get_db $track_defs .start]
    set steps       [get_db $track_defs .step]
    set num_tracks   [get_db $track_defs .num_tracks]
    set widths      [get_db $track_defs .width]

    array set track_locations {}

    set cnt 0 
    foreach start $starts {
        for {set i 0} {$i<[lindex $num_tracks $cnt]} {incr i} {
            # add location and the width {loc width}
            lappend track_locations($cnt) [list [expr {$start + ($i*[lindex $steps $cnt])}]]
        }
        incr cnt
    }
    #join the tracks to get a complete list
    set tracks {}
    for {set t 0} {$t<[lindex $num_tracks 0]} {incr t} {
        for {set c 0} {$c<$cnt} {incr c} {
            if {[lsearch [lindex $track_locations($c) $t] *] != -1} {
                lappend tracks [lindex $track_locations($c) $t]
            }
        }
    }
    return [lsort -real $tracks ]
}

proc eval_cmd {cmd} {
    puts "\[INFO\] $cmd"
    eval $cmd
}

proc ipbu_add_repeater {args} {
    # This proc inserts a repeater on a net and drives all the loads on the net using that repeater
    # unless requested by the user.
    parse_proc_arguments -args $args rptr_info
    set net $rptr_info(-net)
    set loc $rptr_info(-location)
    set new_net_name $rptr_info(-new_net_name)
    set new_inst_name $rptr_info(-name)
    set rptr $rptr_info(-cell)
    
    if {[expr {[llength $loc] != 2}]} {
        puts "Usage: ipbu_add_repeater -net <net_name_to_repeat> -location {x y} -new_net_name <new_net_name> -name <new_inst_name> -cell <rptr_cell>"
        return 1
    }
    #Substitute any [ ] with __
    regsub -all {\[} $net __ nnet
    regsub -all {\]} $nnet __ nnet
    regsub -all {/} $nnet _ nnet
    
    #to preserve the route attributes. As doing connect_pins seems to get rid of route_attributes set previously
    set net_is_dont_touch [get_db [get_db nets $net] .dont_touch]
    array set croute_attributes [join [get_route_attributes -nets $net -quiet]]
    
    #create a new net in the design
    set auto_net $new_net_name
    create_net -name $auto_net
    #

    #create a new instance of the repeater
    set auto_inst $new_inst_name
    create_inst -cell $rptr -inst $auto_inst -location $loc 
    #
    
    #Find all the connections to the net and find the input(s) and the output(s) of that net
    set net_iterms {}
    set net_opinterms {}
    set term_o [all_connected -leaf $net] 
    set net_iterms    [get_db [get_db $term_o -if {(.direction == in) && (.obj_type != port)}] .name]
    set net_opinterms [get_db [get_db $term_o -if {(.direction == out) && (.obj_type == port)}] .name]
    set net_drvterm [get_db [get_db $term_o -if {(.direction == out) && (.obj_type != port)}] .name]
    
    set rptr_iterm [get_db [get_db [get_db base_cells $rptr] .base_pins -if {.direction == in}] .base_name]
    set rptr_oterm [get_db [get_db [get_db base_cells $rptr] .base_pins -if {.direction == out}] .base_name]
    
    ##Attach the terms to make the connection
    if {[get_db [get_db ports $net] .direction] == "out"} {
        connect_pin -inst $auto_inst -pin $rptr_iterm -net $auto_net
        connect_pin -inst $auto_inst -pin $rptr_oterm -net $net
        regexp {(.*)\/(.*)} $net_drvterm match inst term
        connect_pin -inst $inst -pin $term -net $auto_net
        
    } else {
        connect_pin -inst $auto_inst -pin $rptr_iterm -net $net
        connect_pin -inst $auto_inst -pin $rptr_oterm -net $auto_net
    }
    
    # all the hinst inputs
    if {\
            (([get_db [get_db ports $net] .direction] == "in") && ![info exist rptr_info(-dont_drive_sideload)]) || \
            (([get_db [get_db ports $net] .direction] == "out") && [info exist rptr_info(-dont_drive_sideload)])\
        } {
        foreach net_iterm $net_iterms {
            if {$net_iterm != ""} {
                regexp {(.*)\/(.*)} $net_iterm match inst term
                connect_pin -inst $inst -pin $term -net $auto_net
            }
        }
    }
    
    # all the output pins 
    #    foreach net_opinterm $net_opinterms {
    #        if {$net_opinterm != ""} {
    #            connect_hpin -hinst - -pin_name $net_opinterm -net $auto_net
    #        }
    #}
    #propagate dont touch and other route attributes
    if {$net_is_dont_touch} {
        set_dont_touch $net
        set_dont_touch $auto_net
    }
    #propagate route attributes
    set croute_attrs [array get croute_attributes]
    set route_attr_options ""
    for {set i 0} {$i<[llength $croute_attrs]} {incr i 2} {
        set attr [lindex $croute_attrs $i]
        if {($attr == "voltage") || ($attr == "avoid_chaining") || ($attr == "is_selected")} {
            continue
        }
        set route_attr_options "${route_attr_options} -[lindex $croute_attrs $i] [lindex $croute_attrs [expr {$i+1}]]"
    }
    set cmd "set_route_attributes -nets $net $route_attr_options"
    eval $cmd
    set cmd "set_route_attributes -nets $auto_net $route_attr_options"
    eval $cmd
    return [list $auto_inst $net $auto_net]
}

define_proc_arguments ipbu_add_repeater -info "Custom add_repeater routine" \
    -define_args {\
                      {-net "specify the net name to repeat" "" string required}\
                      {-location "specify the {x y} location" "" string required}\
                      {-new_net_name "new net name" "" string required}\
                      {-name "instance name of the created instance" "" string required}\
                      {-cell "the repeater cell to use" "" string required}\
                      {-dont_drive_sideload "Don't use the output of the repeater to drive the sideload [default always drive the sideload using the newly inserted repeater]" "" bool optional}\
                  }

###############################################################################
proc fopenw {file_name} {
    return [open $file_name w]
}

proc fopena {file_name} {
    return [open $file_name a]
}

proc fread {file_name} {
    set fh [fopenr $file_name]
    zlib push gunzip $fh
    set read_lines {}
    foreach l [split [read $fh] "\n"] {
        lappend read_lines $l
    }
    close $fh
    return $read_lines
}


proc fwrite {args} {
    parse_proc_arguments -args $args wargs
    set fh [fopenw $wargs(-file)]
    foreach l $wargs(-wlist) {
        puts $fh $l
    }
    close $fh
}
define_proc_arguments fwrite -info "Write to a file" \
    -define_args {\
                      {-file "File name to write to" "" string required}\
                      {-wlist "List of statements to write" "" string required}\
                  }




proc mutil_octstrip { x } {
    if {([string length $x] > 1) && ([string index $x 0]==0)} {
        return [string range $x 1 end]
    } else {
        return $x
    }
}    
proc mutil_octfix { num } {
    return [lmap x $num { mutil_octstrip $x}]
}

proc mutil_dbu2um { args } {
    return [mutil_octfix [convert_dbu_to_um {*}$args]]
}

proc mutil_um2dbu { args } {
    return [mutil_octfix [convert_um_to_dbu {*}$args]]
}

proc um2track { args } {

parse_proc_arguments -args $args t

        set layer_name [string toupper $t(-layer)]
        set um $t(-um)
        set dbu [mutil_um2dbu $um]
        
        if { ! [llength [get_db layers -if { .name == $layer_name }]] } {
            mint_error -msg "(track2um) Layer: $layer_name does NOT exist.  Please use one of: get_db layers .name"
        }

        set pref_dir [get_db [get_db layers $layer_name] .direction]

        set track_dir "x"
        if { $pref_dir == "horizontal" } { set track_dir "y" }

        #set track_patterns [get_db track_patterns -if { .layers.name == $layer_name && .direction == $track_dir && .route_rule eq "" } ]
        set track_patterns [get_sorted_tracks $layer_name $track_dir]
        set num_tpat [llength $track_patterns]

        set tpat_idx 0
        set min_dbu_delta 999999999
        set stored_snap_um 0
        set curr_tpat_idx 0
        set stored_internal_track_num 0
        foreach track_pattern $track_patterns {

            set track_start [mutil_um2dbu [get_db $track_pattern .start]]
            set track_step [mutil_um2dbu [get_db $track_pattern .step]]

            if { [info exists t(-ceil)] } {
                set internal_track_num [expr int(ceil(double($dbu - $track_start) / $track_step ))]
                set snap_dbu [expr (double($internal_track_num) * $track_step) + $track_start]
                set dbu_delta [expr $snap_dbu - $dbu]
                if { $dbu_delta < 0 } {
                    mint_error -msg "Calc snap_dbu: $snap_dbu < dbu: $dbu ... snap_dbu should NEVER be less than dbu with -ceil option"
                    incr curr_tpat_idx
                    continue
                }
            } else {
                set internal_track_num [expr int(($dbu - $track_start) / $track_step ) ]
                set snap_dbu [expr (double($internal_track_num) * $track_step) + $track_start]
                set dbu_delta [expr abs($snap_dbu - $dbu)]
            }
            if { $dbu_delta < $min_dbu_delta } {
                set min_dbu_delta $dbu_delta
                set tpat_idx $curr_tpat_idx
                set stored_snap_dbu $snap_dbu
                set stored_internal_track_num $internal_track_num
            }
            incr curr_tpat_idx
        }

        return [expr ($stored_internal_track_num * $num_tpat) + $tpat_idx]


}

define_proc_arguments um2track -info "Print conversion of um to power track in the preferred direction" \
    -define_args {\
	    { -um                       "Microns" {um} float required }\
	    { -layer                    "Layer Name" {layer} string required }\
	    { -ceil                     "Ceiling" {ceil} boolean optional }\
	    { -floor                    "floor" {floor} boolean optional }\
	}



proc tracksort {a b} {
    return [expr [get_db $a .start] > [get_db $b .start]]
}

proc get_sorted_tracks { layer dir } {
    if {![info exists ::MINT_PRECALC_TRACKS] || ![dict exists $::MINT_PRECALC_TRACKS $layer $dir]} {

        set sorted_tracks [lsort -command tracksort [get_db track_patterns -if {.layers.name==$layer && .direction == $dir && .route_rule eq "" } ] ]

        dict set ::MINT_PRECALC_TRACKS $layer $dir $sorted_tracks
    }

    return [dict get $::MINT_PRECALC_TRACKS $layer $dir]
    
}





# Convert track um
proc track2um { args } {
parse_proc_arguments -args $args t

        set layer_name [string toupper $t(-layer)]
        set track_num $t(-num)
        if { ! [llength [get_db layers -if { .name == $layer_name }]] } {
            mint_error -msg "(track2um) Layer: $layer_name does NOT exist.  Please use one of: get_db layers .name"
        }

        set pref_dir [get_db [get_db layers $layer_name] .direction]

        set track_dir "x"
        if { $pref_dir == "horizontal" } { set track_dir "y" }

        set track_patterns [get_sorted_tracks $layer_name $track_dir]
        #set track_patterns [get_db track_patterns -if { .layers.name == $layer_name && .direction == $track_dir && .route_rule eq "" }]
        set num_tpat [llength $track_patterns]

        set track_starts [get_db $track_patterns .start]
        set track_steps [get_db $track_patterns .step]

        set track_start [expr double( [lindex $track_starts [expr $track_num % $num_tpat]] )]
        set track_step [expr double( [lindex $track_steps [expr $track_num % $num_tpat]] )]

        set track_mult [expr int(floor(double($track_num)/double($num_tpat)))]

        return [expr $track_start + $track_mult*$track_step]

}
define_proc_arguments track2um -info "Print conversion of um to power track in the preferred direction" \
    -define_args {\
	    { -num                      "Global track number" {num} int required }\
	    { -layer                    "Layer Name" {layer} string required }\
	}


