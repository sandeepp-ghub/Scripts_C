gui_bind_key g  -cmd "find_fanout_flops" 
gui_bind_key Shift-g -cmd "find_fanin_flops" 

proc find_fanin_flops {} {
    puts "DBG:: working"
    set select_cells [get_db selected -if {.obj_type==inst} ]
    set select_ports [get_db selected -if {.obj_type==port && .direction==out } ]
    deselect_obj -all
    if {$select_cells ne ""} {
#set ipins [get_db [get_db $select_cells .pins -if {.direction==in && .is_clock==false && .is_clear==false  && .is_data==true}] .name]
        set ipins [get_db [get_db $select_cells .pins -if {.direction==out && .is_clock==false && .is_clear==false                  }] .name]
        set afic [all_fanin -to $ipins -trace_through all -startpoints_only -only_cells]
        set afip [get_db ports [get_object_name [all_fanin -to $ipins -trace_through all -startpoints_only]]]
        if {$afic ne ""} {
            select_obj $afic
            foreach_in_collection af $afic {
                puts "Fanin ::[get_object_name $af]"
            }
        }
        if {$afip ne ""} {select_obj $afip}
    }
    if {$select_ports ne ""} {
        set ipins [get_db $select_ports .name]
        set afic [all_fanin -to $ipins -trace_through all -startpoints_only -only_cells]
        set afip [get_db ports [get_object_name [all_fanin -to $ipins -trace_through all -startpoints_only]]]
        if {$afic ne ""} {select_obj $afic}
        if {$afip ne ""} {select_obj $afip}

    }
    gui_highlight -color yellow
}




proc find_fanout_flops {} {
    puts "DBG:: working"
    set select_cells [get_db selected -if {.obj_type==inst} ]
    set select_ports [get_db selected -if {.obj_type==port && .direction==in } ]
    deselect_obj -all
    if {$select_cells ne ""} {
        #set ipins [get_db [get_db $select_cells .pins -if {.direction==in && .is_clock==false && .is_clear==false  && .is_data==true}] .name]
        set opins [get_db [get_db $select_cells .pins -if {.direction==out && .is_clock==false && .is_clear==false                  }] .name]
        set afoc [all_fanout -from $opins -trace_through all -endpoints_only -only_cells]
        set afop [get_db ports [get_object_name [all_fanout -from $opins -trace_through all -endpoints_only]]]
        if {$afoc ne ""} {select_obj $afoc}
        if {$afop ne ""} {select_obj $afop}
    }
    if {$select_ports ne ""} {
        set opins [get_db $select_ports .name]
        set afoc [all_fanout -from $opins -trace_through all -endpoints_only -only_cells]
        set afop [get_db ports [get_object_name [all_fanout -from $opins -trace_through all -endpoints_only]]]
        if {$afoc ne ""} {select_obj $afoc}
        if {$afop ne ""} {select_obj $afop}

    }
    gui_highlight -color yellow
}


