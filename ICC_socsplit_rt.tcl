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
proc soc_split_rt { args } {
    
    set results(-nworst) 1000000
    parse_proc_arguments -args ${args} results
    set file_path $results(file_path)
    upvar $results(array_name) Path
    set pathNumber 0
    set Recording "off"
    set infile   [open $file_path r]
    while {[gets $infile line] >= 0}  {
        if { $pathNumber == $results(-nworst) } { break }  
#get the start point and reset some vars
        if {[regexp {(Startpoint: )([a-zA-Z0-9_/-\[\]]*)} $line all lb rb]} { 
            incr pathNumber ; 
            unset -nocomplain point_list;
            unset -nocomplain lib_list;
            unset -nocomplain cell_list;
            set Path($pathNumber,StartPoint) $rb; 
            puts "-------------------------";   
        }
# look for slack line & add it to array        
        if {[regexp {(  slack \()([A-Za-z]*)(\)[ ]*)([0-9.-]*)} $line a b met d slack]} { 
        set Path($pathNumber,met) $met
        set Path($pathNumber,slack) $slack 
        }
# get the end point        
        if {[regexp {(Endpoint: )([a-zA-Z0-9_/-\[\]]*)} $line all lb rb]} { set Path($pathNumber,EndPoint) $rb   }
# move on the timing path get cell/point/lib lists
        if {[regexp {Point} $line]} {set Recording "on" } 
        if { $Recording == "on" && [regexp {^(  [a-zA-Z0-9_-]*/.*)(\()(.*)(\))} $line all rb mlb mrb lb] } {
            puts "working .. path number ${pathNumber} "
            append point_list $rb; #geting stuff 
            append lib_list $mrb;

            regexp {(.*)(/.*)$} $rb all lb rb
            append cell_list $lb;

        }
# all lists to the array & get the invbuff from cells
        if {[regexp {data arrival time} $line]} {
            set Recording "off"
            set Path($pathNumber,points) $point_list
            set Path($pathNumber,libs) $lib_list

            set cell_list [lsort -u $cell_list]
            set Path($pathNumber,cells) $cell_list
            set temp [get_cells $Path($pathNumber,cells) -quiet -filter "number_of_pins==2 AND full_name!~ *io_buf/*"]
            set Path($pathNumber,invbuf) [collection_to_list $temp -name_only -no_braces]

        }

            }
        close $infile;
        return $pathNumber
} ;# end of proc 


define_proc_attributes soc_split_rt \
    -info "read a pt/icc timing report and return for each timing path the: start point \n end point \n violated or met \n slack  \n point list \n cells list \n lib list \n buf&inv list of top level on the timing path \n the inputs are the path for the timing report file && name of the array to be upvar \n the array columans are: \n Path(pathNumber,StartPoint) \n Path(pathNumber,EndPoint) \n Path(pathNumber,met) \n Path(pathNumber,slack) \n Path(pathNumber,points) \n Path(pathNumber,cells) \n Path(pathNumber,libs) \n Path(pathNumber,invbuf) \n the return value is the number of paths -help" -define_args {
        {file_path         "path to report file"        "file_path" string required}
        {array_name         "name of array to be upvar"  "array_name" string required}
        {-nworst "number of paths to read from report default is all" "" int optional}
}


