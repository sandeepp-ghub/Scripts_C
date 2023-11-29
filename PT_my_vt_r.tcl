set cells [get_cells * -hier -filter "is_hierarchical==false"]
set sum [sizeof_collection $cells]
set lnd 0
set lzd 0
set i 1
foreach_in_collection c $cells {
    puts  "cell $i from $sum"
    set ref   [get_attr $c ref_name]
    set slack [get_attr [get_timing_paths -through $c] slack]
    if {[regexp {([^_]*)(.*)} $ref --> vt end]} {
        if {$slack > 0 && $vt eq "lnd"} {incr lnd}
        if {$slack > 0 && $vt eq "lzd"} {incr lzd}
    } else {
        continue
    }
    
}
puts "there are $lnd lnd cells on a pos wns paths"
puts "there are $lzd lzd cells on a pos wns paths"


