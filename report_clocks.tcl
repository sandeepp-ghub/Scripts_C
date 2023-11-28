set txt ""
foreach_in_collection  c [get_clocks *] {
    echo [get_object_name $c]
    set name [get_object_name $c]
    set src  [get_object_name [get_attr $c sources]]
    set mst  [get_object_name [get_attr $c master_clock -q]]
    set eod  [sizeof_collection [all_registers -clock $c]]
    set pr   [get_attr $c period]
    set txt  "${txt}\n${name},${src},${mst},${eod},${pr}" 
}
echo $txt
