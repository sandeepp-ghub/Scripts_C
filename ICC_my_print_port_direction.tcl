#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description:        #
#====================================================================#
# Example: set <list name> [file_to_list <file path>]                #
#====================================================================#


# get part of a name of ports and return ports ans slacks.

proc ppd {in_name} {
    foreach_in_collection i [get_ports ${in_name}*] {
        echo [format " %-25s  %s " [get_object_name $i]  [get_attr $i direction]]
    }
}
