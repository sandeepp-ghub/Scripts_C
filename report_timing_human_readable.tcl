#====================================================================#
#                       M A R V E L L - IPBU                         #
#                       ====================                         #
# Date: 22/4/13 Updated 31/03/19                                     #
#====================================================================#
# Script Owner: Lior  Allerhand                                      #
#====================================================================#
# Description: more readable format of report timing                 #
#====================================================================#
# Example: mrt -from -to  -startpoints                               #
#====================================================================#

proc mrt {args} {
#    global synopsys_program_name
    set results(-path_group)        {}
    set results(-from)              {}
    set results(-to)                {}
    set results(-thr)               {}
    set results(-scenarios)         {}
    set results(-max_p)             {1}
    set results(-nworst)            {1}
    set results(-slack_lesser_than) {}
    set results(-neg_only)          {0}
    set results(-endpoints)         {0}
    set results(-startpoints)       {0}
    set results(-clock_skew)        {0}
    set results(-xtalk)             {0}
    set results(-gates)             {0}
    set results(-clocks)            {false}
# INN work diff    set results(-min)               {false}
    set results(-pba)               {}
    set results(-exclude)           {}
    set results(-draw_paths)        {0}
    set results(-draw_full_paths)   {0}
    set results(-clear)             {0}
    set results(-dontClear)         {0}
    set results(-skip_paths)        {0}
    #-- parse command line arguments
    parse_proc_arguments -args $args results
    foreach v [array names results] {
        regsub {^\-} $v {} vn
        eval "set i_${vn} \$results($v)"
    }

#    suppress_message UITE-479       
#    suppress_message UITE-416

    set cmd_ "report_timing -collection"
    if {$i_path_group != ""} {append cmd_ " -path_group $i_path_group"}
    if {$i_from != ""}       {append cmd_ " -from $i_from"}
    if {$i_to != ""}         {append cmd_ " -to $i_to"}
    if {$i_thr != ""}        {append cmd_ " -through $i_thr"}
#    if {$i_scenarios != ""} {append cmd_ " -scenarios $i_scenarios"}
    if {$i_neg_only}         {append cmd_ " -slack_l 0"} elseif {$i_slack_lesser_than != ""} {append cmd_ " -slack_l $i_slack_lesser_than"}
    if {$i_max_p > 1}        {append cmd_ " -max_path $i_max_p"}
    if {$i_nworst > 1}       {append cmd_ " -nworst $i_nworst"}
# INN work diff    if {$i_min != "false"}   {append cmd_ " -delay_type min"}    
    if {$i_pba != ""}        {append cmd_ " -pba $i_pba"}    
    if {$i_exclude != ""}    {append cmd_ " -exclude \"$i_exclude\""}
    if {$i_xtalk||$i_draw_full_paths}            {append cmd_ " -path_type full_clock"}
    
    #-- remove last draw
    if {($i_draw_paths && !$i_dontClear)||($i_draw_full_paths && !$i_dontClear)||$i_clear} { 
        gui_clear_highlight -all ;
        delete_obj  [get_db gui_lines];
        delete_obj  [get_db gui_rects];
        delete_obj [get_db gui_texts];
    }

   
    puts "cmd_ => $cmd_"
    set i 1
    foreach_in_collection path [eval $cmd_] {
    if {$i <= $i_skip_paths} {incr i;continue}
	set slack [format {%0.3f} [get_property $path slack]]
	if {$i_endpoints} {
	    set endpoint [get_object_name [get_property $path endpoint]]	    
	    set str "\[$i\] $endpoint $slack"
	} elseif {$i_startpoints} {
	    set startpoint [get_object_name [get_property $path startpoint]]
	    set str "\[$i\] $startpoint $slack"
	} elseif {$i_clocks != "false"} {
	    set start_clock [get_object_name [get_property $path startpoint_clock]]
	    set end_clock [get_object_name [get_property $path endpoint_clock]]
	    set str "\[$i\] $start_clock --> $end_clock $slack"	    
	} else {
        #-- print bothe start and endpoints
	    set startpoint [get_object_name [get_property $path startpoint]]	
	    set endpoint [get_object_name [get_property $path endpoint]]	    
	    set str "\[$i\] $startpoint --> $endpoint $slack"
	}
    if {$i_clock_skew} {
       set scl [get_property $path startpoint_clock_latency -quiet]
       set ecl  [get_property $path endpoint_clock_latency   -quiet]
       if {$scl eq ""} {set scl 0}
       if {$ecl eq ""} {set ecl 0}
       set skew [expr {double($ecl) - $scl}]
       set scl  [format {%0.3f} $scl]
       set ecl  [format {%0.3f} $ecl]
       set skew [format {%0.3f} $skew]
       set str "$str ${scl}(Lnc) ${ecl}(Cpt) ${skew}(Skew)"
    }
    if {$i_xtalk||$i_gates||$i_draw_paths||$i_draw_full_paths} {
        set points [get_property $path points]
        set obj [get_property $points object]
        set path_delay [get_property $path path_delay]
        if {$i_gates} {
            set allCells [get_cells -of $obj -quiet]
            set routeNum [sizeof_collection [filter_collection $allCells "ref_name=~*BUF*||ref_name=~*INV*||ref_name=~*DLY*||ref_name=~*CKND*||ref_name=~*CKBD*"]]
            set logicNum [sizeof_collection [filter_collection $allCells "ref_name!~*BUF*&&ref_name!~*INV*&&ref_name!~*DLY*&&ref_name!~*CKND*&&ref_name!~*CKBD*"]]
            set str "$str ${path_delay}(Data path) ${logicNum}(Lgc) ${routeNum}(Buf)"
        }
        if {$i_xtalk||$i_draw_full_paths} {
#            echo "DBUG LLLLLLLLLLLLLLLLLL"
            set spcPoints [get_property [get_property $path launch_clock_path -quiet]  timing_points]
            set epcPoints [get_property [get_property $path capture_clock_path -quiet] timing_points]


        }
        if {$i_xtalk} {
#            if {$synopsys_program_name ne "icc2_shell"} {echo "Warning A point xtalk attribute name for dc/icc/pt is NE. call lioral if you see false Zero at xtalk value" }
            set dataDelta  0
            set clockDelta 0
            #-- going over data.
            foreach_in_collection p $points {
                #echo [get_object_name [get_property $p object]]
                set dataDeltaP [get_property $p delta_delay -quiet ]
                #echo $dataDeltaP
                if {$dataDeltaP ne ""} {set dataDelta [expr {double($dataDelta) + $dataDeltaP}]}
            }
            #-- going over start point clock.
            foreach_in_collection p $spcPoints {
                set clockDeltaP [get_property $p delta_delay -quiet ]
                #echo $clockDeltaP
                if {$clockDeltaP ne ""} {set clockDelta [expr {double($clockDelta) + abs($clockDeltaP)}]}
            }
            #-- going over end point clock.
            foreach_in_collection p $epcPoints {
                set clockDeltaP [get_property $p delta_delay -quiet ]
                #echo $clockDeltaP
                if {$clockDeltaP ne ""} {set clockDelta [expr {double($clockDelta) + abs($clockDeltaP)}]}
            }
            set dataDelta   [format {%0.3f} $dataDelta]
            set clockDelta  [format {%0.3f} $clockDelta]
            set str "$str ${dataDelta}(Xdata) ${clockDelta}(Xclk)"
        }
     }
    if {$i_draw_full_paths} {
        set color blue
        set x 0;
        set y 0;
        foreach_in_collection p [get_property $spcPoints object] {
#if {[get_property $p object_class] eq "pin"}  {set cell  [get_cells -of $p]}
            if {[get_property $p object_class] eq "pin"}  {set cell  [get_db $p .inst]}
            if {[get_property $p object_class] eq "port"} {set cell  $p                }
#            echo "DBG0 [get_object_name $p]"
            set xy [GetCellXY2 $cell];
#           echo "DBG::  $xy"
            set x_next [lindex $xy 0]
            set y_next [lindex $xy 1]
            gui_highlight -pattern solid -color pink $cell

#  gui_change_highlight -add -color $color  -collection $cell
            #-- chk that this is not the first cell on the list or no arrow is needed.
            if {$x eq "0" && $y eq "0"} {#notting;} else {
                if {$x eq $x_next && $y eq $y_next} {#notting you are at the same cell } else {
                    set_layer_preference $color -color $color -is_visible 1 -line_width 2
                    create_gui_shape -layer $color -line "$x $y $x_next $y_next" -arrow
                }
            }
            set x $x_next;
            set y $y_next;
        }
     }

     if {$i_draw_paths||$i_draw_full_paths} {
        set color yellow
        set x 0;
        set y 0;
        foreach_in_collection p $obj {
#if {[get_property $p object_class] eq "pin"}  {set cell  [get_cells -of $p]}
            if {[get_property $p object_class] eq "pin"}  {set cell  [get_db $p .inst]}
            if {[get_property $p object_class] eq "port"} {set cell  $p                }
#            echo "DBG0 [get_object_name $p]"
            set xy [GetCellXY2 $cell];
#           echo "DBG::  $xy"
            set x_next [lindex $xy 0]
            set y_next [lindex $xy 1]
            gui_highlight -pattern solid -color red $cell

#  gui_change_highlight -add -color $color  -collection $cell
            #-- chk that this is not the first cell on the list or no arrow is needed.
            if {$x eq "0" && $y eq "0"} {#notting;} else {
                if {$x eq $x_next && $y eq $y_next} {#notting you are at the same cell } else {
                    set_layer_preference $color -color $color -is_visible 1 -line_width 1
                    create_gui_shape -layer $color -line "$x $y $x_next $y_next" -arrow
                }
            }
            set x $x_next;
            set y $y_next;
        }
     }

    if {$i_draw_full_paths} {
        set color green
        set x 0;
        set y 0;
        foreach_in_collection p [get_property $epcPoints object] {
#if {[get_property $p object_class] eq "pin"}  {set cell  [get_cells -of $p]}
            if {[get_property $p object_class] eq "pin"}  {set cell  [get_db $p .inst]}
            if {[get_property $p object_class] eq "port"} {set cell  $p                }
#            echo "DBG0 [get_object_name $p]"
            set xy [GetCellXY2 $cell];
#           echo "DBG::  $xy"
            set x_next [lindex $xy 0]
            set y_next [lindex $xy 1]
            gui_highlight -pattern solid -color purple $cell

#  gui_change_highlight -add -color $color  -collection $cell
            #-- chk that this is not the first cell on the list or no arrow is needed.
            if {$x eq "0" && $y eq "0"} {#notting;} else {
                if {$x eq $x_next && $y eq $y_next} {#notting you are at the same cell } else {
                    set_layer_preference $color -color $color -is_visible 1 -line_width 2
                    create_gui_shape -layer $color -line "$x $y $x_next $y_next" -arrow
                }
            }
            set x $x_next;
            set y $y_next;
        }
     }





        # PrintPoints $points
        puts $str
	    incr i
    }
#    unsuppress_message UITE-479 
#    unsuppress_message UITE-416
}

