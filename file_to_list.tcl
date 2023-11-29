######################################
# get file return a list             #
# Lior Allerhand 1/12/12             #
######################################

proc file_to_list {file_path} {
    set infile   [open $file_path r]
    while {[gets $infile line] >= 0}  {
        lappend out_list $line
        }
    close $infile;
return $out_list
}


