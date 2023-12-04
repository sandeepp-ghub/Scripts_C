proc soc_rt { args } {

set results(-number) 10
parse_proc_arguments -args ${args} results
set incell  $results(startPoint);
set outcell $results(endPoint);


set incelloutpins  [get_pins -of_object [get_cell $incell] filter "direction==out AND pin_type==DataOut"]
set incellclock    [get_pins -of_object [get_cell $incell] filter "direction==in AND pin_type==Clock"   ]
set outcellinpins  [get_pins -of_object [get_cell $incell] filter "direction==in  AND pin_type==DataIn" ]
set thrcelloutpins [get_pins -of_object [get_cell $incell] filter "direction==out AND pin_type==DataOut"]





}

  
#---------------- proc body -----------------------------------------#



return $my_return
}; #end of procs

define_proc_attributes look_one_level_up  \
    -info "wrapper for report_timing. this proc get two or more cells as input find the i/o/c pins of these cells and print a timing report" \
    -define_args {
                   {startPoint  "input collection of cells"        input  "" string required}
                   {thr_list "input collection of cells"       output list optional}
                   {endPoint  "highlight the new collection in gui" -from string optional}
                   {-number    "highlight the new collection in gui" <n> string optional}

}