define_proc_arguments mrt \
    -info "my report timing" \
    -define_args {
	{-path_group         "group name"                              "<group_name>" string optional}
	{-from               "from"                                    "<from>" string optional}
	{-to                 "to"                                      "<to>" string optional}
	{-thr                "thr"                                     "<thr>" string optional}
	{-scenarios          "scenarios"                               "<max/min0-99>" string optional}
	{-max_p              "max_paths"                               "<value>" int optional}
	{-nworst             "number of worst path to endpoint"        "<value>" int optional}
	{-slack_lesser_than  "only paths with slack lesser than"       "<value>" float optional}	
	{-neg_only           "only negative paths"                     "" boolean optional}	
	{-endpoints          "endpoints only"                          "" boolean optional}
	{-startpoints        "startpoints only"                        "" boolean optional}
	{-clocks             "get startpoint & endpoints clocks"       "" boolean optional}
	{-clock_skew         "report clock skew "                      "" boolean optional}
	{-xtalk              "report clock and data xtalk sum "        "" boolean optional}
	{-gates              "report number of logic and route gates " "" boolean optional}
	{-draw_paths         "highlight paths on gui"                  "" boolean optional}
	{-draw_full_paths    "highlight data and clock paths on gui"   "" boolean optional}
	{-clear              "clear highlighted paths on gui"          "" boolean optional}
	{-dontClear          "Dont clear highlighted paths on gui"          "" boolean optional}
	{-pba                "pba mode (e/p) "                         "<value>" string optional}
	{-exclude            "exclude list"                            "<exclude_list>" string optional}
    {-skip_paths         "skip the first n paths"                  "<value>" int optional}
}

proc PrintPoints {points} {
    set pins [get_property $points object]
    foreach_in_collection pin $pins {
        echo [get_object_name $pin]
    }
}

proc GetCellXY2 {cell} {
    if {[get_db $cell .obj_type] eq "hport" ||[get_db $cell .obj_type] eq "port"} {
        set box [get_db [get_db ports [get_db $cell .base_name]] .location]
        set x_mid [lindex $box 0]
        set y_mid [lindex $box 1]
#        echo "$x_mid $y_mid"
        return "$x_mid $y_mid"
    }
# echo "DBG $cell [get_object_name $cell] [get_db $cell .obj_type]"
    set bbox [get_db $cell .bbox]
    set x0 [lindex [lindex $bbox 0] 0]
    set y0 [lindex [lindex $bbox 0] 1]
    set x1 [lindex [lindex $bbox 0] 2]
    set y1 [lindex [lindex $bbox 0] 3]
    set x_mid [expr (${x0} + ${x1})/2]
    set y_mid [expr (${y0} + ${y1})/2]
#    echo "$x_mid $y_mid"
    return "$x_mid $y_mid"
}



#	{-min                "report for hold "                        "" boolean optional}

