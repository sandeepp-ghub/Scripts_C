
        set latch_cells [get_cells -hierarchical -quiet -filter "full_name =~*LATCH_FIFO* && is_sequential == true && is_hierarchical == false"]
        puts "Lioral Info: Removing dont_touch and size_only from [sizeof_collection ${latch_cells}] latches in design..."

        if { [sizeof_collection $latch_cells] > 0 } {

            set_dont_touch $latch_cells false
            set_size_only $latch_cells false
            set_dont_touch [get_nets -of $latch_cells] false
        }


