proc highlight_macro_per_module {{depth 4}} {
set hier_list [get_db designs .local_hinsts -depth $depth] 
set i 1
foreach hier $hier_list {
set macro_list [get_db [get_db $hier .insts -if {.base_cell.base_class == "block"}] .name]
if {$macro_list != ""} {
select_inst $macro_list
gui_highlight -index $i
deselect_obj -all;
if {$i < 63} {
incr i
} else {
set i 1
}}}}
