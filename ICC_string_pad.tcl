########################################################
#string_pad                                            #
#will pad a string with spaces to fit a given length   #
#                                                      #
#lior allerhand 25/9/12                                #
########################################################

proc string_pad { args } {
     
    set fp 0
    parse_proc_arguments -args ${args} results
    set str $results(input_string)
    set len $results(string_length)
    
    if {[info exists results(-fp)] == 1} {
        set pad [string repeat " " $results(-fp)]
        set str [append pad $str]
        set fp $results(-fp)
    }

    if { [expr { $len - $fp }] < [string length $str] } { return $str; }
    
       set pad_num [expr { $len - [string length $str] }]
    set pad [string repeat " " $pad_num]
    set str [append str $pad]
    return $str

}
define_proc_attributes string_pad  \
    -info "string pad will pad an input string with space so string will be in the input length" \
    -define_args {
                   {input_string "the input string to work on"  ""    string required}
                   {string_length "the length of the output string" <n>  string required}
                   {-fp "number of spaces to add in the beginning of the string" <n> string optional}
                  

}

