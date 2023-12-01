proc trace_path {in_net fileName} {
  set fp [open $fileName w]
  set found 1
  deselectAll
  puts $fp "input net\t\t instance\t\t cell"
  puts $fp "=========\t\t ========\t\t ===="
  while {$found} {
    set input_pins [dbget [dbget [dbget top.nets.name $in_net -p].instTerms.isInput 1 -p].name]
    regsub -all "{" $input_pins "" input_pins
    regsub -all "}" $input_pins "" input_pins
    set count 0
    set inputs [llength $input_pins]
    while {$count < $inputs} {
      set in_pin [lindex $input_pins $count]
      set instance [dbget [dbget top.insts.instTerms.name $in_pin -p2].name]
      set inv [dbget [dbget top.insts.name $instance -p].cell.isInverter]
      set buf [dbget [dbget top.insts.name $instance -p].cell.isBuffer]
      set cell [dbget [dbget top.insts.name $instance -p].cell.name]
      if {(($buf) || ($inv))} {
        selectNet $in_net
        selectInst $instance
        puts $fp "$in_net\t $instance\t$cell"
        set in_net [dbget [dbget [dbget top.insts.name $instance -p].instTerms.isOutput 1 -p].net.name]
        set found 1
        break
      } else {
        set found 0
        incr count
      }
    }
  }
  close $fp
}


