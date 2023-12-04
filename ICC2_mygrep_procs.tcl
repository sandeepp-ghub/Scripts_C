global attrs
proc my_get_attr {object pattern} {
    global attrs
    redirect -var attrs {[list_attributes -class [get_attr [index_collection $object 0] object_class] -app -nosplit]}
    set pattern "\\S*${pattern}\\S*"
#    echo $pattern
    foreach a [split $attrs \n ] {
        if {[regexp ($pattern) $a -> pat ]} {
            echo $pat
            echo [get_attr [index_collection $object 0] $pat]
        
        } else {}
    }
}
