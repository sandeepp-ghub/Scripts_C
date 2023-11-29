#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: print a collection line by line. can return a list    #
#====================================================================#
# Example: pc $collection                                            #
#====================================================================#


proc pc { args } {
    parse_proc_arguments -args ${args} results



    foreach_in_collection i $results(a) {
        set name [ get_object_name $i]
        puts $name 
        lappend return_list $name;
    }
if { ![info exists results(-nr)] } {return {}} else {return $return_list};
}

define_proc_attributes pc \
    -info "this proc will print a collection one by one & return a list of objects name " \
    -define_args {
        {a     "a collection"          a  list    required}
        {-nr   "do return value"  -nr boolean optional}

}

