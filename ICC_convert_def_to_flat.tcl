#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: convert def to flat format                            #
#====================================================================#
# Example: soc_convert_def_to_flat <in file path> <out file path>    #
#====================================================================#

proc soc_convert_def_to_flat {input_file output_file} {
    set outfile  [open $output_file  w]
    set infile   [open $input_file r]
    while {[gets $infile line] >= 0}  {
        if {[ regexp {get_cells} $line ]} {
            set line_list [split $line "/"]
            set start [join [lrange $line_list 0 1] "/"]
            set end   [join [lrange $line_list 2 end] "_" ]
            set line  [join [list $start $end] "_"]
        }
    puts $outfile $line

    }
    close $infile;
    close $outfile;
}


