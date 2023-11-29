proc <proc_name> { args } {

global env

    # set default value for args element
    set results(<arg1_name>) 1     
    set results(<arg2_name>) 1

    # parse input args
    parse_proc_arguments -args ${args} results

    # sanity check on input arguments
    if { $results(-cells) eq {} } {
        puts "Error: Given cells list is empty."
        return
    }
#----------------------proc body----------------------------------



set infile   [open $file_path r]
while {[gets $infile line] >= 0}  {

#  if {[ regexp stuff2com $line ]} { do stuff }

    lappend templist $line;
}
close $infile;

}

#---------------------define proc attributes----------------------
define_proc_attributes <proc_name> \
    -info "this stuff will print whan user write <porc_name> -help" \
    -define_args {
        {a         "first addend arg"           a string required}
        {b         "second addend arg"          b string required}
        {-verbose  "issue a message"           "" boolean optional}
        {-cts_cell "the cts cell name"         "" list    optional}
        {-lib_cell "the library cell name"     "" list    optional}
        {-debug    "debug mode"                "" boolean optional}
        {-Int int help AnInt int optional}
        {-Float float help AFloat float optional}
        {-String "string help" AString string optional}
        {-Oos oos help AnOos one_of_string {required value_help {values {a b}}}}


}






#### loop and condition
# if {cond1 || cond2 && cond3 } { }
# foreach i $list { puts $i; }
# for {set i 0} {$i<0} {incr i} { puts $i }
# set x 0; while {$x<0} { puts $x}
# set a [expr {double $a/$b}] 
# set my_list [split $a _]
# set my_string [join  $a _]
# lindex
# lset

###### string #######
# string range 
# string map
# string compare
# string match
# string first
# string last
# string index
# string trim
# switch
# string toupper/tolower $old_string   => "NEW STRING"

###### list ######
# set new_list [list a b c]



###### array ######





################################
#  how 2 use split,join & lset #
#  to change part of string    #
################################
#set a lzd_buff_8   -> lzd_buff_8  # 
#set b [split $a _] -> lzd buff 8  # split the string to a list by _. can be /\. and stuff.
#lset b end "32"    -> lzd buff 32 # change the last var at a list. end is an index it can be 0 1 2.....end-1 end
#join $b _          -> lzd_buff_32 # join a list to string with _ between list var

###################################
# find and replace part of string #
###################################
#set myString "lior allerhand is a golden god";
#set myNewString  [string map {god dog} $myString] -> lior allerhand is a golden d...

#set myString "oneTwoThree
#set myNewString [string replace $myString 3 5 three] -> onethreeThree
###################################
# cat a sub string from string    #
###################################
#set MY_SUB_STRING [string range $MY_STRING 0 end-1] 

###################################
#  add stuff to end of line       #
###################################

