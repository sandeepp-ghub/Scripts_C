proc split_selected_from_net {net_or_pin} {

    if {[set pin [get_pins $net_or_pin -q]] ne ""} {
        set net [get_nets -of $pin] 
    } else {
        set net [get_net $net_or_pin]
    }
    if {[sizeof_collection $net] ne 1} {
        puts "Lioral-Error net num not eq 1 returning [get_object_name $net]"
        return
    }

    set selected [get_db selected]
    
    puts "LiorAl-Info:: net name [get_object_name $net]"
    puts "LiorAl-Info:: selected exists split loads"
    set out [filter [get_pins -of $net -leaf] direction==out]
    set in  [filter [get_pins -of $net -leaf] direction==in]
    gui_deselect -all
    select_obj $net
    gui_highlight -color yellow
    gui_deselect -all
    select_obj [get_cells -of $out -q]
    gui_highlight -color green
    gui_deselect -all
    select_obj [get_cells -of $in -q]
    gui_highlight -color red
    gui_zoom -selected
    gui_zoom -in
    gui_deselect -all
    set netdb [get_db nets [get_object_name $net]]
    #puts [get_object_name $net]
    #puts $netdb
    #set pins [get_db $selected .pins -if .net==$netdb]
    set pins [get_db $selected .pins -if .net==$netdb]
    set i    0
    set pxt  0
    set pyt  0
    set pxav 0
    set pyav 0
    set nn [get_object_name $net]
    puts $nn
    foreach pin $pins {
        set px [get_db $pin .location.x]
        set py [get_db $pin .location.y]
        incr i
        set pxt [expr $pxt + $px]
        set pyt [expr $pyt + $py]
    }
    set pxav [expr $pxt / $i ]
    set pyav [expr $pyt / $i ]
    puts "pxav $pxav"
    puts "pyav $pyav"
    if {$i > 0} {
        puts "LiorAl-Info:: more then zero endpoint exists running eco"
    }
    #uniq to the second name
    set fname_date [clock format [clock seconds] -format {%d_%h_%y__%H_%M_%S}]
    puts $fname_date

    create_net -name "MAX_TRANS_CAP_FANOUT_ECO_NET_split_selected_from_net_$fname_date"
    create_inst -name "MAX_TRANS_CAP_FANOUT_ECO_CELL_split_selected_from_net_$fname_date" -location $pxav $pyav -base_cell BUFFD8BWP210H6P51CNODULVT
    foreach pin $pins {
        puts $pin
        set bpn [get_db $pin .base_name]
        set cn [get_db $pin .cell_name]
        puts $bpn
        puts $cn
        disconnect_pin -inst $cn -pin $bpn
        connect_pin -inst $cn -pin $bpn -net "MAX_TRANS_CAP_FANOUT_ECO_NET_split_selected_from_net_$fname_date"
    }
    connect_pin -inst "MAX_TRANS_CAP_FANOUT_ECO_CELL_split_selected_from_net_$fname_date" -pin Z -net "MAX_TRANS_CAP_FANOUT_ECO_NET_split_selected_from_net_$fname_date"
    connect_pin -inst "MAX_TRANS_CAP_FANOUT_ECO_CELL_split_selected_from_net_$fname_date" -pin I -net $nn
    gui_deselect -all
    select_obj [get_cells "MAX_TRANS_CAP_FANOUT_ECO_CELL_split_selected_from_net_$fname_date" -q]
    gui_highlight -color pink

}   
