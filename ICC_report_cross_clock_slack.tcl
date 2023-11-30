############################################################################
# report_cross_clocks_slack find all paths with slack lesser then 0        #
# give a report on TNS WNS FEN for internal cross clocks path              #
#                                                                          #
# Lior Allerhand                                                           #
# 20.12.12                                                                 #
############################################################################


proc report_cross_clocks_slack {args} {

    # parse input args
    redirect ../report/cross_clocks_slack.rpt {puts "" }
    parse_proc_arguments -args ${args} results

#----------------------proc body----------------------------------
    set paths  [get_timing_paths -nworst 100 -slack_lesser_than 0 -max_paths 1000000 ]
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
            puts "start point object class: $sPointobjcc"
            puts "end point object class: $ePointobjcc"
            puts "start point clock: $spointClock"
            puts "end point clock: $epointClock"
        }

##############################################
# get external start port table              #
##############################################
        if {$sPointobjcc=="port" && $ePointobjcc=="pin"} {   
            set extrin($iei,sname)   $spoint 
            set extrin($iei,sclock)  $spointClock
            set extrin($iei,ename)   $epoint
            set extrin($iei,eclock)  $epointClock
            set extrin($iei,slack)   $slack
            incr iei ; # incr external uid
        }
##############################################
# get external end port table                #
##############################################
        if {$sPointobjcc=="pin" && $ePointobjcc=="port"} {   
            set extrout($ieo,sname)   $spoint 
            set extrout($ieo,sclock)  $spointClock
            set extrout($ieo,ename)   $epoint
            set extrout($ieo,eclock)  $epointClock
            set extrout($ieo,slack)   $slack
            incr ieo ; # incr external uid
        }
##############################################
# get external io port table                 #
##############################################
        if {$sPointobjcc=="port" && $ePointobjcc=="port"} {   
            set extrio($iio,sname)   $spoint 
            set extrio($iio,sclock)  $spointClock
            set extrio($iio,ename)   $epoint
            set extrio($iio,eclock)  $epointClock
            set extrio($iio,slack)   $slack
            incr iio ; # incr external uid
        }

#############################################
# get internal start/end pin table          #
#############################################        
        if {$sPointobjcc=="pin"&&$ePointobjcc=="pin"} {   
            set intr($iit,sname)   $spoint 
            set intr($iit,sclock)  [get_object_name $spointClock]
            set intr($iit,ename)   $epoint
            set intr($iit,eclock)  [get_object_name $epointClock]
            set intr($iit,slack)   $slack
            incr iit ; # incr external uid
        } 
    }; # end of foreach on all paths
    puts $iit
        set j 0
        set failpath ""
        for {set i 0} {$i<$iit} {incr i} {
            if {$intr($i,slack) <= 0.0} {
                if {$intr($i,sclock) ne $intr($i,eclock)} {
                    if {[info exists printarr($intr($i,sclock),$intr($i,eclock),FEP)]} {
                        set printarr($intr($i,sclock),$intr($i,eclock),sclock) $intr($i,sclock)
                        set printarr($intr($i,sclock),$intr($i,eclock),eclock) $intr($i,eclock)
                        incr printarr($intr($i,sclock),$intr($i,eclock),FEP)
                        set printarr($intr($i,sclock),$intr($i,eclock),TNS) [expr {$printarr($intr($i,sclock),$intr($i,eclock),TNS)+$intr($i,slack)}]
                        if { $printarr($intr($i,sclock),$intr($i,eclock),WNS) > $intr($i,slack) } {
                            set printarr($intr($i,sclock),$intr($i,eclock),WNS) $intr($i,slack)
                        }
                    } else {
                        set printarr($intr($i,sclock),$intr($i,eclock),sclock) $intr($i,sclock)
                        set printarr($intr($i,sclock),$intr($i,eclock),eclock) $intr($i,eclock)
                        set printarr($intr($i,sclock),$intr($i,eclock),FEP) 1
                        set printarr($intr($i,sclock),$intr($i,eclock),TNS) $intr($i,slack)
                        set printarr($intr($i,sclock),$intr($i,eclock),WNS) $intr($i,slack)
                        lappend failpath "$intr($i,sclock),$intr($i,eclock)"
                    }
                }              
             }
          }
          foreach p $failpath {
                 redirect -append ../report/cross_clocks_slack.rpt { 
                     echo [format "start point clock %-33s end point clock %-33s WNS %12.4f  TNS %15.4f FEP %-7d" $printarr($p,sclock) $printarr($p,eclock) $printarr($p,WNS) $printarr($p,TNS) $printarr($p,FEP)]
                 }  
          }
return 1;
}; # end of proc
#---------------------define proc attributes----------------------
define_proc_attributes report_cross_clocks_slack \
    -info "this stuff will print whan user write <porc_name> -help" \
    -define_args {
        
{-debug  "use for debug stuff"    "" boolean optional}
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

