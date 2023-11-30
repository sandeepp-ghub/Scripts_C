#################################################
# report_design_slack_information
# give a 

proc report_design_slack_information {args} {
    set nworst 100
    set group_ns "group_wns"
    set sort_direction down;
    set group_list "*"
    set min max
    parse_proc_arguments -args ${args} results
    if {[info exists results(-nworst)]} {set nworst $results(-nworst)}
    if {[info exists results(-delay_type)]} {set min $results(-delay_type)}
    if {[info exists results(-sort_by)]} {
        if {$results(-sort_by) eq "wns"} {}
        if {$results(-sort_by) eq "tns"} {set group_ns "group_tns" }
        if {$results(-sort_by) eq "fep"} {set group_ns "group_total_vpath"; set sort_direction up;  }
        if {$results(-sort_by) eq "name"} {set sort_by_name 1  }       
    }
    if {[info exists results(-group_list)]} {set group_list $results(-group_list)}
           set uid 0
           set design_tns 0
           set design_wns 100000
           set design_total_vpath 0
           set group_name_max_length 0
#########################
# get all info to array #
#########################
    #-- set hold pram if selected
    if {[info exists results(-hold)]} {
        set hold "-delay_type min"
    } else {
        set hold ""
    }
    foreach_in_collection group [get_path_groups $group_list] {
         set group_tns 0
         set group_wns 100000
         set group_total_vpath 0
         if {[string length [get_object_name $group]]> $group_name_max_length} {set group_name_max_length [string length [get_object_name $group]]}
         foreach_in_collection path [get_timing_paths -nworst $nworst -group [get_object_name $group] -delay_type $min ] {
         if {[info exists results(-internal_only)]} {   
            set spoint        [get_object_name [get_attr $path startpoint]] ;# path start point
            set epoint        [get_object_name [get_attr $path endpoint  ]] ;# path end point
            set sPointobjcc    [get_attr $spoint object_class]               ;# path start point object class
            set ePointobjcc   [get_attr $epoint object_class]               ;# path end point object class
            if {$sPointobjcc=="pin"&&$ePointobjcc=="pin"} { } else {continue }
          }
               set slack [get_attribute $path slack]
               if {$slack < $group_wns} {
                  set group_wns $slack
                  if {$slack < $design_wns} {
                      set design_wns $slack
                  }
               }
               if {$slack < 0.0} {
                 set group_tns [expr $group_tns + $slack]
                 incr group_total_vpath
               } 
             }
             set design_tns [expr $design_tns + $group_tns]
             set design_total_vpath [expr $design_total_vpath + $group_total_vpath]
             set group_name [get_attribute $group full_name]
             set uid                        [incr uid]
             set arr($uid,group_name)        $group_name
             set arr($uid,group_wns)         $group_wns
             set arr($uid,group_tns)         $group_tns
             set arr($uid,group_total_vpath) $group_total_vpath

                          
      }; # end of foreach

###########################
# sort the array by wns   #
###########################
if {![info exists sort_by_name]} {
    for {set i 1} {$i <$uid} {incr i} {
        set current $arr($i,$group_ns)
        set max_val $current
        set max_uid $i
        for {set j [expr {$i+1}]} {$j <$uid} {incr j} {
            set next $arr($j,$group_ns)
            if {$sort_direction eq "down"} {
                if {$max_val>$next} {set max_val $next; set max_uid $j}
            } else {
                if {$max_val<$next} {set max_val $next; set max_uid $j}
            }
        }
        set group_name        $arr($i,group_name)        
        set group_wns         $arr($i,group_wns)        
        set group_tns         $arr($i,group_tns)         
        set group_total_vpath $arr($i,group_total_vpath) 

        set arr($i,group_name)        $arr($max_uid,group_name)
        set arr($i,group_wns)         $arr($max_uid,group_wns)
        set arr($i,group_tns)         $arr($max_uid,group_tns) 
        set arr($i,group_total_vpath) $arr($max_uid,group_total_vpath)

        set arr($max_uid,group_name)        $group_name
        set arr($max_uid,group_wns)         $group_wns
        set arr($max_uid,group_tns)         $group_tns
        set arr($max_uid,group_total_vpath) $group_total_vpath

    }
} else {
    for {set i 1} {$i<=$uid} {incr i} {
        lappend names $arr($i,group_name)
        set fliparr($arr($i,group_name)) $i  
    }
    set names_sort [lsort -dictionary $names]
    pl $names_sort
# return 0
    set id 1    
    foreach n $names_sort {

        set arr2($id,group_name)        $arr($fliparr($n),group_name)
        set arr2($id,group_wns)         $arr($fliparr($n),group_wns)
        set arr2($id,group_tns)         $arr($fliparr($n),group_tns) 
        set arr2($id,group_total_vpath) $arr($fliparr($n),group_total_vpath)
        incr id
    
    }
    array set arr [array get arr2]
}

########################
# print info to screen #
########################
set group_name_max_length [expr {$group_name_max_length+2}] ; #set the table first column length
if {$group_name_max_length<12} {set group_name_max_length 12 }
for {set i 0} {$i<$group_name_max_length} {incr i} {append line "-"}
append line "------------------------------------------"
echo $line
echo [format "%-${group_name_max_length}s| %-13s| %-15s| %-7s|" "group name " " WNS" " TNS" " TFP" ]
echo $line

for {set i 1} {$i <=$uid} {incr i} {
    set group_name        $arr($i,group_name)        
    set group_wns         $arr($i,group_wns)        
    set group_tns         $arr($i,group_tns)         
    set group_total_vpath $arr($i,group_total_vpath) 

                          

    if {[info exists results(-neg_only)]} { 
                if {$group_wns < 0} {
                    echo [format "%-${group_name_max_length}s|  %12.4f| %15.4f| %-7d|" $group_name $group_wns $group_tns $group_total_vpath ]
                }
    } else {
        echo [format "%-${group_name_max_length}s|  %12.4f| %15.4f| %-7d|" $group_name $group_wns $group_tns $group_total_vpath ]
    }

}


           echo $line
           echo ""
           echo "total design info"
           echo ""
           echo $line
           echo [format "%-${group_name_max_length}s| %-13s| %-15s| %-7s|" "group name " " WNS" " TNS" " TFP" ]
           echo $line
           echo [format "%-${group_name_max_length}s|  %12.4f| %15.4f| %-7d|" "FULL DESIGN" $design_wns $design_tns $design_total_vpath ]
           echo $line
# puts $group_name_max_length
}; # end of proc

define_proc_attributes report_design_slack_information \
    -info "printing a table of WNS TNS TFP for every path group in the design.   -help" \
    -define_args { 
{-neg_only  "will print only path groups with WNS < 0"    "" boolean optional}
{-internal_only  "make the report only for internal paths" "" boolean optional}
{-sort_by "sort results by wns or tns (default is wns)" "" one_of_string {optional value_help {values {wns tns fep name}}}}
{-delay_type "min or max delay type report (default is max)" "" one_of_string {optional value_help {values {min max}}}}
{-nworst "number of paths for each path group (default is 10000)" "" int optional}
{-hold  "print hold slacks" "" boolean optional}
{-group_list "list to groups (default is *)" "" string optional}
}

