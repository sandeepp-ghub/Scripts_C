#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description:get selection& print to screen commands to place cells #
#====================================================================#
# Example:soc_export_cell_place_of_get_selected                      #
#====================================================================#


proc soc_export_cell_place_of_get_selected {} {
    foreach_in_collection cell_obj [get_selection] {
        set cell_name [get_object_name $cell_obj]
        set bbox [get_attr $cell_obj bbox]
        regexp {(\{.*\})( \{.*\})} $bbox --> start end
        puts "set_object_fixed_edit \[get_cells $cell_name\] 0"
        puts "move_objects -to $start  $cell_name"

    }
return ""
}


#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: get selection& print to screen commands to creat partial blockages #
#====================================================================#
# Example: soc_export_place_p_blockages_of_get_selection                 #
#====================================================================#

proc soc_export_place_p_blockages_of_get_selection {} {
     foreach_in_collection block_obj [get_selection] {
        set bname [get_object_name $block_obj]
        set coordinate [get_attr $block_obj bbox]
        set type [get_attr $block_obj type]
        set blocked_percentage [get_attr $block_obj blocked_percentage]
        puts "create_placement_blockage -coordinate \{$coordinate\} -name new${bname} -type $type -blocked_percentage $blocked_percentage"

     }
return ""
}
