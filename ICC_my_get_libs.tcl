proc glib { cell } {
    
    return [get_lib_cells -of_objects [get_cells $cell]]
}

