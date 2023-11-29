#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: print all pins of a cell (object). can return a list. #
#====================================================================#
# Example: set <list name> [file_to_list <file path>]                #
#====================================================================#


proc pp { args } {
    parse_proc_arguments -args ${args} results

    set pin_col [get_pins -of_object $results(a)]
    foreach_in_collection i $pin_col {
        set name [ get_object_name $i]
        puts $name
        lappend return_list $name;
    }
 if { ![info exists results(-nr)] } {return {}} else {return $return_list};
}

define_proc_attributes pp \
    -info "this proc will print a collection one by one & return a list of objects name -help" \
    -define_args {
        {a     "a collection"          a  list    required}
        {-nr   "do return value"  -nr boolean optional}

}

