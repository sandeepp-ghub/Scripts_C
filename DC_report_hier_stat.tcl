echo "Inst,Ref_name,Total cells,Srams,Flops,Buffers,Logic,Total cells Area,Sram area,Flops area,Buffers area,Logic Area"
set tiesS 0
set all_regs [all_registers]
foreach_in_collection h  [get_cells -filter "is_hierarchical==true"] {
    set inst   [get_object_name $h] 
    set ref    [string range [get_attr $h ref_name] 0 18]
    set cells  [get_cells * -hierarchical -filter "full_name=~$inst/* && is_hierarchical==false"]
    set cellsS [sizeof_collection $cells]
    set cellsA [area $cells]
    set srams  [get_cells * -hierarchical -filter "is_hierarchical==false&& (full_name=~$inst/*sram*/m_*||full_name=~$inst/*sram/m_*)"]
    set sramsS [sizeof_collection $srams]
#if {$sramsS > 0} {foreach_in_col s $srams {echo [get_object_name $s]}}
    set sramsA [area $srams]
    set regs   [filter_collection $all_regs "full_name=~$inst/* && full_name!~$inst/*sram*/m_* && full_name!~$inst/*sram/m_*"]
    set regsS  [sizeof_collection $regs]
    set regsA  [area $regs]
    set bufs   [filter_collection $cells "ref_name=~*BUF*||ref_name=~*INV*"]
    set bufsS  [sizeof_collection $bufs]
    set bufsA  [area $bufs]
    set logicsS [expr $cellsS - $sramsS - $regsS - $bufsS]
    set logicsA [expr $cellsA - $sramsA - $regsA - $bufsA]

    echo $inst,$ref,$cellsS,$sramsS,$regsS,$bufsS,$logicsS,$cellsA,$sramsA,$regsA,$bufsA,$logicsA
    
}

echo "TIES $tiesS"

set tiesS 0
proc area {col} {
    global tiesS
    set tot 0
    foreach_in_collection c $col {
        set temp [get_attr $c area -q]
        if {$temp eq ""} {set tiesS [expr $tiesS + 1] ;continue} 
        set tot [expr $tot + $temp]
    }
    return $tot

}


if {0} {
set inst u_hnf_nid32
set regs   [filter_collection $all_regs "full_name=~$inst/* && full_name!~$inst/*sram*/m_* "]
foreach_in_collection reg $regs {
    set name [get_object_name $reg  ]
    set ref  [get_attr $reg ref_name]
    set area  [get_attr $reg area    ]
    echo "$name,$ref,$area" >> u_hnf_nid32.csv
}

set inst u_smxp_1_1
set regs   [filter_collection $all_regs "full_name=~$inst/* && full_name!~$inst/*sram*/m_*"]
foreach_in_collection reg $regs {
    set name [get_object_name $reg  ]
    set ref  [get_attr $reg ref_name]
    set area  [get_attr $reg area    ]
    echo "$name,$ref,$area" >> u_smxp_1_1.csv
}
}
