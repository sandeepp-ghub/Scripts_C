###Proc to generate skew histogram

proc generatingHistogram {nop step checkType} {
set paths [report_timing -collection -nworst 1 -max_paths $nop -check_type $checkType -path_group reg2reg]
set max_skew [lindex [lsort -real   [get_property $paths skew] ] end]
set min_skew [lindex [lsort -real   [get_property $paths skew] ] 0]
set skew1 [get_property $paths skew]

set noi [expr [expr int ([expr $max_skew*1000])/$step] + 1]
set nnoi [expr [expr int ([expr $min_skew*1000])/$step] * -1]

if {$nnoi >= $noi} {
    for {set i 0} {$i <= $nnoi} {incr i} {
        set count($i) 0
        set ncount($i) 0
    }
} else {
    for {set i 0} {$i <= $noi} {incr i} {
        set count($i) 0
        set ncount($i) 0
    }
}

foreach j $skew1 {
    if { $j >= 0.0 } {
        for {set i $noi} {$i > 0} {incr i -1} {
            set a [expr [expr $step * [expr $i - 1] * 0.001]]
            set b [expr [expr $step * $i] * 0.001]
            if { $j >= $a && $j < $b } {
                incr count($i)
            }
        }
    } elseif { $j < 0.0 } {
        for {set i 0} {$i < $nnoi} {incr i} {
            set a [expr [expr $step * $i] * -0.001]
            set b [expr [expr $step * [expr $i + 1]] * -0.001]
            if { $j < $a && $j >= $b } {
                incr ncount($i)
            }
        }
    }
}

set a ""
for {set i $noi} {$i > 0} {incr i -1} {
    lappend a $count($i)
}

for {set i 0} {$i < $nnoi} {incr i} {
    lappend a $ncount($i)
}

set maxcount [lindex [lsort -real $a] end]
puts "Max count: $maxcount"
set comp [expr $nop/10]
set comp1 [expr $comp/10]

for {set i $noi} {$i > 0} {incr i -1} {
    set a [expr [expr $step * [expr $i - 1] * 0.001]]
    set b [expr [expr $step * $i] * 0.001]
    puts "\n"
    puts -nonewline  "Paths between skew $b and $a are count($i) : $count($i)   "
    if {$maxcount >= $comp} {
        set normcount($i)  [expr $count($i)/$comp1]
        for {set i1 $normcount($i)} {$i1 >= 0} {incr i1 -1} {    
            puts -nonewline "#"
        } 
    } else {
            for {set i1 $count($i)} {$i1 > 0} {incr i1 -1} {    
                puts -nonewline "#"   
            }
        }
    }


for {set i 0} {$i < $nnoi} {incr i} {
    set a [expr [expr $step * $i] * -0.001]
    set b [expr [expr $step * [expr $i + 1]] * -0.001]
    puts "\n"
    puts  -nonewline "Paths between skew $a and $b are ncount($i) :$ncount($i)   "
    if {$maxcount >= $comp} {
        set normcount($i)  [expr $ncount($i)/$comp1]
        for {set i2 0} {$i2 <= $normcount($i)} {incr i2} {    
            puts -nonewline "#"
        } 
    } else {
    for {set i2 0} {$i2 < $ncount($i)} {incr i2 } {    
    puts -nonewline "#"       
    }
}
} 
puts "\n"
}

