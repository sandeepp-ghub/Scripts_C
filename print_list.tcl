#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: print a list line by line have an regexp flag         #
#====================================================================#
# Example: pl $list                                                  #
#====================================================================#


proc pl { args } {
    parse_proc_arguments -args ${args} results
    set inlist $results(inlist)
    if {[info exists results(-regexp)]} { set exp $results(-regexp) }

    if {[info exists results(-regexp)]} {
        foreach l $inlist {
            if {[regexp $exp $l]} {
                puts $l 
            }
        }
    } else {
        foreach l $inlist {
            puts $l
        }
    }
    
}

define_proc_arguments pl \
    -info "this stuff will print whan user write <porc_name> -help" \
    -define_args {
        { inlist "input list"                          "" string    optional}
        {-regexp "print only list object who regexp"   "" string    optional}}
