#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: EyalD                                                #
#====================================================================#
# Description: more readable format of report timing                 #
#====================================================================#
# Example: mrt -from -to  -startpoints                               #
#====================================================================#


proc mrt {args} {

    set results(-group) {}
    set results(-from) {}
    set results(-to) {}
    set results(-thr) {}
    set results(-max_p) {1}
    set results(-nworst) {1}
    set results(-slack_lesser_than) {}
    set results(-neg_only) {0}
    set results(-endpoints) {0}
    set results(-startpoints) {0}
    set results(-clocks) {false}
    set results(-min) {false}
    set results(-pba) {}
    set results(-exclude) {}
    #-- parse command line arguments
    parse_proc_arguments -args $args results
    foreach v [array names results] {
        regsub {^\-} $v {} vn
        eval "set i_${vn} \$results($v)"
    }

    suppress_message UITE-479       
    suppress_message UITE-416

    set cmd_ "get_timing_path"
    if {$i_group != ""} {append cmd_ " -group $i_group"}
    if {$i_from != ""} {append cmd_ " -from $i_from"}
    if {$i_to != ""} {append cmd_ " -to $i_to"}
    if {$i_thr != ""} {append cmd_ " -thr $i_thr"}
    if {$i_neg_only} {append cmd_ " -slack_l 0"} elseif {$i_slack_lesser_than != ""} {append cmd_ " -slack_l $i_slack_lesser_than"}
    if {$i_max_p > 1} {append cmd_ " -max_path $i_max_p"}
    if {$i_nworst > 1} {append cmd_ " -nworst $i_nworst"}
    if {$i_min != "false"} {append cmd_ " -delay_type min"}    
    if {$i_pba != ""} {append cmd_ " -pba $i_pba"}    
    if {$i_exclude != ""} {append cmd_ " -exclude \"$i_exclude\""}    

    #puts "cmd_ => $cmd_"
    set i 1
    foreach_in_collection path [eval $cmd_] {
	set slack [get_attribute $path slack]
	if {$i_endpoints} {
	    set endpoint [get_object_name [get_attribute $path endpoint]]	    
	    puts "\[$i\] $endpoint $slack"
	} elseif {$i_startpoints} {
	    set startpoint [get_object_name [get_attribute $path startpoint]]
	    puts "\[$i\] $startpoint $slack"
	} elseif {$i_clocks != "false"} {
	    set start_clock [get_object_name [get_attribute $path startpoint_clock]]
	    set end_clock [get_object_name [get_attribute $path endpoint_clock]]
	    puts "\[$i\] $start_clock --> $end_clock $slack"	    
	} else {
        #-- print bothe start and endpoints
	    set startpoint [get_object_name [get_attribute $path startpoint]]	
	    set endpoint [get_object_name [get_attribute $path endpoint]]	    
	    puts "\[$i\] $startpoint --> $endpoint $slack"
	}
	incr i
    }

    unsuppress_message UITE-479 
    unsuppress_message UITE-416
}

define_proc_attributes mrt \
    -info "my report timing" \
    -define_args {
	{-group              "group name"                             "<group_name>" string optional}
	{-from               "from"                                   "<from>" string optional}
	{-to                 "to"                                     "<to>" string optional}
	{-thr                "thr"                                    "<thr>" string optional}
	{-max_p              "max_paths"                              "<value>" int optional}
	{-nworst             "number of worst path to endpoint"       "<value>" int optional}
	{-slack_lesser_than  "only paths with slack lesser than"      "<value>" float optional}	
	{-neg_only           "only negative paths"                    "" boolean optional}	
	{-endpoints          "endpoints only"                         "" boolean optional}
	{-startpoints        "startpoints only"                       "" boolean optional}
	{-clocks             "get startpoint & endpoints clocks"      "" boolean optional}
	{-min                "report for hold "                       "" boolean optional}
	{-pba                "pba mode (e/p) "                          "<value>" string optional}
	{-exclude            "exclude list"                           "<exclude_list>" string optional}
}
