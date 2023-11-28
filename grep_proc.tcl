### ************************************************************************
### * Author      : Lior Allerhand
### * Description : catches a command output. 
### *               print to screen matching to regexp patterns (date 04/16/19)
### ************************************************************************



proc grep_proc {args} {
    if {[catch {redirect -var temp {uplevel 1 [join [lrange $args 1 end]]}} error_msg]} {
        return -code error "$error_msg"
    } else {
        foreach line [split $temp "\n"] {
             set pat [lindex $args 0]
            if {[regexp $pat $line ]} {echo $line}
        }
    }
}    


