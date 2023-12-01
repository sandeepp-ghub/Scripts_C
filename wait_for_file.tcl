proc waitForFiles {directory} {
    set files [glob -directory $directory -nocomplain]
    if {[llength $files] == 0} {
   # sh bfw run -from invcui_pre_fp
   puts "iside if loop"
    }
    # check again in 100 milliseconds
    after 100 [list waitForFiles $directory]
}
