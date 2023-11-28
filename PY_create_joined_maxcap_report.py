#! /usr/local/bin/perl -sw 
######################################################################

use lib '/proj/ccpd01/extvols/wa_003/seyal/perseus_sta/sum';

use File::Find;
use File::Copy;
use Getopt::Long;
#Getopt::Long::Configure ("bundling_override");
use Pod::Usage;
use IO::File;
use Switch;
use Text::Table;

# Globals and defaults values:
my $printon = 0;
my ($help ,$OutFileName);
$OutFileName = 'max_cap.rpt';
GetOptions(	'help|?' => \$help,
		'o|out=s' => \$OutFileName,
		"print" => \$printon
		) or pod2usage(0);

pod2usage(verbose => 2 ) if $help;
pod2usage(msg => "No file given. For help use: create_joined_maxcap_report.pl --help\n" ,verbose => 2 ) if ((@ARGV < 1 ) && (-t STDIN));

################### Print Parameters ###################

#   [-path_type format]    (Format for path report: 
#                           Values: full, full_clock, short, end, 
#                           summary, full_clock_expanded)

#########################################################
#  ## If no arguments were given, then allow STDIN to be used only
# ## if it's not connected to a termina	l (otherwise print usage)
################### Open input & output files
if (-e $OutFileName && -r $OutFileName) {
	unlink $OutFileName;
}

our %DB = () ;
our %Local_DB = () ;

################### 
foreach my $MaxCapReportFileNname (<@ARGV>) {
	print "Reading maxcap report $MaxCapReportFileNname ...\n";
	my @MaxCapReport = read_file($MaxCapReportFileNname);
	print "Analyse report...\n";
	
	my $index = 0 ;
	
	%Local_DB = () ;
	
	my $in_rpt = 0;
	foreach my $line (@MaxCapReport) {
		#print $line ;
		chomp($line);
		
		if ($line =~ /---    -----   ----- -------/) {
		    print "$line\n" if $printon;
		    $in_rpt = $index + 1;
		}
		if ($in_rpt > 0 && $index >= $in_rpt && (length($line) > 1)) {
			#my @split_line = split (/\s+/,$line);
			my @split_line = split (/[\s+\(\)]/,$line);
			@split_line = split(" ",join(" ",@split_line));
			
			my $pin = $split_line[0];
			my $required =  $split_line[2];
			my $actual = $split_line[1];
			my $slack = $split_line[3];
			$Local_DB{$pin}{"required"} = $required;
			$Local_DB{$pin}{"actual"} = $actual;
			$Local_DB{$pin}{"slack"} = $slack;
			$Local_DB{$pin}{"report_file"} = $MaxCapReportFileNname;
			#$driver = $driver."   ";
			#$driver_type = $cell_split[2];
			my $len = length($line);
			print "$len , line=${line}\n" if $printon;
			print "split_line=@split_line\n" if $printon;
			print "pin=$pin required=$required actual=$actual slack=$slack\n" if $printon;
		}
		
	    $index = $index + 1;	

		
	}
	# When reached to EOF update %DB with %LOCAL_DB
	UpdateMaxCapDB();	
	
}


#print "\n";
my $tb ;
my @pins_violatios_sort = sort { $DB{$a}{"slack"} <=> $DB{$b}{"slack"} } keys %DB ;
my $index = 1 ;

$tb = Text::Table->new(
	{title=>"Pin",align=>"left",align_title => "left"},
	{title=>"Required",align=>"left",align_title => "left"},
	{title=>"Actual",align=>'left',align_title => "left"},
	{title=>"Slack",align=>'left',align_title => "left"},
	{title=>"Report_File",align=>"left",align_title => "left"}
);

foreach my $pin ( @pins_violatios_sort )  {
    my $required = $DB{$pin}{"required"};
    my $actual = $DB{$pin}{"actual"};
    my $slack = $DB{$pin}{"slack"};
    my $report_file = $DB{$pin}{"report_file"};
    $tb->add($pin,$required,$actual,$slack,$report_file);
    $index = $index + 1;	
}	

open(INFOut, ">$OutFileName") or die("Error, cannot open file: $OutFileName\n");
print "Saving max cap report to $OutFileName\n\n";
print INFOut "Joined max cap report : \n\n";
print INFOut $tb;
close(INFOut);

exit(1);

#####################################################################
# Function: $Match = GetPattern($SearchStr,$Pattern)
sub UpdateMaxCapDB {
    foreach my $pin (keys %{Local_DB}) {
	print "Update global DB pin : $pin \n" if $printon;
	if (exists $DB{$pin}) {
	    if ($Local_DB{$pin}{"slack"} < $DB{$pin}{"slack"} ) {
		$DB{$pin} = $Local_DB{$pin} ;
	    }
	} else {
	    $DB{$pin} = $Local_DB{$pin} ;
	}
    }
}


sub make_table {
    my ( $headers, $rows ) = @_;
    my @rule      = qw(- +);
    my @headers   = \'| ';
    push @headers => map { $_ => \' | ' } @$headers;
    pop  @headers;
    push @headers => \' |';

    unless ('ARRAY' eq ref $rows
        && 'ARRAY' eq ref $rows->[0]
        && @$headers == @{ $rows->[0] }) {
       # print(
       #     "make_table() rows must be an AoA with rows being same size as headers\n\n"
       # );
    }
    my $table = Text::Table->new(@headers);
    $table->rule(@rule);
    $table->body_rule(@rule);
    $table->load(@$rows);

    return $table->rule(@rule),
           $table->title,
           $table->rule(@rule),
           map({ $table->body($_) } 0 .. @$rows),
           $table->rule(@rule);
}


