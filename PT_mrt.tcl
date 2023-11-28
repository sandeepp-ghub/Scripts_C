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
# mrt -group rclk -min -print_path -print_path_regx dss_dch_top  -max_p 100000 -print_path_in

proc mrt {args} {
    global run_type_specific
    global synopsys_program_name
    set results(-group)             {}
    set results(-from)              {}
    set results(-to)                {}
    set results(-thr)               {}
#    set results(-scenarios)         {*}
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
    set results(-min)               {false}
    set results(-pba)               {}
    set results(-exclude)           {}
    set results(-draw_paths)        {0}
    set results(-print_path_regx)   {.*}
    set results(-print_path)        {0}
    set results(-print_path_in)        {0}
    #-- parse command line arguments
    parse_proc_arguments -args $args results
    foreach v [array names results] {
        regsub {^\-} $v {} vn
        eval "set i_${vn} \$results($v)"
    }

    if {[info exists run_type_specific]} {set runty $run_type_specific} else {set runty "unkno"}
    suppress_message UITE-479       
    suppress_message UITE-416

    set cmd_ "get_timing_path -include_hierarchical_pins"
    if {$i_group != ""}     {append cmd_ " -group $i_group"}
    if {$i_from != ""}      {append cmd_ " -from $i_from"}
    if {$i_to != ""}        {append cmd_ " -to $i_to"}
    if {$i_thr != ""}       {append cmd_ " -thr $i_thr"}
#    if {$i_scenarios != ""} {append cmd_ " -scenarios $i_scenarios"}
    if {$i_neg_only}        {append cmd_ " -slack_l 0"} elseif {$i_slack_lesser_than != ""} {append cmd_ " -slack_l $i_slack_lesser_than"}
    if {$i_max_p > 1}       {append cmd_ " -max_path $i_max_p"}
    if {$i_nworst > 1}      {append cmd_ " -nworst $i_nworst"}
    if {$i_min != "false"}  {append cmd_ " -delay_type min"; set check "min"  } else {set check "max"}    
    if {$i_pba != ""}       {append cmd_ " -pba $i_pba"}    
    if {$i_exclude != ""}   {append cmd_ " -exclude \"$i_exclude\""}
    if {$i_xtalk}           {append cmd_ " -path_type full_clock_ex"}
    
    #-- remove last draw
    if {$i_draw_paths} {
        gui_change_highlight -remove -all_colors
        gui_remove_all_annotations -group mrt
    }
    #puts "cmd_ => $cmd_"
    set i 1
    set paths [eval $cmd_]
    if {$paths eq "" && $i_print_path} {
        regsub {dss\*\/dmc_ch\*\/} $i_thr {} port
        echo "[format "%-*s %-*s" 45 $port 8 "NC" ]" >> mrt_budget_out.rpt
        
    }
    foreach_in_collection path $paths {
	set slack [format {%0.3f} [get_attribute $path slack]]
	if {$i_endpoints} {
	    set endpoint [get_object_name [get_attribute $path endpoint]]	    
	    set str "\[$i\] $endpoint $slack"
	} elseif {$i_startpoints} {
	    set startpoint [get_object_name [get_attribute $path startpoint]]
	    set str "\[$i\] $startpoint $slack"
	} elseif {$i_clocks != "false"} {
	    set start_clock [get_object_name [get_attribute $path startpoint_clock]]
	    set end_clock [get_object_name [get_attribute $path endpoint_clock]]
	    set str "\[$i\] $start_clock --> $end_clock $slack"	    
	} else {
        #-- print bothe start and endpoints
	    set startpoint [get_object_name [get_attribute $path startpoint]]	
	    set endpoint [get_object_name [get_attribute $path endpoint]]	    
	    set str "\[$i\] $startpoint --> $endpoint $slack"
	}
    if {$i_clock_skew} {
       set scl [get_attr $path startpoint_clock_latency -quiet]
       set ecl  [get_attr $path endpoint_clock_latency   -quiet]
       if {$scl eq ""} {set scl 0}
       if {$ecl eq ""} {set ecl 0}
       set skew [expr {double($ecl) - $scl}]
       set scl  [format {%0.3f} $scl]
       set ecl  [format {%0.3f} $ecl]
       set skew [format {%0.3f} $skew]
       set str "$str ${scl}(Lnc) ${ecl}(Cpt) ${skew}(Skew)"
    }
    if {$i_xtalk||$i_gates||$i_draw_paths} {
        set points [get_attr $path points]
        set obj [get_attr $points object]
        if {$i_gates} {
            set allCells [get_cells -of $obj -quiet]
            set routeNum [sizeof_collection [filter_collection $allCells "ref_name=~*BUF*||ref_name=~*INV*||ref_name=~*DLY*"]]
            set logicNum [sizeof_collection [filter_collection $allCells "ref_name!~*BUF*&&ref_name!~*INV*&&ref_name!~*DLY*&&is_hierarchical==false"]]
            set str "$str  ${logicNum}(Lgc) ${routeNum}(Buf)"
        }
        if {$i_xtalk} {
            if {$synopsys_program_name ne "icc2_shell"} {echo "Warning A point xtalk attribute name for dc/icc/pt is NE. call lioral if you see false Zero at xtalk value" }
            set dataDelta  0
            set clockDelta 0
            set spcPoints [get_attr $path startpoint_clock -quiet]
            set epcPoints [get_attr $path endpoint_clock -quiet]
            #-- going over data.
            foreach_in_collection p $points {
                set dataDeltaP [get_attr $p delta_delay -quiet ]
                if {$dataDeltaP ne ""} {set dataDelta [expr {double($dataDelta) + $dataDeltaP}]}
                
            }
            #-- going over start point clock.
            foreach_in_collection p $spcPoints {
                set clockDeltaP [get_attr $p delta_delay -quiet ]
                if {$clockDeltaP ne ""} {set dataDelta [expr {double($clockDelta) + $clockDeltaP}]}
            }
            #-- going over end point clock.
            foreach_in_collection p $epcPoints {
                set clockDeltaP [get_attr $p delta_delay -quiet ]
                if {$clockDeltaP ne ""} {set clockDelta [expr {double($clockDelta) + $clockDeltaP}]}
            }
            set dataDelta   [format {%0.3f} $dataDelta]
            set clockDelta  [format {%0.3f} $clockDelta]
            set str "$str ${dataDelta}(Xdata) ${clockDelta}(Xclk)"
        }
     }
     if {$i_print_path} {
        set end_clock [get_object_name [get_attribute $path endpoint_clock]]
        set points [get_attr $path points]
        foreach_in_collection p $points {
            set name "[get_object_name [get_attr $p object]]"
            if {[get_attr [get_cells -of [get_attr $p object]] ref_name] eq "dss_2ch" ||[get_attr [get_cells -of [get_attr $p object]] ref_name] eq "dss_2ch_corner"} {
#            if {[get_attr [get_cells -of [get_attr $p object]] ref_name] eq "dmc" ||[get_attr [get_cells -of [get_attr $p object]] ref_name] eq "dmc"} {}
                 echo "YES1"
                if {$i_print_path_in && [get_attr [get_attr $p object] direction] == "in"} {}
                if {[get_attr [get_attr $p object] direction] == "in"} {
                echo "YES2:in "
                    set direc "in"
                    regsub {dss.\/} $name {} name
                    if {[info exists MDB($name,slack)]} {
                        if {$MDB($name,slack) > $slack} {
                            set MDB($name,slack) $slack
                            set MDB($name,clock) $end_clock
                            set MDB($name,direc) $direc
                            set MDB($name,check) $check
                            set MDB($name,point) $endpoint
                            set MDB($name,runty) $runty
                        }

                    } else {
                        set MDB($name,slack) $slack
                        set MDB($name,clock) $end_clock
                        set MDB($name,direc) $direc
                        set MDB($name,check) $check
                        set MDB($name,point) $endpoint
                        set MDB($name,runty) $runty
                    }
                } elseif {[get_attr [get_attr $p object] direction] == "out"} {
                    echo "YES3:out"
                    set direc "out"
                    regsub {dss.\/} $name {} name
                    if {[info exists MDB($name,slack)]} {
                        if {$MDB($name,slack) > $slack} {
                            set MDB($name,slack) $slack
                            set MDB($name,clock) $end_clock
                            set MDB($name,direc) $direc
                            set MDB($name,check) $check
                            set MDB($name,point) $startpoint
                            set MDB($name,runty) $runty
                        }
                    } else {
                        set MDB($name,slack) $slack
                        set MDB($name,clock) $end_clock
                        set MDB($name,direc) $direc
                        set MDB($name,check) $check
                        set MDB($name,point) $startpoint
                        set MDB($name,runty) $runty
                    }
                    #set str "$str \n $name"
                }
            }
        }
     }

     if {$i_draw_paths} {
        set color yellow
        set x 0;
        set y 0;
        foreach_in_collection p $obj {
            if {[get_attr $p object_class] eq "pin"}  {set cell  [get_cells -of $p]}
            if {[get_attr $p object_class] eq "port"} {set cell  $p                }
            set xy [GetCellXY $cell];
#            echo "DBG::  $xy"
            set x_next [lindex $xy 0]
            set y_next [lindex $xy 1]
            gui_change_highlight -add -color $color  -collection $cell
            #-- chk that this is not the first cell on the list or no arrow is needed.
            if {$x eq "0" && $y eq "0"} {#notting;} else {gui_add_annotation -group mrt -window [gui_get_current_window -types Layout] -type arrow [list [list $x $y]     [list $x_next $y_next]] -width 2 -color $color}
            set x $x_next;
            set y $y_next;
        }
     }
        # PrintPoints $points
        puts "$str"
	    incr i
    }
    unsuppress_message UITE-479 
    unsuppress_message UITE-416
    #echo "" > mrt_budget_out.rpt
    foreach key  [array names MDB *slack*] {
        regsub {,slack} $key {} pname_key
        regsub {,slack} $key {,clock} clock_key
        regsub {,slack} $key {,direc} direc_key
        regsub {,slack} $key {,check} check_key
        regsub {,slack} $key {,runty} runty_key
        regsub {,slack} $key {,point} point_key
        echo "[format "%-*s %-*s %-*s %-*s %-*s %-*s  $MDB($point_key)" 45 $pname_key 8 $MDB($key) 12 $MDB($clock_key) 5 $MDB($direc_key) 5 $MDB($check_key) 5 $MDB($runty_key)]" >> mrt_budget_out.rpt
    }
}

define_proc_attributes mrt \
    -info "my report timing" \
    -define_args {
	{-group              "group name"                              "<group_name>" string optional}
	{-from               "from"                                    "<from>" string optional}
	{-to                 "to"                                      "<to>" string optional}
	{-thr                "thr"                                     "<thr>" string optional}
	{-print_path_regx    "show_path_regx"                          "<show_path_regx>" string optional}
    {-print_path           "show_path"                             "" boolean optional}
    {-print_path_in     "show_path"                             "" boolean optional}
	{-max_p              "max_paths"                               "<value>" int optional}
	{-nworst             "number of worst path to endpoint"        "<value>" int optional}
	{-slack_lesser_than  "only paths with slack lesser than"       "<value>" float optional}	
	{-neg_only           "only negative paths"                     "" boolean optional}	
	{-endpoints          "endpoints only"                          "" boolean optional}
	{-startpoints        "startpoints only"                        "" boolean optional}
	{-clocks             "get startpoint & endpoints clocks"       "" boolean optional}
	{-min                "report for hold "                        "" boolean optional}
	{-clock_skew         "report clock skew "                      "" boolean optional}
	{-xtalk              "report clock and data xtalk sum "        "" boolean optional}
	{-gates              "report number of logic and route gates " "" boolean optional}
	{-draw_paths         "highlight paths on gui"                  "" boolean optional}
	{-pba                "pba mode (e/p) "                         "<value>" string optional}
	{-exclude            "exclude list"                            "<exclude_list>" string optional}
}
# 	{-scenarios          "scenarios"                               "<max/min0-99>" string optional}

proc PrintPoints {points} {
    set pins [get_attr $points object]
    foreach_in_collection pin $pins {
        echo [get_object_name $pin]
    }
}

proc GetCellXY {cell} {
    set bbox [get_attr $cell bbox]
    set x0 [lindex [lindex $bbox 0] 0]
    set y0 [lindex [lindex $bbox 0] 1]
    set x1 [lindex [lindex $bbox 1] 0]
    set y1 [lindex [lindex $bbox 1] 1]
    set x_mid [expr (${x0} + ${x1})/2]
    set y_mid [expr (${y0} + ${y1})/2]
#    echo $x_mid
#    echo $y_mid
    return "$x_mid $y_mid"
}

