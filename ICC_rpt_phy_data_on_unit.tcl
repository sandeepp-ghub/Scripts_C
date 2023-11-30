#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: report cell count and place area of first order hier  #
#              get macro utilization as input                        #
#====================================================================#
# Example: report_phy_data_on_unit 0.6                               #
#====================================================================#


proc report_phy_data_on_unit {input} {

set ram_facrot 1.1
set util $input
set units [get_cells * -filter "is_hierarchical == true"]
set top [get_cells * -filter "is_hierarchical == false"]
puts "ram factor is $ram_facrot"
puts "cell util is $util"
echo [format "%-*s " 30 "hierarchy name"] [format "%-*s " 14 "cell count"] [format "%-*s " 14 "total area"]

foreach_in_collection u $units {
    set un [get_object_name $u]
    set cells [get_cells * -hier  -filter "full_name=~${un}/* AND is_hierarchical == false"]
    set cell_count_count 0
    set area       0
    set ram_count  0
    set ram_area   0
    set FF_count   0
    set FF_area    0
    foreach_in_collection cell $cells {
        set cell_area [get_attribute $cell area]
        if {$cell_area != ""} {
	        set cell_count_count [expr $cell_count_count + 1]
	        set area [expr $area + $cell_area]
	    }
        if {[get_cells $cell -filter "ref_name =~ rf1* || ref_name =~ rf2* || ref_name =~ sr1* || ref_name =~ sr2* || ref_name=~rsd12288*"] != "" } {
	        set ram_count [expr $ram_count + 1]
	        set ram_area [expr $ram_area + $cell_area]
	    }
        if {[get_cells $cell -filter "ref_name =~ rf1* || ref_name =~ rf2* || ref_name =~ sr1* || ref_name =~ sr2* || ref_name=~rsd12288*"] == "" } {
            if {[get_cells $cell -filter "is_sequential==true"] != "" } {
	            set FF_count [expr $FF_count + 1]
	            set FF_area [expr $FF_area + $cell_area]
            }
    	}
    }
    set cells_only_area [expr {$area-$ram_area}]
    set cells_only_area_factor [expr {${cells_only_area}/$util}]
    set ram_area_factor        [expr {${ram_area}*$ram_facrot}]
    set tot_area [expr {$cells_only_area_factor+$ram_area_factor}]
    echo [format "%-*s " 30 $un] [format "%-*s " 14 $cell_count_count] [format "%12.2f " $tot_area]
#  puts "for hier: ${un}"
#    puts "total unit cell count: $cell_count_count"
#    puts "total unit area:       $area"
#    puts "total ram count:       $ram_count"
#    puts "total ram area:        $ram_area"
#    puts "total flop count:      $FF_count"
#    puts "total flop area:       $FF_area"
#    puts ""
}
#--> looking at cell at the top level 
    set cells [get_cells *   -filter "is_hierarchical == false"]
    set cell_count_count 0
    set area       0
    set ram_count  0
    set ram_area   0
    set FF_count   0
    set FF_area    0
    foreach_in_collection cell $cells {
        set cell_area [get_attribute $cell area]
        if {$cell_area != ""} {
	        set cell_count_count [expr $cell_count_count + 1]
	        set area [expr $area + $cell_area]
	    }
        if {[get_cells $cell -filter "ref_name =~ rf1* || ref_name =~ rf2* || ref_name =~ sr1* || ref_name =~ sr2* || ref_name=~rsd12288*"] != "" } {
	        set ram_count [expr $ram_count + 1]
	        set ram_area [expr $ram_area + $cell_area]
	    }
        if {[get_cells $cell -filter "ref_name =~ rf1* || ref_name =~ rf2* || ref_name =~ sr1* || ref_name =~ sr2* || ref_name=~rsd12288*"] == "" } {
            if {[get_cells $cell -filter "is_sequential==true"] != "" } {
	            set FF_count [expr $FF_count + 1]
	            set FF_area [expr $FF_area + $cell_area]
            }
    	}
    }
    set cells_only_area [expr {$area-$ram_area}]
    set cells_only_area_factor [expr {${cells_only_area}/$util}]
    set ram_area_factor        [expr {${ram_area}*$ram_facrot}]
    set tot_area [expr {$cells_only_area_factor+$ram_area_factor}]
    echo [format "%-*s " 30 "TOP"] [format "%-*s " 14 $cell_count_count] [format "%12.2f " $tot_area]

#    puts "for hier: top"
#    puts "total unit cell count: $cell_count_count"
#    puts "total unit area:       $area"
#    puts "total ram count:       $ram_count"
#    puts "total ram area:        $ram_area"
#    puts "total flop count:      $FF_count"
#    puts "total flop area:       $FF_area"
#    puts ""



return ""
}
