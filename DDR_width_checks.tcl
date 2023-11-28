#VTEL_P
#VTEL_N

set bss [get_db base_cells]
foreach bs  $bss {
    set dxs  [get_db [get_db $bs .obs_layer_shapes -if {.layer == layer:VT*}] .shapes.rect.length]
    foreach dx $dxs {  
        if {$dx < 0.153 } {puts "$bs :: $dx"}
    }
}

get_db [get_db [get_db base_cell:BUFFD1BWP210H6P51CNODULVT ] .obs_layer_shapes -if {.layer == layer:VTUL_P}] .shapes.rect.length