sub GetPattern {
	my $SearchStr = shift;
	my $Pattern = shift;
	
	#print "Searching for: $Pattern \n";
	
	
	if ($SearchStr =~ m/$Pattern/gs) {
		return $&;
	}
	print "Didn't Find anything for $Pattern\n";
	exit;
	return undef;
}
#####################################################################
# Function: $Match = GetPatternNoExit($SearchStr,$Pattern)
sub GetPatternNoExit {
	my $SearchStr = shift;
	my $Pattern = shift;
	
	#print "Searching for: $Pattern \n";
	
	
	if ($SearchStr =~ m/$Pattern/gs) {
		return $&;
	}
	print "Didn't Find anything for $Pattern\n" if $printon;

	return undef;
}
#####################################################################
# Function: $Match = GetFirstPattern($SearchStr,$Pattern)
sub GetFirstPattern {
	my $SearchStr = shift;
	my $Pattern = shift;
	
	#print "Searching for: $Pattern \n";
	if ($SearchStr =~ m/($Pattern)/s) {
		return $1;
	}
	print "Didn't Find anything for $Pattern\n";
	exit;
	return undef;
}
#####################################################################
# Function: $Match = GetFirstPatternNoExit($SearchStr,$Pattern)
sub GetFirstPatternNoExit {
	my $SearchStr = shift;
	my $Pattern = shift;
	
	#print "Searching for: $Pattern \n";
	
	
	if ($SearchStr =~ m/($Pattern)/s) {
		return $1;
	}
	print "Didn't Find anything for $Pattern\n" if $printon;
	return undef;
}
#####################################################################
# Function: $Match = GetAfterPattern($SearchStr,$Pattern)
sub GetAfterPattern {
	my $SearchStr = shift;
	my $Pattern = shift;
	
	#print "Searching for: $Pattern \n";
	
	
	if ($SearchStr =~ m/$Pattern/s) {
		return $' ;
	}
	print "Didn't Find anything for $Pattern\n";
	exit;
	return undef;
}
#####################################################################
# Function: $Match = GetBeforePattern($SearchStr,$Pattern)
sub GetBeforePattern {
	my $SearchStr = shift;
	my $Pattern = shift;
	
	#print "Searching for: $Pattern \n";
	
	
	if ($SearchStr =~ m/$Pattern/s) {
		return $` ;
	}
	print "Didn't Find anything for $Pattern\n";
	exit;
	return undef;
}
#####################################################################
sub GetBeforePatternNoExit {
	my $SearchStr = shift;
	my $Pattern = shift;
	
	#print "Searching for: $Pattern \n";
	
	
	if ($SearchStr =~ m/$Pattern/s) {
		return $` ;
	}
	print "Didn't Find anything for $Pattern\n" if $printon;
	return undef;
}
#####################################################################
# Function: $Match = ReplacePattern($SearchStr,$Pattern,$Replacement)
sub ReplacePattern {
	my $SearchStr = shift;
	my $Pattern = shift;
	my $Replacement = shift;
	
	#print "Searching for: $Pattern and replace with $Replacement\n";
	if ($SearchStr =~ s/$Pattern/$Replacement/gs) {
		return $SearchStr;
	}
	print "Didn't Find anything\n";
	exit;
	return undef;
}
#####################################################################
# Function: #String = str_replace($replace_this,$with_this,$string)
#Replace a string without using RegExp.
sub str_replace
{
	my $search = shift;
	my $replace = shift;
	my $subject = shift;
	if (! defined $subject) { return -1; }
	my $count = shift;
	if (! defined $count) { $count = -1; }
	
	my ($i,$pos) = (0,0);
	while ( (my $idx = index( $subject, $search, $pos )) != -1 )
	{
		substr( $subject, $idx, length($search) ) = $replace;
		$pos=$idx+length($replace);
		if ($count>0 && ++$i>=$count) { last; }
	}
	
	return $subject;
}
######################################################################
# Function: @FileList = read_file(FileName)The script read the verplex Non-equivalent points report which generated by :
#report compare data -class NONEQ .
#After reading, The script will analyze the report and will comapre is to the given verilog netlist for finding
#the non-equivalent modules.
sub read_file {
	my $FileName = shift;
	my @FileList = undef;
	if (-e $FileName && -r $FileName) {
	    if ($FileName =~ /.gz$/) {
		open(INFO, "gunzip -c $FileName |") || die("Error, cannot open file: $FileName\n");
	    } else {
		open(INFO, $FileName) or die("Error, cannot open file: $FileName\n");
	    }
	    @FileList = <INFO>;
	    close(INFO);
	}
	return @FileList;
}


1;

# "NAME|SYNOPSIS|DESCRIPTION|OPTIONS|AUTHORS" 

		
__END__

=pod

=head1 NAME

The script read primetime max capacitance reports and create a joined report.
The script can read several primetime reports.

=head1 SYNOPSIS

create_joined_maxcap_report.pl [PrimeTime Max Capacitance report] -o <OutputFileName>

=head1 DESCRIPTION


=head1 OPTIONS

=over 4

=item B<--help>

Print help screen.

=item B<--out -o [OutputFileName]>

The joined report filename. Shorted by maxcap violation.

=item B<--percent >

Sort report by percent, otherwise (default) sort by slack .

=item B<--file >

Add to summary the most violation report file name.

=item B<--print>

Enter debug mode.

=back

=head1 AUTHORS

Eyal Sarfati <seyal@marvell.com>

=cut
