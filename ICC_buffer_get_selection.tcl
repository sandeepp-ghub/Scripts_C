#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: disconnect get_selection cells from input net         #
#              and connect ref_name buffer in the middle             #
#====================================================================#
# Example: soc_buffer_get_selection <some_net> lnd_sbufx24           #
#====================================================================#

proc soc_buffer_get_selection {net ref_name} {
#    set ref_name lnd_sbufx24
    set pre_fix ""
    set pins ""
    set gs          [get_selection]
    set pins_gs     [get_pins -of_object $gs -filter "direction==in"]
    set pins_net    [all_connected $net -leaf]
#pc $pins_gs
#    puts "------------"
#    pc $pins_net
    foreach_in_collection pgs $pins_gs {
        foreach_in_collection pnet $pins_net {
            if {[get_attr $pgs full_name] eq [get_attr $pnet full_name]} {
                puts "[get_attr $pgs full_name] eq [get_attr $pnet full_name]"
                append_to_collection pins $pnet
#puts "Info: add [get_object_name $pins_net]"
                break
            }
        }
    }
    set a [index_collection $pins 0]
    set v_driver_x [get_attribute $a bbox_llx]
    set v_driver_y [get_attribute $a bbox_lly]
    set post_fix [clock format [clock scan now] -format "%m-%d-%y_%H-%M"]
    puts "Info: creating buffer"
    create_cell ${pre_fix}buffer_get_selection_${post_fix}  $ref_name
    move_objects -to "${v_driver_x} ${v_driver_y}" [get_cells ${pre_fix}buffer_get_selection_${post_fix}]
    foreach_in_collection p $pins {
        puts "Info: disconnecting net $net from $p"
        disconnect_net [get_nets -of_object $p] $p
        puts "Info: connecting pins $p --> [get_pins buffer_get_selection_${post_fix}/Z -hier]"
        puts "\n\n\n\n\n"
        connect_pin -to ${p} -from [get_pins ${pre_fix}buffer_get_selection_${post_fix}/Z -hier] -port_name buffer_get_selection_port
    }
    connect_net $net [get_pins ${pre_fix}buffer_get_selection_${post_fix}/A -hier]

    return [sizeof_collection $pins]        
    
}
