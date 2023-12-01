proc highlightModule { } {
      set file1 [open module_highlight.tcl w]
        puts $file1 "dehighlight -all;setPreference HighlightColorNumber 16"
          set module_list [dbGet top.hInst.treeHInsts.name *]
            set count 0
              foreach m $module_list {
                      if {$count != 0 && $count < 17 } { puts $file1 "selectModule $m ; highlight -index $count;deselectAll " }
                            incr count
                                }
                                  close $file1
}
 
