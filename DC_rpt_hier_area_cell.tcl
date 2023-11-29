#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: Manor P                                              #
#====================================================================#
# Description: report a post synt area report                        #
#====================================================================#
# Example: source report_hier_area_cell.tcl                          #
#====================================================================#




set report ../report/post_synt_area_report.rpt

echo "" > $report 
echo [format "%-*s " 25 "Instance"] [format "%-*s " 12 "Cellcount"] [format "%-*s " 12 "Tot Area"]  [format "%-*s " 5 "#Rams"] [format "%-*s " 12 "Rams Area"] >> $report 
set all_1st_hier_cells [get_cells -filter "is_hierarchical == true"]
set num_of_1st_hier_cells [sizeof_collection $all_1st_hier_cells]

set tot_area 0
set tot_cell_count 0
set tot_rams 0
set tot_rams_area 0

set rams_factor 1.1
set util_factor 0.6

foreach_in_collection hier $all_1st_hier_cells { 
    set name [get_attribute $hier name]
    set cell_count_inc_hier [get_cells  * -hier -filter "full_name =~ ${name}/* "]
    set cell_count [filter_collection $cell_count_inc_hier "is_hierarchical == false" ]
    set area 0
    set ram_area 0
    set cell_count_count 0
    set ram_count 0 
    foreach_in_collection cell $cell_count {
	#puts "[get_attribute $cell full_name ] cell area is [get_attribute $cell area]"
	set cell_area [get_attribute $cell area]
	if {$cell_area != ""} {
	    set cell_count_count [expr $cell_count_count + 1]
	    set area [expr $area + $cell_area]
	}
	if {[get_cells $cell -filter "ref_name =~ rf1* || ref_name =~ rf2* || ref_name =~ sr1* || ref_name =~ sr2*"] != "" } {
	    set ram_count [expr $ram_count + 1]
	    set ram_area [expr $ram_area + $cell_area]
	}
    }
    
    set tot_area [expr $tot_area + $area]
    set tot_cell_count [expr $tot_cell_count + $cell_count_count]
    set tot_rams [expr $tot_rams + $ram_count]
    set tot_rams_area [expr $tot_rams_area + $ram_area]
    echo [format "%-*s " 25 $name] [format "%-*s " 12 $cell_count_count] [format "%-*s " 12 $area]  [format "%-*s " 5 $ram_count] [format "%-*s " 12 $ram_area] >> $report 

}

echo "" >> $report 
echo [format "%-*s " 25 $TopModule] [format "%-*s " 12 $tot_cell_count] [format "%-*s " 12 $tot_area]  [format "%-*s " 5 $tot_rams] [format "%-*s " 12 $tot_rams_area] >> $report 
echo "area calculation: " >> $report  
echo "(rams_area) * rams_factor + (tot_area - rams_area) / util_factor = " >> $report  
echo "$tot_rams_area * $rams_factor + ($tot_area - $tot_rams_area ) / $util_factor = " [expr $tot_rams_area * $rams_factor + ($tot_area - $tot_rams_area ) / $util_factor ] >> $report 

 
