#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 11/03/14                                                     #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: report on cross clock timing path                     #
#====================================================================#
# soc_cross_clock_timing_report                                      #
#====================================================================#



proc soc_cross_clock_timing_report {args} {
    parse_proc_arguments -args ${args} results    
    set clocks_col [get_clocks *]
    #-- set group as i like them.
    remove_path_group [get_object_name [get_path_groups ]]
    foreach_in_collection clk $clocks_col {
        group_path -name [get_object_name $clk] -from $clk
    }
    group_path -name IN    -from [all_inputs]
    group_path -name OUT   -to   [all_outputs]
    group_path -name INOUT -from [all_inputs] -to [all_outputs]

    

#-- INTERNAL PATHS 
    redirect -file cross_clocks.rpt         {puts "#=========================#" }
    redirect -file cross_clocks.rpt -append {puts "#-- INTERNAL PATHS ONLY --#" }
    redirect -file cross_clocks.rpt -append {puts "#=========================#\n" }
    foreach_in_collection clk1 $clocks_col {
        foreach_in_collection clk2 $clocks_col {
            #-- remove dup clks
            if {[compare_collections $clk1 $clk2] eq 0} {puts "Lioral-Info continue clk1: [get_object_name $clk1] clk2: [get_object_name $clk2]"; continue;}
            set path  [get_timing_paths -from $clk1 -to $clk2 -max_path 1 -group [get_object_name $clk1]] 
            if {[sizeof_collection $path] > 0} {
                set spoint   [get_object_name [get_attr $path startpoint]] ;# path start point
                set epoint   [get_object_name [get_attr $path endpoint  ]] ;# path end point
                set slack    [get_attr $path slack]
                #-- path is not constr..
                if {$slack eq "INFINITY"} { continue;}
                redirect -file cross_clocks.rpt -append {
                    puts "Lioral-Info: report_timing -from [get_object_name $clk1] -to  [get_object_name $clk2] ;# slack : $slack"
                }
            
            }
        }
    }
#-- work on internal only paths.
    if {[info exists results(-internal_paths_only)]} {return "1"}



#-- IN PATHS 
    redirect -file cross_clocks.rpt -append {puts "\n#=========================#" }
    redirect -file cross_clocks.rpt -append {puts "#-- IN PATHS ONLY       --#" }
    redirect -file cross_clocks.rpt -append {puts "#=========================#\n" }
    foreach_in_collection clk1 $clocks_col {
        foreach_in_collection clk2 $clocks_col {
            #-- remove dup clks
            if {[compare_collections $clk1 $clk2] eq 0} {puts "Lioral-Info continue clk1: [get_object_name $clk1] clk2: [get_object_name $clk2]"; continue;}
            set path  [get_timing_paths -from $clk1 -to $clk2 -max_path 1 -group IN] 
            if {[sizeof_collection $path] > 0} {
                set spoint   [get_object_name [get_attr $path startpoint]] ;# path start point
                set epoint   [get_object_name [get_attr $path endpoint  ]] ;# path end point
                set slack    [get_attr $path slack]
                #-- path is not constr..
                if {$slack eq "INFINITY"} { continue;}
                redirect -file cross_clocks.rpt -append {
                    puts "Lioral-Info: report_timing -from [get_object_name $clk1] -to  [get_object_name $clk2] ;# slack : $slack"
                }
            
            }
        }
    }

#-- OUT PATHS
    redirect -file cross_clocks.rpt -append {puts "\n#=========================#" }
    redirect -file cross_clocks.rpt -append {puts "#-- OUT PATHS ONLY      --#" }
    redirect -file cross_clocks.rpt -append {puts "#=========================#\n" }
    foreach_in_collection clk1 $clocks_col {
        foreach_in_collection clk2 $clocks_col {
            #-- remove dup clks
            if {[compare_collections $clk1 $clk2] eq 0} {puts "Lioral-Info continue clk1: [get_object_name $clk1] clk2: [get_object_name $clk2]"; continue;}
            set path  [get_timing_paths -from $clk1 -to $clk2 -max_path 1 -group OUT] 
            if {[sizeof_collection $path] > 0} {
                set spoint   [get_object_name [get_attr $path startpoint]] ;# path start point
                set epoint   [get_object_name [get_attr $path endpoint  ]] ;# path end point
                set slack    [get_attr $path slack]
                #-- path is not constr..
                if {$slack eq "INFINITY"} { continue;}
                redirect -file cross_clocks.rpt -append {
                    puts "Lioral-Info: report_timing -from [get_object_name $clk1] -to  [get_object_name $clk2] ;# slack : $slack"
                }
            
            }
        }
    }


#-- INOUT PATHS 
    redirect -file cross_clocks.rpt -append {puts "\n#=========================#" }
    redirect -file cross_clocks.rpt -append {puts "#-- INOUT PATHS ONLY    --#" }
    redirect -file cross_clocks.rpt -append {puts "#=========================#\n" }
    foreach_in_collection clk1 $clocks_col {
        foreach_in_collection clk2 $clocks_col {
            #-- remove dup clks
            if {[compare_collections $clk1 $clk2] eq 0} {puts "Lioral-Info continue clk1: [get_object_name $clk1] clk2: [get_object_name $clk2]"; continue;}
            set path  [get_timing_paths -from $clk1 -to $clk2 -max_path 1 -group INOUT] 
            if {[sizeof_collection $path] > 0} {
                set spoint   [get_object_name [get_attr $path startpoint]] ;# path start point
                set epoint   [get_object_name [get_attr $path endpoint  ]] ;# path end point
                set slack    [get_attr $path slack]
                #-- path is not constr..
                if {$slack eq "INFINITY"} { continue;}
                redirect -file cross_clocks.rpt -append {
                    puts "Lioral-Info: report_timing -from [get_object_name $clk1] -to  [get_object_name $clk2] ;# slack : $slack"
                }
            
            }
        }
    }
return "1";
}; #end of proc


define_proc_attributes soc_cross_clock_timing_report \
    -info "report on the exists of cross clock timing paths" \
    -define_args {
    {-internal_paths_only  ""  "" boolean optional}

  }

