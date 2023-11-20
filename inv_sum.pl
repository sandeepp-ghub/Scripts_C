

$file = $ARGV[0] ;


$head = `zcat $file | grep -e "Setup mode" -e "Hold mode"`;
@ahead = split ('\|' , $head);

$wns = `zcat $file | grep "WNS"`;
@awns = split('\|' , $wns);

$tns = `zcat $file | grep "TNS"`;
@atns = split('\|' , $tns);

$fep = `zcat $file | grep "Violating Paths"`;
@afep = split('\|' , $fep);

#print "@ahead\n";
#print "@awns\n";
#print "@atns\n";
#print "@afep\n";
$i = 1 ;
foreach $l (@ahead) {
    $awns[$i] =~ s/ //g;
    $atns[$i] =~ s/ //g;
    $afep[$i] =~ s/ //g;
    printf "%-50s %-10s %-10s %-10s \n", $ahead[$i],$awns[$i],$atns[$i],$afep[$i];
    $i = $i +1 ;
}
