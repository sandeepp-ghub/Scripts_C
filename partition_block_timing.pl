#!/usr/bin/perl

#$dirs = `pwd`;
#@dir = split("/",$mydir);
#$block = $dir[-2] ;
#$block =~ s/.PNR\d+//;
$block = $ARGV[0] ;
$rpt_dir = $ARGV[1] ;
if ( $rpt_dir == "" ) {
    $rpt_dir  = reports ;
}

print "BLOCK : $block\n";
@func_scen = ("func_max1" , "func_max10" , "func_max12" , "func_max13" , "func_max3" , "func_max4" , "func_max9" , "func_min1" , "func_min11" , "func_min12" , "func_min13" , "func_min15" , "func_min2" , "func_min5" , "func_min6" , "func_min9");
@shift_scen = ("scan_shift_max1" , "scan_shift_max10" , "scan_shift_max12" , "scan_shift_max13" , "scan_shift_max3" , "scan_shift_max4" , "scan_shift_max9" , "scan_shift_min1" , "scan_shift_min11" , "scan_shift_min12" , "scan_shift_min13" , "scan_shift_min15" , "scan_shift_min2" , "scan_shift_min5" , "scan_shift_min6" , "scan_shift_min9");
@atspeed_scen = ("scan_atspeed_max1" , "scan_atspeed_max10" , "scan_atspeed_max12" , "scan_atspeed_max13" , "scan_atspeed_max3" , "scan_atspeed_max4" , "scan_atspeed_max9" , "scan_atspeed_min1" , "scan_atspeed_min11" , "scan_atspeed_min12" , "scan_atspeed_min13" , "scan_atspeed_min15" , "scan_atspeed_min2" , "scan_atspeed_min5" , "scan_atspeed_min6" , "scan_atspeed_min9");
@atspeed_scen_intest = ("scan_atspeed_intest_max1" , "scan_atspeed_intest_max10" , "scan_atspeed_intest_max12" , "scan_atspeed_intest_max13" , "scan_atspeed_intest_max3" , "scan_atspeed_intest_max4" , "scan_atspeed_intest_max9" , "scan_atspeed_intest_min1" , "scan_atspeed_intest_min11" , "scan_atspeed_intest_min12" , "scan_atspeed_intest_min13" , "scan_atspeed_intest_min15" , "scan_atspeed_intest_min2" , "scan_atspeed_intest_min5" , "scan_atspeed_intest_min6" , "scan_atspeed_intest_min9");
@atspeed_scen_extest = ("scan_atspeed_extest_max1" , "scan_atspeed_extest_max10" , "scan_atspeed_extest_max12" , "scan_atspeed_extest_max13" , "scan_atspeed_extest_max3" , "scan_atspeed_extest_max4" , "scan_atspeed_extest_max9" , "scan_atspeed_extest_min1" , "scan_atspeed_extest_min11" , "scan_atspeed_extest_min12" , "scan_atspeed_extest_min13" , "scan_atspeed_extest_min15" , "scan_atspeed_extest_min2" , "scan_atspeed_extest_min5" , "scan_atspeed_extest_min6" , "scan_atspeed_extest_min9");
@stuck_at_scen = ("scan_stuckat_max1" , "scan_stuckat_max10" , "scan_stuckat_max12" , "scan_stuckat_max13" , "scan_stuckat_max3" , "scan_stuckat_max4" , "scan_stuckat_max9" , "scan_stuckat_min1" , "scan_stuckat_min11" , "scan_stuckat_min12" , "scan_stuckat_min13" , "scan_stuckat_min15" , "scan_stuckat_min2" , "scan_stuckat_min5" , "scan_stuckat_min6" , "scan_stuckat_min9");
@stuck_at_scen_intest = ("scan_stuckat_intest_max1" , "scan_stuckat_intest_max10" , "scan_stuckat_intest_max12" , "scan_stuckat_intest_max13" , "scan_stuckat_intest_max3" , "scan_stuckat_intest_max4" , "scan_stuckat_intest_max9" , "scan_stuckat_intest_min1" , "scan_stuckat_intest_min11" , "scan_stuckat_intest_min12" , "scan_stuckat_intest_min13" , "scan_stuckat_intest_min15" , "scan_stuckat_intest_min2" , "scan_stuckat_intest_min5" , "scan_stuckat_intest_min6" , "scan_stuckat_intest_min9");
@stuck_at_scen_extest = ("scan_stuckat_extest_max1" , "scan_stuckat_extest_max10" , "scan_stuckat_extest_max12" , "scan_stuckat_extest_max13" , "scan_stuckat_extest_max3" , "scan_stuckat_extest_max4" , "scan_stuckat_extest_max9" , "scan_stuckat_extest_min1" , "scan_stuckat_extest_min11" , "scan_stuckat_extest_min12" , "scan_stuckat_extest_min13" , "scan_stuckat_extest_min15" , "scan_stuckat_extest_min2" , "scan_stuckat_extest_min5" , "scan_stuckat_extest_min6" , "scan_stuckat_extest_min9");
#@scenarios = ("func_max1", "func_max3", "scan_atspeed_max1" , "scan_atspeed_max1", "scan_shift_min1" ,"func_min1" ,"func_min2", "func_min6" );
@scenarios = "" ;
@modes = ("func","scan_shift","scan_atspeed","scan_stuckat");
foreach $mode (@modes) {
    foreach $del ("max","min") {
        foreach $num (1..16) {
            if ( $mode =~ /scan_stuckat/ || $mode =~ /scan_atspeed/ ) { 
                push @scenarios, "${mode}_${del}${num}";
                foreach $test ("extest","intest") {
                    push @scenarios, "${mode}_${test}_${del}${num}" ;
                    foreach $com ("cmp","byp") {
                        push @scenarios, "${mode}_${test}_${com}_${del}${num}" ;
                    }
                }
            } else {
                push @scenarios, "${mode}_${del}${num}";
            }
        }
   }
}
#push @scenarios, @func_scen ;
#push @scenarios, @shift_scen ;
#push @scenarios, @atspeed_scen ;
#push @scenarios, @stuck_at_scen ;
#push @scenarios, @atspeed_scen_intest ;
#push @scenarios, @atspeed_scen_extest ;
#push @scenarios, @stuck_at_scen_intest ;
#push @scenarios, @stuck_at_scen_extest ;
#    @dirs = @ARGV ;
#foreach $top_dir ($dirs) {
$top_dir = `pwd`;
chomp($top_dir);
@adir = split("/",$top_dir);
$dir = pop @adir ;
if ( $dir =~ /^iocx/ || $dir =~ /^cpt/ ) {
    $hier = "";
}
if ( $dir =~ /^roc/ ) {
    $hier = "iocx/";
}
if ( $dir =~ /^roc/  && $block =~ /^cpt/) {
    $hier = "cpt/";
}
if ( $dir =~ /^fc/ ) {
    
    $hier = "roc/iocx/";
    if ( $block =~ /^cpt/) {
    $hier = "roc/cpt/";
    }
}
    if ( -d $top_dir ) {
    print "\nPartiton timing from : $top_dir\n\n";
    printf "%42s                             | %14s \n",ITERNAL,INTERFACE;
    printf "-----------------------------------------------------------------------------------------------------------------------------------------\n";
    printf "%-30s| %14s %14s %10s | %14s %14s %10s | %10s %10s %10s %10s \n",Scenario,WNS,TNS,FEP,WNS,TNS,FEP,Max_Trans,Max_Cap,Min_period,Min_pulse_width;
        foreach (@scenarios) {
            $scen = $_ ;
            $file = "${top_dir}/${rpt_dir}/split_rpt/${scen}/hierarchical_full/${hier}SUMMARY.gz" ;
            $trans = "${top_dir}/${rpt_dir}/split_rpt/${scen}/trans_constraint/${hier}SUMMARY.trans.gz" ;
            $cap = "${top_dir}/${rpt_dir}/split_rpt/${scen}/cap_constraint/${hier}SUMMARY.cap.gz" ;
            $min_period = "${top_dir}/${rpt_dir}/split_rpt/${scen}/period_constraint/${hier}SUMMARY.period.gz" ;
            #print "min_period : $min_period\n";
            $pulse_width = "${top_dir}/${rpt_dir}/split_rpt/${scen}/pulse_constraint/${hier}SUMMARY.pulse.gz" ;
            if ( -e $file ) {
                $data = `zcat $file | grep "${block}-internal" `;
                $dataf = `zcat $file | grep "${block}-interface" `;
                chomp($data);
                chomp($dataf);
                @pall = split(" ",$data);
                @pallf = split(" ",$dataf);
                $tns = $pall[1] ;    
                $wns = $pall[2] ;    
                $fep = $pall[3] ;    
                $tnsf = $pallf[1] ;    
                $wnsf = $pallf[2] ;    
                $fepf = $pallf[3] ;    
            } else {
                $tns = "NA";
                $wns = "NA";
                $fep = "NA";
                $tnsf = "NA";
                $wnsf = "NA";
                $fepf = "NA";
            }
            @cons = ("trans","cap","period","pulse");
            foreach (@cons) {
                $c = $_ ;
                $cfile = "${top_dir}/${rpt_dir}/split_rpt/${scen}/${c}_constraint/SUMMARY.${c}.gz";
                if ( -e $cfile ) {
                    $cnt = `zcat $cfile | grep "${block}" | awk '{print \$4}'`;
                    chomp($cnt);
                } else {
                    $cnt = "NA";
                }
                   push @result,$cnt; 
            }
            if ( -e $file ) {
                printf "%-30s| %14s %14s %10s | %14s %14s %10s | %10s %10s %10s %10s\n",$scen,$wns,$tns,$fep,$wnsf,$tnsf,$fepf,$result[0],$result[1],$result[2],$result[3];
                undef @result  ;
            }
        }
    } else {
            print "Directory $top_dir does not exists."
    }
print "\n\n";
#}
