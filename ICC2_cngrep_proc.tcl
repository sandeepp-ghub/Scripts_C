### ************************************************************************
### *                                                                      *
### *  MARVELL CONFIDENTIAL AND PROPRIETARY NOTE                           *
### *                                                                      *
### *  This software contains information confidential and proprietary     *
### *  to Marvell, Inc. It shall not be reproduced in whole or in part,    *
### *  or transferred to other documents, or disclosed to third parties,   *
### *  or used for any purpose other than that for which it was obtained,  *
### *  without the prior written consent of Marvell, Inc.                  *
### *                                                                      *
### *  Copyright 2019-2019, Marvell, Inc.  All rights reserved.            *
### *                                                                      *
### ************************************************************************
### * Author      : Lior Allerhand
### * Description : catchs a command ouput. 
### *               print to screen matching regexp patterns (date 04/16/19)
### ************************************************************************



proc cn_grepProc {args} {
    if {[catch {redirect -var temp {uplevel 1 [join [lrange $args 1 end]]}} error_msg]} {
        return -code error "$error_msg"
    } else {
        foreach line [split $temp "\n"] {
             set pat [lindex $args 0]
            if {[regexp $pat $line ]} {echo $line}
        }
    }
}    


