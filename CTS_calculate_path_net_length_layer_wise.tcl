proc calculatePathNetLengthLayerWise {args} {
    parse_proc_arguments -args $args opt
    set sink $opt(-sink)
    set skew_group $opt(-skew_group)
    set net [get_object_name [get_nets -of_objects [get_skew_group_path -skew_group $skew_group -sink $sink]]]
    set metal_layer [get_db [get_db layers -if { .type == routing}] .name]
    puts "Net cts_net_type route_rule $metal_layer total \n"
    foreach k $net {
        printf "$k "
        printf "[get_db net:$k .cts_net_type] "
        if { [get_db net:$k .route_rule.name] == "" } { 
            printf "NA " 
        } else {
            printf "[get_db net:$k .route_rule.name] "
        }
        set total 0
        foreach j $metal_layer {
            set sum 0
            foreach i [get_db [get_db -u net:$k .wires -if { .layer.name == $j }] .length] {
                set sum [expr $sum + $i]  
            }
            printf "[format "%.1f" $sum] "
            set total [expr $total + $sum]
        }
        print "[format "%.1f" $total]"
    }
    
    printf "Total NA NA "
    set net [get_object_name [get_nets -of_objects [get_skew_group_path -skew_group $skew_group -sink $sink]]]
    foreach j $metal_layer {
        set total 0
        foreach k $net {
            set sum 0
            foreach i [get_db [get_db -u net:$k .wires -if { .layer.name == $j }] .length] {
                set sum [expr $sum + $i]  
            }
            set total [expr $total + $sum]
        }
        printf "[format "%.1f" $total] "
    }
    printf "\n"
}

define_proc_arguments calculatePathNetLengthLayerWise -info "Calculate the layer wise net length for all the net in that path"\
-define_args {
    {-skew_group "specify the skew_group name" "" string required}
    {-sink "specify the sink name" "" string required}
}

