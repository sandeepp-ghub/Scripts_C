set blocks [get_db insts -if {.base_cell==*dwc_ddrphydbyte_top_ew* || .base_cell==*dwc_ddrphyacx4_top_ew* || .base_cell==*dwc_ddrphymaster_top*}]
set i 0

foreach b $blocks {
    # block
    set x0 [get_db $b .bbox.ll.x] 
    set y0 [get_db $b .bbox.ll.y]
    set x1 [get_db $b .bbox.ur.x]
    set y1 [get_db $b .bbox.ur.y]
    set or [get_db $b .orient   ]
    puts "${x0} ${y0} ${x1} ${y1} : $or"
    set aprov_aficfn ""
    set aprov_afocfn ""
    set ipins  [get_db [get_db $b .pins -if {.direction==in && .is_clock==false && .is_clear==false  && .is_data==true}] .name]
    set afic   [all_fanin -to $ipins -trace_through all -startpoints_only -only_cells]
    set aficf  [filter_collection $afic "is_combinational==false&&is_macro_cell==false&&full_name!~*compressor*"]
    set aficfn [get_object_name $aficf]
    foreach reg $aficfn {
        set fo [filter_collection [all_fanout -from $reg/* -endpoints_only -only_cells] "full_name=~dwc_ddrphy_macro_0/u_DWC_DDRPHY0_top/dwc_ddrphy_top_i/u_DWC_DDRPHY*"]
       if {[sizeof_collection $fo] > 1} {
            puts "DBG:: $reg  :: [sizeof_collection $fo] :: [get_object_name $fo] "
       } else {
            lappend aprov_aficfn $reg
       }
    }
#set afici [get_db insts $aficn -if {.is_sequential==true &&.is_macro==false}]

    set opins [get_db [get_db $b .pins -if {.direction==out && .is_clock==false && .is_clear==false                  }] .name]
    set afoc  [all_fanout -from $opins -trace_through all -endpoints_only -only_cells]
    set afocf [filter_collection $afoc "is_combinational==false&&is_macro_cell==false&&full_name!~*compressor*"]
    set afocfn [get_object_name $afocf]
#set afoci [get_db insts $afocn -if {.is_sequential==true &&.is_macro==false}]
 
    foreach reg $afocfn {
        set fi [filter_collection [all_fanin -to $reg/D* -startpoints_only -only_cells] "full_name=~dwc_ddrphy_macro_0/u_DWC_DDRPHY0_top/dwc_ddrphy_top_i/u_DWC_DDRPHY*"]
       if {[sizeof_collection $fi] > 1} {
            puts "DBG:: $reg  :: [sizeof_collection $fi] :: [get_object_name $fi] "
       } else {
            lappend aprov_afocfn $reg
       }
    }






    create_group -name SNPS_MACRO_BOUND_$i  -type region
    #set reg_bounds [get_db insts $afocfn]
    foreach inst $aprov_afocfn {
        update_group -name SNPS_MACRO_BOUND_$i -add -objs $inst
    }
    foreach inst $aprov_aficfn {
        update_group -name SNPS_MACRO_BOUND_$i -add -objs $inst
    }
    if {$or eq "r0"} {
        set bx0 [expr $x1 + 0]
        set by0 [expr $y0 + 0]
        set bx1 [expr $x1 + 55]
        set by1 [expr $y1 + 0]
    } else {
        set bx0 [expr $x0 - 55]
        set by0 [expr $y0 + 0]
        set bx1 [expr $x0 + 0]
        set by1 [expr $y1 + 0]
    }
    create_boundary_constraint   -type region -group SNPS_MACRO_BOUND_$i -rects "\{$bx0 $by0 $bx1 $by1\}"    
    incr i

}
