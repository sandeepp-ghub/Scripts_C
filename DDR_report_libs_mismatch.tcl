
regexp {(m(in|ax)\d+)} $run_type_specific -> corner

set RLM(max1)  "ssgnp0p675v0c_cworst_CCworst"
set RLM(max2)  "ssgnp0p675v125c_cworst_CCworst"
set RLM(max3)  "ssgnp0p675vn40c_cworst_CCworst"
set RLM(max4)  "ssgnp0p765v125c_cworst_CCworst"
set RLM(max5)  "ssgnp0p765vn40c_cworst_CCworst"
set RLM(max6)  "ssgnp0p765v125c_cworst_CCworst"
set RLM(max7)  "tt0p75v25c_typical"
set RLM(max8)  "tt0p75v25c_typical"
set RLM(max9)  "tt0p75v25c_typical"
set RLM(max10) "tt0p75v25c_typical"
set RLM(max11) "ssgnp0p765v0c_cworst_CCworst"
set RLM(max12) "ssgnp0p765v125c_cworst_CCworst"
set RLM(max13) "ssgnp0p675vn40c_cworst_CCworst"
set RLM(max14) "ssgnp0p675v125c_cworst_CCworst"
set RLM(max15) "ssgnp0p675vn40c_cworst_CCworst"
set RLM(max16) "ssgnp0p675v125c_cworst_CCworst"
set RLM(max17) "Not exists at iliad"

set RLM(min1)   "ffgnp0p935v125c_cbest_CCbest"
set RLM(min2)   "ffgnp0p935vn40c_cbest_CCbest"
set RLM(min3)   "ffgnp0p825v125c_cbest_CCbest"
set RLM(min4)   "ffgnp0p825vn40c_cbest_CCbest"
set RLM(min5)   "ssgnp0p675v125c_cworst_CCworst"
set RLM(min6)   "ssgnp0p675v0c_cworst_CCworst"
set RLM(min7)   "ssgnp0p765v125c_cworst_CCworst"
set RLM(min8)   "ssgnp0p765vn40c_cworst_CCworst"
set RLM(min9)   "tt0p75v25c_typical"
set RLM(min10)  "tt0p75v25c_typical"
set RLM(min11)  "tt0p75v25c_typical"
set RLM(min12)  "ffgnp0p825vn40c_cbest_CCbest"
set RLM(min13)  "ffgnp0p825v125c_cbest_CCbest"
set RLM(min14)  "ffgnp0p935vn40c_cbest_CCbest"
set RLM(min15)  "ffgnp0p935v125c_cbest_CCbest"
set RLM(min16)  "ffgnp0p935vn40c_cbest_CCbest"
set RLM(min17)  "ffgnp0p935vn40c_cbest_CCbest"


set ERROR 0
set OF  [open ${run_type_specific}_report_SNPS_libs_mismatch.rpt w]
redirect -variable libs {list_libs -only_used}
puts     "Info: Library related to dss_2ch"
puts $OF "Info: Library related to dss_2ch"
puts     "\n"
puts $OF "\n"
foreach lib $libs {
    if {[regexp {dwc} $lib]} {
        puts "Info: $lib"
        puts $OF "Info: $lib"
    }
}
puts     "\n"
puts $OF "\n"
# check if using power libs.
foreach lib $libs {
    if {[regexp {dwc} $lib]&&[regexp {\/} $lib]} {
        if {![regexp {dwc.+?vddvss} $lib]} {
            puts     "Error: The next lib is using lib view w/o power, vddvss $lib"
            puts $OF "Error: The next lib is using lib view w/o power, vddvss $lib"
            set ERROR 1
        }
    }
}
puts     "\n"
puts $OF "\n"

# check if using right pvt libs.

foreach lib $libs {
    if {[regexp {dwc} $lib]} {
        set exp_corner $RLM($corner)
        if {![regexp {/} $lib ] } {continue}
        if {[regexp {(DWC_DDRPHY_CLKTREE_REPEATER|DWC_DDRPHY_UTILITY_BLOCKS)} $lib ]} {
            regsub {_.+} $exp_corner {} exp_corner
        }
        if {![regexp $exp_corner $lib]} {
            puts      "Error: The next lib have a view mismatch for corner $corner expecting $exp_corner and getting: $lib"
            puts $OF  "Error: The next lib have a view mismatch for corner $corner expecting $exp_corner and getting: $lib"
             set ERROR 1
        }
    }
}
puts     "\n"
puts $OF "\n"

close $OF

if {$ERROR} {
    puts "Sending Email ...."   
    set subject        "Auto mail - Odysseys SNPS lib mapping is wrong"
    set recipient_list "lioral@marvell.com"
    set cc_list        "lioral@marvell.com"
    set body    "Hi You,\n \
\n\
This is an auto mail.\n\
If you are reading this someone touched the Odyssey lib mapping and now the SNPS lib mapping is wrong.\n\
Please look at $env(PWD)/${run_type_specific}_report_SNPS_libs_mismatch.rpt to see what went wrong.\n\
\n\
\nThanks,\
\n-Lioral's Bot."


set msg {From: dss_2ch_lib_mapping_check_bot}
append msg \n "To: " [join $recipient_list ,]
append msg \n "Cc: " [join $cc_list ,]
append msg \n "Subject: $subject"
append msg \n\n $body

exec /usr/lib/sendmail -oi -t << $msg
}


