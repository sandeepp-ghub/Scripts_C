#################################################################################
# soc_split_rt - read a pt/icc timing report and return                         #   
# for each path the start point ,end point ,violated or met ,slack              #
# point list ,cells list, lib list, buf&inv of top level on the timing path     #
# two input:                                                                    #
# 1. input file path                                                            #
# 2. name of var to upval the output array to                                   #
# Lior Allerhand                                                                #
# 9/10/12                                                                       #
#################################################################################

# pathNumber in the end hold the number of paths in the report
proc fix_trans_on_paths { args } {
#-- get reports in var format and conv to list
    redirect -variable reports {report_timing -capacitance -transition_time -group sata10_TX_CLK_from_serdes5_txdclk -max_path 2 -nosplit}
    parse_proc_arguments -args ${args} results
    set pathNumber 0
    set Recording "off"
    set lines [split $reports \n]
#-- break the report from list format to array
    foreach line $lines   {
    #-- get the start point and reset some vars
        if {[regexp {(Startpoint: )([a-zA-Z0-9_/-\[\]]*)} $line all lb rb]} { 
            incr pathNumber ; 
            set Path($pathNumber,StartPoint) $rb;    
        }
    #-- look for slack line & add it to array        
# if {[regexp {(  slack \()([A-Za-z]*)(\)[ ]*)([0-9.-]*)} $line a b met d slack]} { 
#        set Path($pathNumber,met) $met
#        set Path($pathNumber,slack) $slack 
#        }
    #-- get the end point        
        if {[regexp {(Endpoint: )([a-zA-Z0-9_/-\[\]]*)} $line all lb rb]} { set Path($pathNumber,EndPoint) $rb   }
    #-- move on the timing path get cell/point/lib lists
        if {[regexp {Point} $line]} {set Recording "on" } 
        if { $Recording == "on" && [regexp {^(  [a-zA-Z0-9_-]*/.*)(\()(.*)(\))( *)([-0-9.]*)([ ]*)(&)} $line all rb mlb mrb lb a inc ] } {
            if {[regexp [get_object_name [current_design]] $mrb]} {continue } ;# jump over hier cells
            regexp {(.*)(/.*)$} $rb all lb rb
            if {[get_attr [get_cells $lb] is_sequential] eq "true"} {continue}
            if {[info exists cells($lb,name)]} {
                if {$inc > $cells($lb,inc)} {
                    set cells($lb,inc) $inc
                    set cells($lb,trans) $trans
                }
            } else {
                set cells($lb,name) $lb
                set cells($lb,trans) $trans
                set cells($lb,inc)   $inc
                set cells($lb,lib)   $mrb
                 regexp {(\w\w\w)(.*)(x[0-9ox]*)(.*)} $mrb --> vt t1 size t2
                set cells($lb,vt)   $vt
                set cells($lb,size)   $size
                lappend cells_list $lb
            }
        }
# all lists to the array & get the invbuff from cells
        if {[regexp {data arrival time} $line]} {
            set Recording "off"
#            set temp [get_cells $Path($pathNumber,cells) -quiet -filter "number_of_pins==2 AND full_name!~ *io_buf/*"]
        }
    }
#####################################################################  
#-- in this part you have all the data now its time to print stuff--#
#####################################################################
    foreach c $cells_list {
        if {$cells($c,vt) eq "szd" || $cells($c,vt) eq "snd"}  {
            if {$cells($c,size) eq "x2" && $cells($c,inc) > 0.07} {
                puts "$cells($c,name) $cells($c,lib) $cells($c,inc)"
            }
        }
    }


    return $pathNumber
} ;# end of proc 


define_proc_attributes fix_trans_on_paths \
    -info "read a pt/icc timing report and return for each timing path the: start point \n end point \n violated or met \n slack  \n point list \n cells list \n lib list \n buf&inv list of top level on the timing path \n the inputs are the path for the timing report file && name of the array to be upvar \n the array columans are: \n Path(pathNumber,StartPoint) \n Path(pathNumber,EndPoint) \n Path(pathNumber,met) \n Path(pathNumber,slack) \n Path(pathNumber,points) \n Path(pathNumber,cells) \n Path(pathNumber,libs) \n Path(pathNumber,invbuf) \n the return value is the number of paths -help" -define_args {
        {-nworst "number of paths to read from report default is all" "" int optional}
}


