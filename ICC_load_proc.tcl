proc rp { args } {

    global path_to_last_proc_loaded
    parse_proc_arguments -args ${args} results
     if {[info exists results(path)] == 1} {
        set path_to_last_proc_loaded  $results(path)
    }
    eval {source $path_to_last_proc_loaded}

}


define_proc_attributes rp  \
    -info "load the lest proc or set a new proc path to load" \
    -define_args {
                   {path "the path to the proc" "" string optional}
                  
}

