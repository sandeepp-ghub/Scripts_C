###################################
# make a table proc get an array width of coulman A & B
# and genereit a table 


proc make_A_table { args } {
    parse_proc_arguments -args ${args} results
    upvar $results(ramToPrint) ramToPrint
    set Aw      $results(-Acw)
    set Bw      $results(-Bcw)
    set header  $results(-header)
    set hA $results(-headerA)
    set hB $results(-headerB)
    
    set hAfix [string_pad $hA $Aw -fp 1 ]
    set hBfix [string_pad $hB $Bw -fp 1 ]

    set tablew [expr { $Aw + $Bw + "3" }]
    set stars  [string repeat "*" $tablew ]
    regsub -all {.} $stars "-" lines

    puts $stars;
    puts "*    [string_pad $header [expr {$tablew -6}]]*"
    puts $stars;
    puts "|${hAfix}|${hBfix}|"
     foreach pin [array names ramToPrint ] {
        set flag 1
        foreach ram [collection_to_list $ramToPrint($pin) -name_only -no_braces] {
            if {$flag == 1} { set p $pin; puts $lines } else { set p " " } 
            puts "|[string_pad $p $Aw -fp 1]|[string_pad $ram $Bw -fp 1]|"
            set flag 0
        }
    }
    puts $lines;


    }

define_proc_attributes make_A_table   \
    -info "wrapper for report_timing. this proc get two or more cells as input find the i/o/c pins of these cells and print a timing report" \
    -define_args {
                   {-Acw  "the width of column A"                "" string required}
                   {-Bcw  "the width of column B"                "" string required}
                   {-headerA  "the header of column A"           "" string required}
                   {-headerB  "the header of column B"           "" string required}
                   {-header  "the header of the table"           "" string required}
                   {ramToPrint "array of collections to prints"  "" string required}
    } 

