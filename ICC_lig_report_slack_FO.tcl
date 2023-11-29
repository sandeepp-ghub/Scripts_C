############################################################################
# lig_report_slack_fanout find all paths with slack lesser then 0          #
# group paths be common start/end point and give a picture                 #
# on ports/hier/regs/rams how are the begining or end point of a big       #
# number of violeted paths                                                 #
#                                                                          #
# Lior Allerhand                                                           #
############################################################################


proc kill_all_timing_problems {args} {

    # parse input args
    redirect ../reports/kill_all_timing_problems.tcl {puts "" }
    parse_proc_arguments -args ${args} results

#----------------------proc body----------------------------------
    set paths  [get_timing_paths -nworst 1 -slack_lesser_than 0 -max_paths 100 ]
    set iei  0 ; # set internal table uid 
    set ieo  0 ; # set external table uid
    set iio  0 ; # set inout    table uid
    set iit  0 ; # set inout    table uid
    foreach_in_collection  path $paths {
        set slack         [get_attr $path slack]                        ;# path slack 
        set spoint        [get_object_name [get_attr $path startpoint]] ;# path start point
        set epoint        [get_object_name [get_attr $path endpoint  ]] ;# path end point
        set sPointobjcc    [get_attr $spoint object_class]               ;# path start point object class 
        set ePointobjcc   [get_attr $epoint object_class]               ;# path end point object class
        set spointClock   [get_attr $path startpoint_clock]           ;# path start point clock
        set epointClock   [get_attr $path endpoint_clock]             ;# path end point clock
#        if {[info exists slack]} { } else {set slack 0}
        if {[info exists results(-debug)]} {
            puts "slack: $slack"
            puts "start point: $spoint"
            puts "end point: $epoint"
            puts "start point object class: $sPointbjcc"
            puts "end point object class: $ePointobjcc"
            puts "start point clock: $spointClock"
            puts "end point clock: $epointClock"
        }
        if { $slack<=$results(maxNegSlack) } {
##############################################
# get external start port table              #
##############################################
            if {$sPointobjcc=="port" && $ePointobjcc=="pin"} {  
                redirect -append ../reports/kill_all_timing_problems.tcl { 
                    puts "set_false_path -setup -from \[get_port $spoint\] -to \[get_pin $epoint\]" 
                } 
            }
##############################################
# get external end port table                #
##############################################
            if {$sPointobjcc=="pin" && $ePointobjcc=="port"} {  
                redirect -append ../reports/kill_all_timing_problems.tcl { 
                    puts "set_false_path -setup -from \[get_pin $spoint\] -to \[get_port $epoint\]" 
                } 
            }
##############################################
# get external io port table                 #
##############################################
            if {$sPointobjcc=="port" && $ePointobjcc=="port"} {  
                redirect -append ../reports/kill_all_timing_problems.tcl { 
                    puts "set_false_path -setup -from \[get_port $spoint\] -to \[get_port $epoint\]" 
                } 
            }

#############################################
# get internal start/end pin table          #
#############################################        
            if {$sPointobjcc=="pin"&&$ePointobjcc=="pin"} {   
                redirect -append ../reports/kill_all_timing_problems.tcl { 
                    puts "set_false_path -setup -from \[get_pin $spoint\] -to \[get_pin $epoint\]" 
                } 
            } 
        }; #end of if slack
    }; # end of foreach on all paths
}; # end of proc
#---------------------define proc attributes----------------------
define_proc_attributes kill_all_timing_problems \
    -info "this stuff will print whan user write <porc_name> -help" \
    -define_args {
        
{-debug  "use for debug stuff"    "" boolean optional}
{maxNegSlack "int help AnInt" "" string required}
}


# {a         "first addend arg"           a string required}
#        {b         "second addend arg"          b string required}
#        {-verbose  "issue a message"           "" boolean optional}
#       {-cts_cell "the cts cell name"         "" list    optional}
#       {-lib_cell "the library cell name"     "" list    optional}
#       {-debug    "debug mode"                "" boolean optional}
#       {-Int int help AnInt int optional}
#       {-Float float help AFloat float optional}
#       {-String "string help" AString string optional}
#        {-Oos oos help AnOos one_of_string {required value_help {values {a b}}}}

