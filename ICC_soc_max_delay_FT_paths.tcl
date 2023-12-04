#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: go over a file line by line and append to list        #
#====================================================================#
# Example: set <list name> [file_to_list <file path>]                #
#====================================================================#

proc soc_max_delay_FT_paths {} {
    redirect -file temp_report {report_path_group -nosplit -expanded }
    set infile   [open temp_report  r]
    while {[gets $infile line] >= 0}  {
        if {![regexp {[\\]} $line]} {
            lappend out_list $line
        }
    }
    close $infile;
    sh rm temp_report

    #-- running on all FT data paths
    foreach line $out_list {
        puts $line
        if {[regexp {([\w+\d+\[\]]*)([ ]*\*[ ]*)([\w+\d+\[\]]*)( INOUT$)} $line --> start mid end]} {
            #-- see if the FT is already cons to max delay
            redirect -variable path {report_timing -from $start -to $end} 
            set is_set 0
            foreach l $path {
                if {[regexp {max_delay} $l]} {set is_set 1}
            }
            #-- look for start point clock and period
            set tp [get_timing_paths -from $start] 
            set spointClock   [get_attr $tp startpoint_clock]           ;# path start point clock
            set spointClockP  [get_attr [get_clocks $spointClock] period]
            #-- look for start and end point delay for max_delay calc
            set sdel [get_attr $tp startpoint_input_delay_value]
            set edel [get_attr $tp endpoint_output_delay_value]
            #-- if max_del not set in the past set it so data will have 0.33 clock p
            if {$is_set eq 0 } {
                set delay [expr {$sdel - $edel + $spointClockP*0.33}]
                redirect -file ./FT_file_out -tee {
                    puts "set_max_delay $delay -from $start -to $end"
                }

            }

        }
    }
return ""
}
