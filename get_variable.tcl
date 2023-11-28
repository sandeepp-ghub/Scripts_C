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
### * Description : Regexp through all set variable at the open tool memory 
### * (date 04/16/19)
### ************************************************************************



proc get_variable {args} {
    #-- args prsing
    global regexpPattern
    global PrintValue
    global RegexpValue
    set regexpPattern ""
    parse_proc_arguments -args ${args} results
    set regexpPattern $results(regexpPattern)
    echo "ABC"
    if {[info exists results(-printValue)]}  {set PrintValue 1 }  else {set PrintValue 0}
    if {[info exists results(-regexpValue)]} {set RegexpValue 1 } else {set RegexpValue 0}

    #-- going over all vars at tool memory
    uplevel 1 {;# moving out of proc scop;
        foreach var [info vars *] {
           if {[array exists $var]} {
              # this is an array; search through all elements
              foreach element [array names $var] {
                  if {([regexp $regexpPattern "$var\($element\)"] & $RegexpValue eq 0)|([regexp $regexpPattern [set ${var}($element)]] & $RegexpValue eq 1)} {
                      if {$PrintValue eq 1} {
                          echo "$var\($element\) == [set ${var}($element)]"
                      } else {
                          echo "$var\($element\)"
                      }
                  }
              }
           } else {
              # this is a scalar... search just the variable
     
                if {([regexp $regexpPattern $var ] & $RegexpValue eq 0)|([regexp $regexpPattern [set $var] ] & $RegexpValue eq 1)} {
                    if {$PrintValue eq 1} {
                        echo "$var == [set $var]"
                    } else {
                        echo $var
                    }
                }
           }
        }
    };# uplevel 
}


define_proc_arguments get_variable \
    -info "Regexp through all set variable at an open tool(dc,icc,pt ....).\n\t\t\t Print the variable that match the given regexp pattern. \n\t\t\t In case of an array this proc will dive into array keys + array name." \
    -define_args {
        {regexpPattern                "regexp pattern"                                                    "regexpPattern"       string    required}
        {-printValue                   "print variable value"                                             ""       boolean   optional}
        {-regexpValue                  "regexp on variable value insted of variable name."                ""       boolean   optional}
}







