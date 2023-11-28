set tot [llength [get_db insts -if {.is_spare==false&&.is_physical==false&&.is_black_box==false}]]
set buf [llength [get_db insts -if {.is_spare==false&&.is_physical==false&&.is_black_box==false&&.is_buffer==true}]]
set inv [llength [get_db insts -if {.is_spare==false&&.is_physical==false&&.is_black_box==false&&.is_inverter==true}]]
set com [llength [get_db insts -if {.is_spare==false&&.is_physical==false&&.is_black_box==false&&.is_combinational==true}]]
set sec [llength [get_db insts -if {.is_spare==false&&.is_physical==false&&.is_black_box==false&&.is_sequential==true}]]
set mac [llength [get_db insts -if {.is_spare==false&&.is_physical==false&&.is_macro==true}]]

puts "Sequential   : $sec"
puts "Combinational: $com"
puts "Buf/Inv      : [expr $buf+$inv]"
puts "Macros       : $mac"
puts "Total        : $tot"
