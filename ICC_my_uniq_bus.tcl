#######################################################
# this proc will print the pins of cell in a uniq way #
# bus will be set only be name                        #
#                                                     #
# Lior Allerhand 24/9/12                              #
# #####################################################

proc ppu { cell } {
    set pins [get_pins -of_object $cell]
    set pins_as_list [collection_to_list $pins -name_only -no_braces]
    foreach p $pins_as_list {
       regexp {([^\[]*)(.*)} $p all name number 
       lappend new_pin_list $name;
    }
    foreach p [lsort -u $new_pin_list] { puts $p }
}
