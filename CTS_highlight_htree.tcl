#### Script to highlight the sinks of CCOpt clock trees / or multi-tap sinks of an H-tree 

set tmp_dir ./clock_tree
rm -rf $tmp_dir 
mkdir $tmp_dir 
set_preference CmdLogMode 1 
set color 1 

### To filter each clock tree or multi-tap clocks. Use only one of the foreach command as needed. 
### Also modify it to specify the correct name of flexible Htree Tap points.

#foreach cur_clk [get_db [get_db clock_trees *flex_Htree*] .name] { 
foreach cur_clk [get_db [get_db clock_trees *] .name] {

### Write each clock to specific files, to source it later, if needed. 
   set cur_file "${tmp_dir}/hilite_${cur_clk}.tcl" 
   set FH [open $cur_file w] 
   set all_active_sinks [get_db [get_db clock_trees $cur_clk] .sinks]
   puts $FH "gui_deselect -all"
    foreach cur_sink $all_active_sinks { 
      puts $FH "select_obj $cur_sink" 
    } 
### Assigning different color 
    if {$color > 64} {
      set color 1
    } 
   puts $FH "gui_highlight \[get_db selected .inst\] -index $color" 
   puts $FH "gui_deselect -all" 
   incr color 

   flush $FH 
   close $FH 

### To highlight only specific clock tree/tap point, comment the following command. And source specific file separately.
  # source $cur_file 
 }
# }


