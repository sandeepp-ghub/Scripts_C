

sub read_spef {
	@in = @_ ;
	$file = shift ;
	if ( $file =~ /\.gz$/) {
	open (IN , " zcat $file |") || die "Can't open file $file." ;
	} else {
	open (IN , " cat $file |") || die "Can't open file $file." ;
	}
	
	while (<IN>) {
		$line = $_ ;
		if ( $line =~ /^\*NAME_MAP/ ) {
			while ( <IN> ) {
				$line = $_ ;
				@l = split (" ", $line);
				if ( $l[0] ne "" && $l[1] ne "" ) {
				chomp($l[1]);
				$l[0] =~ s/\*//g;
				$name_map{$l[0]} = $l[1] ;
				}
				if ( $line =~ /^\*PORTS/ ) {
					last;
				}
			}	
		}
		if ( $line =~ /^\*D_NET/ ) {
			@l = split (" ", $line);
			chomp($l[2]);
			$l[1] =~ s/\*//g;
			if ( $l[1] ne "" && $l[2] ne "" ) {
			$value{$l[1]} = $l[2] ;
			}
		}
	}
	close IN;
	
	
	foreach $i ( keys %value ) {
		$tmp = $name_map{$i};
		$final{$tmp} = $value{$i};
	}
	return %final ;	
}

$spef1 = $ARGV[0] ;
$spef2 = $ARGV[1] ;
%out1 = read_spef("$spef1");
%out2 = read_spef("$spef2");
$total_rat = 0 ;
$count = 0 ;
foreach $i ( keys %out1 ) {
	$c1 = $out1{$i};
	$c2 = $out2{$i} / 1000 ;
	$diff = abs($c1-$c2);
	if ( $c2 > 0 && $c1 > 0) {
	$ratio = $c2 / $c1 ;
	$total_rat = $total_rat + $ratio ;
	$count++ ;
	}
	#printf "$i %.5f %5.f %.3f\n", $c1,$c2,$ratio;
}
$avg_rat = $total_rat / $count ;
printf "\nSample count : $count\tAvg ratio : %.4f\n", $avg_rat;
#foreach $i ( keys %out) {
#	print "$i ==> $out{$i}\n";
#}
