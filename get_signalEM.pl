#!/usr/bin/perl


$file = $ARGV[0] ;

open ( IN ,"<" , $file ) or die "Can not open file $file";
while (<IN>) {
    $line = $_ ;
    if ($line =~ /^#/) {
        next ;
    }
    if ($line =~ /^NET/) {
        @net = split(" ",$line);
            $foo = <IN>;
            $foo = <IN>;
            $foo = <IN>;
        while (<IN>) {
            $value = $_ ;
            @values = split(" ",$value);
            if ( $values[0] >= 1 ) {
                #print "$value";
             #   $value = /\s+(M\d+)\s+\(\s+(\d+.\d+)\s+(\d+.\d+)\s+(\d+.\d+)\s+(\d+.\d+)\s+\)\s+/;
                $value = /\s+(M\d+)\s+\((\s+\d+.\d+|\d+.\d+)\s+(\d+.\d+)\s+(\d+.\d+)\s+(\d+.\d+)\)\s+/;
                #print "$1 $2 $3 $4 $5\n"
                print "create_marker -bbox {$2 $3 $4 $5} -layer $1 -description {Signal EM violation for net $net[1]} \n";
            } else {
                last ;
            }
        } 
     }
}
close (IN);
