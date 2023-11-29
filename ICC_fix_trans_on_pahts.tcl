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
#    redirect -variable reports {report_timing -capacitance -transition_time -group [remove_from_collection [get_path_group] [get_path_groups {IN OUT INOUT}]]  -max_path 100 -slack_lesser_than 0 -nosplit}
    redirect -variable reports {report_timing -capacitance -transition_time  -max_path 1 -nosplit -slack_lesser_than 0 -from kw28_pex_cluster/kw28_pex_x4_wrap/FULL_BLOCK_pex2_top/pex2_rams_top/DFX_WRAPPERS_pex2_tlrx_hdr_buff/PHYSICAL_MODE_1_table_inst_1/table_core/table_bank_0/dfx_ram_pex2_rxhdr_inst1_id1_ram_1w1r_rf2p32x128_tst_wr_rd_clk_parity_0/memory/RCLK -to dfx_macro_glue_alpha_top/dfx_macro_glue_alpha/dfx_client_alpha_macro_pex_test_clk/dfx_client/dfx_client_data_glue/client_sampled_ram_debug_bus_reg_8_/D}

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
        if { $Recording == "on" && [regexp {^(  [a-zA-Z0-9_-]*/.*)(\()(.*)(\))( *)([-0-9.]*)( *)([-0-9.]*)( *)([-0-9.]*)} $line all rb mlb mrb lb a cap c trans e inc] } {
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
    parray  cells
    set i 0
     redirect -file stuff {puts ""}
    foreach c $cells_list {
# if {$cells($c,vt) eq "szd" || $cells($c,vt) eq "snd"}  { }
           if {[regexp {(generic_cell_mux2)$} $cells($c,name)] && $cells($c,inc) > 0.1} {
               puts "$cells($c,name) $cells($c,inc)"
#     redirect -file -append stuff {puts "size_cell $cells($c,name) lnd_smx2x8"}
# if { $cells($c,inc) > 0.1} { }
# puts "$cells($c,name) $cells($c,lib) $cells($c,inc)"
                incr i
            } ;# elseif {$cells($c,inc) > 0.1} {
# redirect -file -append stuff {puts "soc_size_cell -vt_swap -down 1 \[get_cells $cells($c,name)\]"}
#            }
    }
puts "number of x2 cells $i"

    return $pathNumber
} ;# end of proc 


define_proc_attributes fix_trans_on_paths \
    -info "read a pt/icc timing report and return for each timing path the: start point \n end point \n violated or met \n slack  \n point list \n cells list \n lib list \n buf&inv list of top level on the timing path \n the inputs are the path for the timing report file && name of the array to be upvar \n the array columans are: \n Path(pathNumber,StartPoint) \n Path(pathNumber,EndPoint) \n Path(pathNumber,met) \n Path(pathNumber,slack) \n Path(pathNumber,points) \n Path(pathNumber,cells) \n Path(pathNumber,libs) \n Path(pathNumber,invbuf) \n the return value is the number of paths -help" -define_args {
        {-nworst "number of paths to read from report default is all" "" int optional}
}


