set file_path /mrvl2g/dc5purecl01_s_t106a0_wa_004/t106a0/t106a0/wa_004/nightly/nightly_hs_rundirs/fc_106____20210413_123959/rr
set templist ""
echo "" > dch
echo "" > diode
echo "" > BP
set infile   [open $file_path r]
while {[gets $infile line] >= 0}  {

    if {[ regexp {([^\s]*)(\s*)([^\s]*)(\s*)([^\s]*)(\s*)} $line -> pin sp0 rc sp1 ac ]} { 
#echo $pin
#echo $ac
        if {[regexp {dch} $pin]} {
            echo "[get_object_name [get_nets -of $pin]],[expr $ac * 1.1],lioral,Connection to tie cell was approved not to be fixed by BB: MAX tran violations inside DSS Tue 4/13/2021 5:35 PM $pin" >> dch
        } elseif {[regexp {DIO} $pin]} {
            echo "[get_object_name [get_nets -of $pin]],[expr $ac * 1.1],lioral,Connection to diode have no timing $pin" >> diode
        } elseif {[regexp {BP} $pin]} {
            echo "[get_object_name [get_nets -of $pin]],[expr $ac * 1.1],lioral,Connection to BUMP $pin" >> BP
        } else { 
            echo "[get_object_name [get_nets -of $pin]],[expr $ac * 1.1],lioral,TBD $pin" >> others 
        }
    }

    lappend templist $line;
}
close $infile;



