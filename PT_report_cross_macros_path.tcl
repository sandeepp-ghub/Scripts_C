proc report_cross_macros_path {args} {
    #-- set get_timing_path flages
    set results(-nworst) 1
    set results(-max_paths) 1
    set results(-swap_method) both
    set results(-work_base) path_base
    set results(-slack_lesser_than) 0.0
    set results(-pba_mode) none ;#, path, exhaustive
    set i 1
#set results()
    parse_proc_arguments -args ${args} results
    set cmd "get_timing_path -include_hierarchical_pins"
    if {[info exists results(-nworst)]}    {append cmd " -nworst $results(-nworst)"}
    if {[info exists results(-max_paths)]} {append cmd " -max_paths $results(-max_paths)"}
    if {[info exists results(-group)]}     {append cmd " -group $results(-group)"}
    if {[info exists results(-from)]}      {append cmd " -from $results(-from)"}
    if {[info exists results(-to)]}        {append cmd " -to $results(-to)"}
    if {[info exists results(-thr)]}       {append cmd " -thr $results(-thr)"}
    if {[info exists results(-thr1)]}       {append cmd " -thr $results(-thr1)"}
    if {[info exists results(-thr2)]}       {append cmd " -thr $results(-thr2)"}
    if {[info exists results(-exclude)]}   {append cmd " -exclude $results(-exclude)"}
    if {[info exists results(-slack_lesser_than)]}  {append cmd " -slack_lesser_than $results(-slack_lesser_than)"}
    if {[info exists results(-slack_greater_than)]} {append cmd " -slack_greater_than $results(-slack_greater_than)"}
    if {[info exists results(-slack_greater_than)]} {append cmd " -pba_mode $results(-pba_mode)"}

    set paths [eval $cmd]
    if {[sizeof_collection $paths] < 1} {puts "Lioral-Info : there are no paths ..." ;return 0}

    foreach_in_collection path $paths { 
        set points [get_attr $path points]
        set start [get_object_name [get_attr $path startpoint]]
        set end   [get_object_name [get_attr $path endpoint]]
        #########################################
        # get all cells and ports of the path   #
        #########################################
        set cur "Lioral-Info : there is no pin before this pin"
        puts "\nInfo: for path number: $i"
        incr i
        puts $start
        foreach_in_collection point $points {
            set pin    [get_attr $point object    ]
#            set oclass [get_attr $pin object_class]
#            set pinTransArray([get_object_name $pin]) [get_attr $point transition]
#            set pinSlackArray([get_object_name $pin]) [get_attr $point slack]
             set pre $cur
             set cur [get_object_name $pin]
            #-- outputs start with io buf and go to nets
             if {![regexp {_io_buf} $pre ] && [regexp {_io_buf} $cur]} {puts "$pre"}
            #-- inputs start with nets and go to io buf
             if {[regexp {_io_buf} $pre ] && ![regexp {_io_buf} $cur]} {puts "$cur"}
             
        }

    }






}

define_proc_attributes report_cross_macros_path \
    -info "" \
    -define_args {
    {-verbos  "use for debug"    "" boolean optional}
    {-group "group list to work on" "" string optional}
    {-from "paths start point" "" string optional}
    {-to "paths end point" "" string optional}
    {-thr "paths going through this point" "" string optional}
    {-thr1 "paths going through this point" "" string optional}
    {-thr2 "paths going through this point" "" string optional}
    {-max_paths "max path number" "" int optional}
    {-nworst "" "" string optional}
    {-pba_mode "" ""  one_of_string {optional value_help {values {none path exhaustive}}}}
    {-slack_lesser_than "work only on paths with slack lesser than val" "" string optional}
    {-slack_greater_than "work only on paths with slack greater than val" "" string optional}
    {-exclude "execlude a point and the paths going through it." "" boolean optional}
  }
