proc remove_bonus_cells_and_ties {} {
    set bonus [get_cells * -hierarchical -filter "full_name=~kw28_alpha_macro_bonus_top*"]
    set bonus_filtered [filter_collection $bonus "ref_name==szd_scbuflpcapx16 OR ref_name==szd_soai21b1x4 OR ref_name==szd_soai22x4 OR ref_name==szd_saoi22x4"] 
    foreach_in_collection c $bonus_filtered {
        set net [get_nets -of_object $c]
        append_to_collection nets $net -unique
    }
    remove_cell [collection_to_list $bonus_filtered -name_only -no_braces]

    

    foreach_in_collection n $nets {
        set cells_of_net [get_cells -of_object $n -filter "name!~*tiel*"]
        if {$cells_of_net eq ""} {
            set tiel_of_net [get_cells -of_object $n -filter "name=~*tiel*"]
            append_to_collection net_to_del $n -unique
            append_to_collection tiel_to_del $tiel_of_net -unique

        }
    }
        remove_net    [collection_to_list $net_to_del -name_only -no_braces]
        remove_cell   [collection_to_list $tiel_to_del -name_only -no_braces]
    return ""
}


