proc cn_define_args {procname help_string argdefs} {
    global __opt_info
    global __arg_info
    global __help_info

    set __opt_info($procname) {}
    set __arg_info($procname) {}
    
    foreach arg $argdefs {
        if {[string index [lindex $arg 0] 0] == "-"} {
            # it is an option
            lappend __opt_info($procname) $arg
        } else {
            # it is an arg
            lappend __arg_info($procname) $arg
        }
    }
    
    set __help_info($procname) $help_string
    
    # if synopsys command exists, register with its help system
    if {[info command define_proc_attributes] != {}} {
        define_proc_attributes $procname -info $help_string -define_args $argdefs
    }

}

proc cn_parse_args {var arglist} {
    global __opt_info
    global __arg_info

    set retval 1

    upvar 1 $var t

    set caller_name [lindex [split [info level [expr [info level] - 1]]] 0]
    # dc_shell tcl_mode prepends "::" to toplevel, tclsh doesn't
    if {[string range $caller_name 0 1] == "::"} {
        set caller_name [string range $caller_name 2 end]
    }
    upvar 0 __opt_info($caller_name) optdefs
    upvar 0 __arg_info($caller_name) argdefs

    set opts_allowed 1
    set argnum 0
    for {set idx 0} {$idx < [llength $arglist]} {set idx [expr $idx + 1]} {
        set targ [lindex $arglist $idx]

        # look for force end of options marker, useful when a 
        # regular arg value wants to start w/a "-"
        if {$targ == "--"} {
            set opts_allowed 0
            continue
        }

        set argmatch {}

        if {$opts_allowed && ([string index $targ 0] == "-") \
                && ![string is integer $targ] \
                && ![string is double  $targ]} {
            # this is an option, loop through argdefs
            set multimatch 0
            set exactmatch 0
            foreach arg $optdefs {
                set opt [lindex $arg 0]
                if {[string compare -length [string length $targ] $targ $opt] == 0} {

                    set ext_m  [expr [string length $targ] == [string length $opt]]

                    if {($argmatch == {}) || $ext_m} {
                        set argmatch $arg			
                        set exactmatch [expr $ext_m || $exactmatch]
                    } elseif {($argmatch != {}) && !($exactmatch)} {
                        set retval 0
                        puts "Error: more than one option matches \"$targ\" during call to $caller_name:"
                        set prevopt [lindex $argmatch 0]
                        puts "\t$prevopt";
                        set multimatch 1
                    }
                }
            }
            if $multimatch {
                set prevopt [lindex $argmatch 0]
                puts "\t$prevopt";
                continue
            }
            if {$argmatch == {}} {
                set retval 0
                puts "Error: no match found for \"$targ\" during call to $caller_name"
                continue
            }

            if {[lindex $argmatch 3] == "boolean"} {
                set val 1
            } else {
                set idx [expr $idx + 1]
                set val [lindex $arglist $idx]
            }
        } else {
            if {$argnum >= [llength $argdefs]} {
                set retval 0
                puts "Error: more arguments given than allowed during call to $caller_name"
                puts "       $arglist"
                continue
            }
            
            set argmatch [lindex $argdefs $argnum]
            set argnum [expr $argnum + 1]
            set val [lindex $arglist $idx]
        }

        set opt [lindex $argmatch 0]
        set type [lindex $argmatch 3]

        switch -exact $type {
            int { 
                if {![string is integer $val]} {
                    set retval 0
                    puts "Error: $opt requires an integer ($val)"
                    continue
                }
            }
            boolean {
                if {![string is boolean $val]} {
                    set retval 0
                    puts "Error: $opt requires a boolean ($val)"
                    continue
                }
            }
            float {
                if {![string is double $val]} {
                    set retval 0
                    puts "Error: $opt requires a float ($val)"
                    continue
                }
            }
        }

        set t($opt) $val
    }

    foreach arg [concat $optdefs $argdefs] {
        set argopt [lindex $arg 0]
        set argreq [lindex $arg 4]

        if {![info exists t($argopt)]} {
            if {$argreq == "required"} {
                set retval 0
                puts "Error: $argopt argument required"
                continue
            }

            # arg not specified
            if {([llength $arg] > 5)} {
                set argtype [lindex $arg 3]
                # arg has a default, use it
                set t($argopt) [uplevel \#0 "subst [list [lindex $arg 5]]"]
                if {($argtype == "int") || ($argtype == "float")} {
                    set t($argopt) [expr $t($argopt)]
                }
            } elseif {[lindex $arg 3] == "boolean"} {
                # arg is boolean, implicit default of 0
                set t($argopt) 0
            }
        }
    }

    return $retval
}


proc size_block_to_5nm {args} {
    cn_parse_args opts $args
    if ![info exists opts(-width)] { puts "Please specify -width <value>"; return }
    if ![info exists opts(-height)] { puts "Please specify -height <value>"; return }
    if ![info exists opts(-scale_factor_w)] { puts "Please specify -scale_factor_w <value>"; return }
    if ![info exists opts(-scale_factor_h)] { puts "Please specify -scale_factor_h <value>"; return }
    set width $opts(-width)
    set height $opts(-height)
    set scale_factor_w $opts(-scale_factor_w)
    set scale_factor_h $opts(-scale_factor_h)
    global tcl_precision
    set tcl_precision 10

    #puts "Using tcl_precision $tcl_precision"
    set pg_tile_width  7.752
    set pg_tile_height 6.720

    set new_width [expr $width * $scale_factor_w]
    set new_height [expr $height * $scale_factor_h]

    set s_width [expr [expr round($new_width / $pg_tile_width)] * $pg_tile_width]
    set s_height [expr [expr round($new_height / $pg_tile_height)] * $pg_tile_height]
    
    puts "\nBlock size (um)"
    puts " width  $s_width"
    puts " height $s_height \n"

    puts "MINT power tiles "
    puts " width  # tiles: [expr $s_width / $pg_tile_width]"
    puts " height # tiles: [expr $s_height / $pg_tile_height]\n"

    if {[info exists opts(-def)] && $opts(-def)==1} {
        set def_width  [lindex [split [expr $s_width * 1000] .] 0]
        set def_height [lindex [split [expr $s_height * 1000] .] 0]
        puts "# USE IN YOUR FLOORPLAND DEF TO USE NEW SIZE"
        puts "DIEAREA ( 0 0 ) ( 0 $def_height ) ( $def_width $def_height ) ( $def_width 0 ) ;\n"
    }

}

cn_define_args size_block_to_5nm \
    "sizes block to 5nm power tile dimenstions" \
    {
        { -width "block width" width float required }
        { -height "block height" height float required }
        { -scale_factor_w "scaling factor width of original block size" scale_factor float required }
        { -scale_factor_h "scaling factor height of original block size" scale_factor float required }
        { -def "Output DEF syntax" def boolean optional }
    }


#
# April 1 2020 - added support for new power tile
#

proc size_block_to_5nm_new_tile {args} {
    cn_parse_args opts $args
    if ![info exists opts(-width)] { puts "Please specify -width <value>"; return }
    if ![info exists opts(-height)] { puts "Please specify -height <value>"; return }
    if ![info exists opts(-scale_factor_w)] { puts "Please specify -scale_factor_w <value>"; return }
    if ![info exists opts(-scale_factor_h)] { puts "Please specify -scale_factor_h <value>"; return }
    set width $opts(-width)
    set height $opts(-height)
    set scale_factor_w $opts(-scale_factor_w)
    set scale_factor_h $opts(-scale_factor_h)
    global tcl_precision
    set tcl_precision 10

    #puts "Using tcl_precision $tcl_precision"
    # -> 4.1.2020 update width = 7.752 um   height = 10.08 um
    set pg_tile_width  7.752
    set pg_tile_height 10.08
    # added support for horizonal buffer as of 4.1.2020
    set horiz_margin   0.051
    set new_width [expr [expr $width * $scale_factor_w] + $horiz_margin]
    set new_height [expr $height * $scale_factor_h]

    set s_width [expr [expr round($new_width / $pg_tile_width)] * $pg_tile_width]
    set s_height [expr [expr round($new_height / $pg_tile_height)] * $pg_tile_height]
    
    puts "\nBlock size (um)"
    puts " width  $s_width"
    puts " height $s_height \n"

    puts "MINT power tiles "
    puts " width  # tiles: [expr $s_width / $pg_tile_width]"
    puts " height # tiles: [expr $s_height / $pg_tile_height]\n"

    if {[info exists opts(-def)] && $opts(-def)==1} {
        set def_width  [lindex [split [expr $s_width * 2000] .] 0]
        set def_height [lindex [split [expr $s_height * 2000] .] 0]
        puts "# USE IN YOUR FLOORPLAND DEF TO USE NEW SIZE"
        puts "DIEAREA ( 0 0 ) ( 0 $def_height ) ( $def_width $def_height ) ( $def_width 0 ) ;\n"
    }

}

cn_define_args size_block_to_5nm_new_tile \
    "sizes block to 5nm power tile dimenstions" \
    {
        { -width "block width" width float required }
        { -height "block height" height float required }
        { -scale_factor_w "scaling factor width of original block size" scale_factor float required }
        { -scale_factor_h "scaling factor height of original block size" scale_factor float required }
        { -def "Output DEF syntax" def boolean optional }
    }
