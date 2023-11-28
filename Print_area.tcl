proc print_area {} {
     set allCells [get_cells * -hier -filter  "is_hierarchical==false&&name!~*_spr_*&&name!~spare*"]
     set allmems  [filter_collection [all_registers] "base_name=~m_*"]
     set allrnl   [remove_from_collection [all_registers] $allmems]
     set allreg   [remove_from_collection [all_registers -flops] $allmems]
     set 1bflop   [filter_collection $allreg ref_name!~*MB*]
     set 2bflop   [filter_collection $allreg ref_name=~*MB2*]
     set 4bflop   [filter_collection $allreg ref_name=~*MB4*]
     set alllat   [remove_from_collection [all_registers -latches] $allmems]
     set bufs     [filter_collection $allCells "ref_name=~*BUF*||ref_name=~*INV*||ref_name=~*DLY*||ref_name=~*CKND*||ref_name=~*CKBD*"]
     set logics   [filter_collection $allCells "is_combinational==true&&(ref_name!~*BUF*&&ref_name!~*INV*&&ref_name!~*DLY*&&ref_name!~*CKND*&&ref_name!~*CKBD*)"]
       
     foreach check {allCells allmems allrnl allreg alllat bufs logics 1bflop 2bflop 4bflop} {
         puts $check
         set size [sizeof_collection [set $check]]
         puts $size
         set area 0
         foreach_in_collection b [set $check] {
             set tmp [get_property $b area ]
             set area [expr $area + $tmp]
         }
         puts $area
         puts "============"
         set ${check}_size $size
         set ${check}_area $area
     }
          
     puts "All cells count           :: $allCells_size"
     puts "All cells Total Area      :: $allCells_area"
     puts "Logic cells count         :: $logics_size"
     puts "Logic cells Total Area    :: $logics_area"
     puts "Buf/Inv cells count       :: $bufs_size"
     puts "Buf/Inv Total Area        :: $bufs_area"
     puts "Register cells count      :: $allrnl_size"
     puts "Register cells Total Area :: $allrnl_area"
     puts "Memories cells count      :: $allmems_size"
     puts "Memories Total Area       :: $allmems_area"
     puts "flops cells count         :: $allreg_size"
     puts "flops cells Total Area    :: $allreg_area"
     puts "Latch cells count         :: $alllat_size"
     puts "Latch cells Total Area    :: $alllat_area"
     puts "1b flops cells count      :: $1bflop_size"
     puts "1b flops cells Total Area :: $1bflop_area"
     puts "2b flops cells count      :: $2bflop_size"
     puts "2b flops cells Total Area :: $2bflop_area"
     puts "4b flops cells count      :: $4bflop_size"
     puts "4b flops cells Total Area :: $4bflop_area"


}
