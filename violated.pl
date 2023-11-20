#!/usr/bin/perl
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
### *  Copyright 2019-2020, Marvell, Inc.  All rights reserved.            *
### *                                                                      *
### ************************************************************************
### * Author      : 
### * Description : 
### ************************************************************************

#
# Bertone 20080905 (bmenezes 20200309: ported to innovus/5nm)
#
# violated.pl [ --help ] [ --sort=[slack|pathgroup] ] [ report_file ]
#
# Reads a timing report file and produces both a summary of all violations
# and a summary of each worst violation per path group.

use warnings;
use strict;
use Getopt::Long;
use Data::Dumper;
#
# searchlist for the standard report files, listed in order of relevance


my @files = ('invcui.post.opt/report/*max1*.rpt*',
             'invcui.post.opt/report/*max2*.rpt*',
             'invcui.post.route/report/*max1*.rpt*',
             'invcui.post.route/report/*max2*.rpt*',
             'invcui.cts/report/*max1*.rpt*',
             'invcui.cts/report/*max2*.rpt*',
             'invcui.pre.place/report/*max1*.rpt*',
             'invcui.pre.place/report/*max2*.rpt*',
             'dc.syn/report/*timing*rpt*');

my $file = '';
my $path = './';

#
# parse the command line options
my %sortMap = ('slack'     => '0',
	       'pathgroup' => '1');

my $parseErrors = 0;
my $all = 0;
my $invcui_format = 0;
my $help = 0;
my $sort = 'slack';
my $verbose = 0;
my $full_verbose = 0;
my $gates = 0;
my $summary = 0;
my $threshold = 0.0;
my $scenario_list  = "all";


GetOptions(
       'i'       => \$invcui_format,
       'invcui'  => \$invcui_format,
	   'a'       => \$all,
	   'all'     => \$all,
	   'h'       => \$help,
	   'help'    => \$help,
	   'v'       => \$verbose,
	   'verbose' => \$verbose,
       'fv'      => \$full_verbose,
	   'full_verbose' => \$full_verbose,
       'gates'   => \$gates,
	   's'       => \$summary,
	   'summary' => \$summary,
	   'sort=s'  => \$sort,
	   'threshold=f'     => \$threshold,
       'scenario_list=s' => \$scenario_list,
       ) or die "Error parsing command line";

$threshold = 999.999 if ($all);

if ($help)
{
    usage();
    exit(0);
}


my @scenarios = ();
if ($scenario_list ne "all") {
    @scenarios = split("\\s*,\\s*",$scenario_list);
}

if (!exists($sortMap{$sort}))
{
    $parseErrors++;
    print "Illegal value \"$sort\" for option \"sort\"\n";
}

die if ($parseErrors);

if ($#ARGV >= 0)
{
    if ($ARGV[0] =~ m/\/$/)
    {
	$path = $ARGV[0];
    }
    else
    {
	$file = $ARGV[0];
    }
}

my @file_list;
if (!$file) {
    foreach my $file_list (@files) {
        @file_list = glob($path.$file_list);
        if ($#file_list >= 0) {
            last;
        }
    }
} else {
    # user specified file directly so use that
    if (!-f $file) {
        print "Error: User-specified file $file does not exists!\n";
        exit;
    }
    push(@file_list,$file);
}
    

my %worst_startpoint;
my %worst_endpoint;
my %worst_slack;
my %worst_slack_scenario;
my %worst_required;
my %worst_arrival;
my %worst_logic_gates;
my %worst_total_gates;
my %worst_skew;
my %worst_xtalkD;
my %worst_xtalkC;
my %file_timestamp;

foreach my $file (@file_list) {
    #
    # open the report file
    $file_timestamp{$file} = localtime((stat($file))[9]);

    die "cannot open any standard report file" if ($file eq '');

    if ($file =~ /\.gz$/)
        {
            open(FILE, "gzip -f -c -d ${file} |") or die "cannot open file \"$file\"";
        }
    else
        {
            open(FILE, $file) or die "cannot open file \"$file\"";
        }

    #
    # process the report file
    # - print a summary of all violations
    # - record the worst violation per path group
    my $scenario = "";
    my $startpoint = "";
    my $startpin = "";
    my $endpoint = "undefined endpoint";
    my $endpoint_for_match = "";
    my $endpin = "";
    my $pathgroup = "";
    my $slack = "";
    my $required = "";
    my $arrival = "";
    my $launchclock = "";
    my $datapath = "";
    my $logic_gates = 0;
    my $total_gates = 0;
    my $done = 0;
    my $inst_last = "";

    my $startPointXtalk = 0;
    my $endPointXtalk = 0;
    my $dataXtalk = 0;
    my $skew = 0;
    my $xtalkD = 0;# lioral
    my $xtalkC = 0;# lioral
    my $firstStartPointPrint = 1; 
    my $whereAmIInTheTimingPath = "STARTCLK" ;# lioral
    my $startClockDelay = 0;
    my $endClockDelay = 0;
    my $clockCycle = 0;
    my $pathgroupFMT =  "";
    my $scenarioFMT   = "";
    my $slackFMT      = "";
    my $requiredFMT   = "";
    my $arrivalFMT    = "";
    my $skewFMT       = "";
    my $xtalkDFMT     = "";
    my $xtalkCFMT     = "";
    my $logic_gatesFMT= "";


    my $file_scenario = $file;
    $file_scenario =~ s/.*(max\d*|min\d*).*/$1/;

    # process file only if not corner-specific (i.e. max) or ...
    #                          corner-specific (i.e. max3) and scenario was requested
    if($file_scenario =~ m/\d+/ && !requested_scenario($file_scenario)) {
        next;
    }
    
    if (!$summary){
        if($full_verbose){
            print "\nprocessing file \"$file\", generated on $file_timestamp{$file}\n\n";
            printf("All violations per pathgroup, slack < %0.3fns:\n", $threshold);
            printf("PATHGROUP, SCENARIO, SLACK  , %sSTARTPOINT -> ENDPOINT%s\n",
                   $full_verbose ? "REQUIRED, ARRIVAL, SKEW   , XTLK(D), XTLK(C), " : "",
                   $gates   ? ", LOGIC_GATES, TOTAL_GATES " : "");
        } else {
            #Backward compatibility header.
            print "\nprocessing file \"$file\", generated on $file_timestamp{$file}\n\n";
            printf("All violations per pathgroup, slack < %0.3fns:\n", $threshold);
            printf("PATHGROUP, SCENARIO, SLACK, %sSTARTPOINT -> ENDPOINT%s\n",
                   $verbose ? "REQUIRED, ARRIVAL, " : "",
                    $gates   ? ", LOGIC_GATES, TOTAL_GATES " : "");
        }
    }
    while (<FILE>)
        {
            $invcui_format = 1 if (m/^\s*\#\s+Generated\s+by\:\s+Cadence\s+Innovus.*/);
#-- collect noise .. start.
            if(m/(\)                    \s+[0-9\.\-]+\s+[0-9\.\-]+    )([\-]?[0-9\.]+)/) {
                if($whereAmIInTheTimingPath eq "DATA") {
                    $xtalkD += $2;
                } else {
                    $xtalkC += $2;
                }
            }
#-- collect noise .. end

	    if ($invcui_format) {
                if (m/^\s+Startpoint:\s+\([A-Z]\)\s+(\S+)/) {
		            $startpoint = $1; 
                    $startpoint =~ s/(\S+)\/\S+/$1/g;
		        }
                $startClockDelay = 0 if (m/^\s+Startpoint:\s+\([A-Z]\)\s+\S+/);
                $endClockDelay = 0   if (m/^\s+Startpoint:\s+\([A-Z]\)\s+\S+/);
                if (m/^\s+Endpoint:\s+\([A-Z]\)\s+(\S+)/) {
		            $endpoint   = $1;
                    $endpoint =~ s/(\S+)\/\S+/$1/g;
                    $endpoint_for_match = $endpoint; 
                    $endpoint_for_match =~ s/\[/\\[/g; 
                    $endpoint_for_match =~ s/\]/\\]/g;
		        }
                $pathgroup  = $1 if (m/^\s+Group: (\S+)/);
                $required   = $1 if (m/^\s+Required Time:\=\s+(\S+)/);
                $launchclock = $1 if (m/^\s+Launch Clock:\=\s+(\S+)/);             
                $slack       = $1 if (m/^\s+Slack:\=\s+(\S+)/);
                if (m/^\s+Data Path:\+\s+(\S+)/) {$datapath   = $1; $arrival = $launchclock + $datapath;}
            } else { #not invcui format
                $scenario   = $1 if (m/^  Scenario: (\S+)/);
                $startpoint = $1 if (m/^  Startpoint: (\S+)/);
                $startClockDelay = 0 if (m/^  Startpoint: (\S+)/);
                $endClockDelay = 0   if (m/^  Startpoint: (\S+)/);
                $endpoint   = $1 if (m/^  Endpoint: (\S+)/);
                $pathgroup  = $1 if (m/^  Path Group: (\S+)/);
                $required   = $1 if (m/^  data required time\s+(\S+)/);
                $arrival    = $1 if (m/^  data arrival time\s+-(\S+)/);
	    }




            # don't process clock path
            if(((m/^\s+$endpoint_for_match\s+\-/ || m/^\s+Other End Path:/) && !$done && $invcui_format) || (m/^  data arrival time/)) {
                $done = 1;
            }

            #-- take clock network delay in case this is an i/o/io path. if reg exists. real clock delay will override this value. 
            if(!$done && m/(clock network delay\D*)([\d\.\-]+)/) {
                $startClockDelay = $2;
            }             
            if($done  && m/(clock network delay\D*)([\d\.\-]+)/) {
                $endClockDelay = $2;
            }             
            #--

            if(!$done && $startpoint && m/^\s+$startpoint\/(\S+)/ && $invcui_format) {
                $startpin = "/$1";
                if($firstStartPointPrint) { 
                   $firstStartPointPrint = 0;
                   m/([0-9\.\-]*)\s+[RF]\s+/;
                   $whereAmIInTheTimingPath = "DATA";
                   $startClockDelay = $1;
                }
            } elsif (!$done && $startpoint && m/$startpoint\/(\S+)/ && !$invcui_format ) {
                $startpin = "/$1";
                if($firstStartPointPrint) {
                   $firstStartPointPrint = 0;
                   m/([0-9\.\-]*)( [rf][ \n])/;# lioral
                   $whereAmIInTheTimingPath = "DATA";
                   $startClockDelay = $1;#lioral                   
                }
            }

            if(!$done && $endpoint && m/^\s+$endpoint\/(\S+)/ && $invcui_format) {
                $endpin = "/$1";
                $whereAmIInTheTimingPath = "ENDCLK";
            } elsif(!$done && $endpoint && m/$endpoint\/(\S+)/ && !$invcui_format) {
                $endpin = "/$1";
                m/([0-9\.\-]*)( [rf][ \n])/;#lioral
                $whereAmIInTheTimingPath = "ENDCLK";
            }
            
             if($done && $endpoint && m/$endpoint\/(\S+)/ && $invcui_format) {
                m/([0-9\.\-]+)\s+[RF]\s+\([0-9\.,\-]+\)\s+[\-][\s+\n]/;
                $endClockDelay = $1;
                $whereAmIInTheTimingPath = "STARTCLK";
            } elsif ($done && $endpoint && m/$endpoint\/(\S+)/ && !$invcui_format) {
                m/([0-9\.\-]*)( [rf][ \n])/;#lioral
                $endClockDelay = $1;#lioral
                $whereAmIInTheTimingPath = "STARTCLK";
            }

            #-- get clock cycle to remove from skew.
            if($done && m/\(arrival\)\s+\d+\s+[0-9\.]+\s+[0-9\.]+\s+[0-9\.\-]+\s+[0-9\.\-]+\s+[0-9\.\-]+\s+([0-9\.]+)/ && $invcui_format) {
                $clockCycle = $1;
            } elsif ($done && m/clock [a-zA-Z0-9_\[\]\\]+ \((rise|fall) edge\)\s+([0-9\.]+)/ && !$invcui_format) {
                $clockCycle = $2;
            }

            if(m/(\S+)\/(\S+)\s+(\S\S\S)\S+\s+/ && !$done && $invcui_format && $startpoint) {
                my $inst = $1;
                my $pin = $2;
                my $gate = $3;
                print "Debug : gate : $gate\n" ;
                # ignore start/end flop, ignore smscts clock buffering, and only count one line per instance
                if ($gate !~ m/^CK/ && $gate !~ m/SDF|LHQ/ && $pin !~ m/CLK|EN|D|din/ && ($inst ne $inst_last) ) {
                    #print "### ($inst)($gate)($pin)\n";
                    $total_gates++;
                    if ($gate !~ m/BUF/ && $gate !~ m/INV/ && $gate !~ m/DLY/) {
                        $logic_gates++;
                    }
                }
                $inst_last = $inst;
            } elsif (m/(\S+)\/(\S+)\s+\((\S\S\S)\S+\)/ && !$done && !$invcui_format) {
                my $inst = $1;
                my $pin = $2;
                my $gate = $3;
                # ignore start/end flop, ignore smscts clock buffering, and only count one line per instance
                if ($gate !~ m/^CK|^DCC/ && $gate !~ m/SDF|LHQ/ && $pin !~ m/CLK|EN|D|din/ && ($inst ne $inst_last) ) {
                    #print "### ($inst)($gate)($pin)\n";
                    $total_gates++;
                    if ($gate !~ m/BUF/ && $gate !~ m/INV/ && $gate !~ m/DLY/) {
                        $logic_gates++;
                    }
                }
                $inst_last = $inst;
            }

            if ( ((m/^  slack \(VIOLATED\)\s+(\S+)/ or (m/^  slack \(MET\)\s+(\S+)/)) && !$invcui_format) || (($done && $slack) && $invcui_format) )
                {
# lioral add skew calc
                    $skew = $endClockDelay - $startClockDelay - $clockCycle;
#                   printf("DBG:: startpoint $startpoint\n");
#                   printf("DBG:: endpoint $endpoint\n");
#                   printf("DBG:: startClockDelay $startClockDelay \n");
#                   printf("DBG:: endClockDelay $endClockDelay \n");
#                   printf("DBG:: clockCycle $clockCycle \n");
                    $skew = sprintf("%.3f", $skew);

                    $slack = $1 if(!$invcui_format);

                    $required = " " . $required if ($required =~ m/^[0-9]/);
                    $arrival  = " " . $arrival  if ($arrival  =~ m/^[0-9]/);
                    $slack    = " " . $slack    if ($slack    =~ m/^[0-9]/);
                    
                    if ($all or ($slack < $threshold))
                        {
                            if ($scenario !~ m/\S+/) {
                                # DC doesn't have scenario info
                                $scenario = "default";
                            }

                            # only print info if scenario is requested
                            if (requested_scenario($scenario)) {
                               if($full_verbose){ 
                                    # format stuff abit.
                                    $pathgroupFMT   = sprintf("%-*s" ,9,$pathgroup );
                                    $scenarioFMT    = sprintf("%-*s" ,8,$scenario  );
                                    $slackFMT       = sprintf("%-*s" ,7,$slack     );
                                    $requiredFMT    = sprintf("%-*s" ,8,$required );
                                    $arrivalFMT     = sprintf("%-*s" ,7,$arrival );
                                    $skewFMT        = sprintf("%-*s" ,7,$skew );
                                    $xtalkDFMT      = sprintf("%-*s" ,7,$xtalkD );
                                    $xtalkCFMT      = sprintf("%-*s" ,7,$xtalkC );
                                    $logic_gatesFMT = sprintf("%-*s" ,10,$logic_gates );
                                    # format stuff end ...
                               }

                                if($full_verbose){
                                    printf("$pathgroupFMT, $scenarioFMT, $slackFMT, %s$startpoint$startpin -> $endpoint$endpin%s\n",
                                            $full_verbose ? "$requiredFMT, $arrivalFMT, $skewFMT, $xtalkDFMT, $xtalkCFMT, " : "",
                                            $gates   ? ", $logic_gatesFMT, $total_gates" : "")
                                            if (!$summary);
                                } else{
                                     #Backward compatibility header.
                                     printf("$pathgroup, $scenario, $slack, %s$startpoint$startpin -> $endpoint$endpin%s\n",
                                             $verbose ? "$required, $arrival, " : "",
                                             $gates   ? ", $logic_gates, $total_gates" : "")
                                             if (!$summary);
                                }
                            
                                if (!exists $worst_slack{$scenario}{$pathgroup} || ($slack < $worst_slack{$scenario}{$pathgroup}))
                                    {
                                        $worst_startpoint{$scenario}{$pathgroup} = "$startpoint$startpin";
                                        $worst_endpoint{$scenario}{$pathgroup}   = "$endpoint$endpin";
                                        $worst_slack{$scenario}{$pathgroup}      = $slack;
                                        $worst_required{$scenario}{$pathgroup}   = $required;
                                        $worst_arrival{$scenario}{$pathgroup}    = $arrival;
                                        $worst_logic_gates{$scenario}{$pathgroup} = $logic_gates;
                                        $worst_total_gates{$scenario}{$pathgroup} = $total_gates;
                                        $worst_skew{$scenario}{$pathgroup} = $skew;
                                        $worst_xtalkD{$scenario}{$pathgroup} = $xtalkD;
                                        $worst_xtalkC{$scenario}{$pathgroup} = $xtalkC;
                                    }
                            }
                        }
                    $logic_gates = 0;
                    $total_gates = 0;
                    $done = 0;
                    $inst_last = "";
                    $startpin = "";
                    $endpin = "";
                    $firstStartPointPrint =1;
                    $whereAmIInTheTimingPath = "startPointClock" ;# lioral
                    $skew = 0;
                    $xtalkD = 0;
                    $xtalkC = 0;
                    $clockCycle = 0;

                }
        }
    print "\nprocessed file \"$file\", generated on $file_timestamp{$file}\n";
}


#
# close the report file
close FILE;


#
# print a summary of each worst violation per path group
my $pathgroup_length  = length("PATHGROUP");
my $scenario_length     = length("SCENARIO");
my $required_length   = length("REQUIRED");
my $arrival_length    = length("ARRIVAL");
my $slack_length      = length("SLACK");
my $startpoint_length = length("STARTPOINT");
my $endpoint_length   = length("ENDPOINT");
my $logic_gates_length = length("LOGIC_GATES");
my $total_gates_length = length("TOTAL_GATES");

foreach my $scenario (keys %{worst_slack})
{
    if (requested_scenario($scenario)) {
        foreach my $pathgroup (keys %{$worst_slack{$scenario}})
        {
            $pathgroup_length  = MAX($pathgroup_length,  length($pathgroup));
            $scenario_length     = MAX($scenario_length,     length($scenario));
            $required_length   = MAX($required_length,   length($worst_required{$scenario}{$pathgroup}));
            $arrival_length    = MAX($arrival_length,    length($worst_arrival{$scenario}{$pathgroup}));
            $arrival_length    = MAX($arrival_length,    length($worst_skew{$scenario}{$pathgroup}));
            $arrival_length    = MAX($arrival_length,    length($worst_xtalkD{$scenario}{$pathgroup}));
            $arrival_length    = MAX($arrival_length,    length($worst_xtalkC{$scenario}{$pathgroup}));
            $slack_length      = MAX($slack_length,      length($worst_slack{$scenario}{$pathgroup}));
            $startpoint_length = MAX($startpoint_length, length($worst_startpoint{$scenario}{$pathgroup}));
            $endpoint_length   = MAX($endpoint_length,   length($worst_endpoint{$scenario}{$pathgroup}));
        }
    }
}

my $sortType = $sortMap{$sort};
printf("\nWorst violation per pathgroup, slack < %0.3fns, sorted by $sort:\n", $threshold);

if ($full_verbose && $gates)
{
    printHeaderFullVerboseGates("PATHGROUP", "SCENARIO", "SLACK", "REQUIRED", "ARRIVAL", "SKEW" , "XTLK(D)" , "XTLK(C)" , "STARTPOINT", "ENDPOINT", "LOGIC_GATES", "TOTAL_GATES");
    foreach my $scenario (keys %{worst_slack})
    {
        if (requested_scenario($scenario)) {
            %worst_slack_scenario = %{$worst_slack{$scenario}};
            foreach my $pathgroup (sort sortFunction keys %worst_slack_scenario) # sort by hash keys
            {
                printLineFullVerboseGates($pathgroup, $scenario, $worst_slack{$scenario}{$pathgroup}, $worst_required{$scenario}{$pathgroup},
                                      $worst_arrival{$scenario}{$pathgroup}, $worst_skew{$scenario}{$pathgroup}, $worst_xtalkD{$scenario}{$pathgroup},  $worst_xtalkC{$scenario}{$pathgroup}, $worst_startpoint{$scenario}{$pathgroup}, $worst_endpoint{$scenario}{$pathgroup}, $worst_logic_gates{$scenario}{$pathgroup}, $worst_total_gates{$scenario}{$pathgroup});
            }
        }
    }
} elsif ($full_verbose)
{
    printHeaderFullVerbose("PATHGROUP", "SCENARIO", "SLACK", "REQUIRED", "ARRIVAL", "SKEW" , "XTLK(D)" , "XTLK(C)" , "STARTPOINT", "ENDPOINT");
    foreach my $scenario (keys %{worst_slack})
    {
        if (requested_scenario($scenario)) {
            %worst_slack_scenario = %{$worst_slack{$scenario}};
            foreach my $pathgroup (sort sortFunction keys %worst_slack_scenario) # sort by hash keys
            {
                printLineFullVerbose($pathgroup, $scenario, $worst_slack{$scenario}{$pathgroup}, $worst_required{$scenario}{$pathgroup},
                                 $worst_arrival{$scenario}{$pathgroup}, $worst_skew{$scenario}{$pathgroup}, $worst_xtalkD{$scenario}{$pathgroup}, $worst_xtalkC{$scenario}{$pathgroup}, $worst_startpoint{$scenario}{$pathgroup}, $worst_endpoint{$scenario}{$pathgroup});
            }
        }
    }
} elsif ($verbose && $gates)
{
    printHeaderVerboseGates("PATHGROUP", "SCENARIO", "SLACK", "REQUIRED", "ARRIVAL", "STARTPOINT", "ENDPOINT", "LOGIC_GATES", "TOTAL_GATES");
    foreach my $scenario (keys %{worst_slack})
    {
        if (requested_scenario($scenario)) {
            %worst_slack_scenario = %{$worst_slack{$scenario}};
            foreach my $pathgroup (sort sortFunction keys %worst_slack_scenario) # sort by hash keys
            {
                printLineVerboseGates($pathgroup, $scenario, $worst_slack{$scenario}{$pathgroup}, $worst_required{$scenario}{$pathgroup},
                                      $worst_arrival{$scenario}{$pathgroup}, $worst_startpoint{$scenario}{$pathgroup}, $worst_endpoint{$scenario}{$pathgroup}, $worst_logic_gates{$scenario}{$pathgroup}, $worst_total_gates{$scenario}{$pathgroup});
            }
        }
    }
} elsif ($verbose)
{
    printHeaderVerbose("PATHGROUP", "SCENARIO", "SLACK", "REQUIRED", "ARRIVAL", "STARTPOINT", "ENDPOINT");
    foreach my $scenario (keys %{worst_slack})
    {
        if (requested_scenario($scenario)) {
            %worst_slack_scenario = %{$worst_slack{$scenario}};
            foreach my $pathgroup (sort sortFunction keys %worst_slack_scenario) # sort by hash keys
            {
                printLineVerbose($pathgroup, $scenario, $worst_slack{$scenario}{$pathgroup}, $worst_required{$scenario}{$pathgroup},
                                 $worst_arrival{$scenario}{$pathgroup}, $worst_startpoint{$scenario}{$pathgroup}, $worst_endpoint{$scenario}{$pathgroup});
            }
        }
    }
}elsif ($summary) 
{
    printf("%-*s, %-*s, %-*s\n", $pathgroup_length, "PATHGROUP", $scenario_length, "SCENARIO", $slack_length, "SLACK");
    foreach my $scenario (keys %{worst_slack})
    {
        if (requested_scenario($scenario)) {
            %worst_slack_scenario = %{$worst_slack{$scenario}};
            foreach my $pathgroup (sort sortFunction keys %worst_slack_scenario) # sort by hash keys
            {
                printf("%-*s, %-*s, %-*s\n", $pathgroup_length, $pathgroup, $scenario_length, $scenario, $slack_length, $worst_slack{$scenario}{$pathgroup});
            }
        }
    }
}
elsif ($gates)
{
    printHeaderGates("PATHGROUP", "SCENARIO", "SLACK", "STARTPOINT", "ENDPOINT", "LOGIC_GATES", "TOTAL_GATES");
    foreach my $scenario (keys %{worst_slack})
    {
        if (requested_scenario($scenario)) {
            %worst_slack_scenario = %{$worst_slack{$scenario}};
            foreach my $pathgroup (sort sortFunction keys %worst_slack_scenario) # sort by hash keys
            {
                printLineGates($pathgroup, $scenario, $worst_slack{$scenario}{$pathgroup}, $worst_startpoint{$scenario}{$pathgroup}, $worst_endpoint{$scenario}{$pathgroup}, $worst_logic_gates{$scenario}{$pathgroup}, $worst_total_gates{$scenario}{$pathgroup});
            }
        }
    }
}else
{
    printHeader("PATHGROUP", "SCENARIO", "SLACK", "STARTPOINT", "ENDPOINT");

    foreach my $scenario (keys %{worst_slack})
    {
        if (requested_scenario($scenario)) {
            %worst_slack_scenario = %{$worst_slack{$scenario}};
            foreach my $pathgroup (sort sortFunction keys  %worst_slack_scenario) # sort by hash keys
            {
                printLine($pathgroup, $scenario, $worst_slack{$scenario}{$pathgroup}, $worst_startpoint{$scenario}{$pathgroup}, $worst_endpoint{$scenario}{$pathgroup});
            }
        }
    }
}




sub MAX {return ($_[0] > $_[1]) ? return $_[0] : return $_[1];} 


sub sortFunction
{
    if ($sortType == 0) { $worst_slack_scenario{$a} <=> $worst_slack_scenario{$b} } # sort by slack
    else                { $a cmp $b} # sort by pathgroup
}


sub printHeader
{
    printf("%-*s, %-*s, %-*s, %-*s -> %-*s\n",
	   $pathgroup_length, $_[0],
           $scenario_length, $_[1],
	   $slack_length, $_[2],
	   $startpoint_length, $_[3],
           $endpoint_length, $_[4]);
}

sub printHeaderGates
{
    printf("%-*s, %-*s, %-*s, %-*s -> %-*s, %-*s, %-*s\n",
	   $pathgroup_length, $_[0],
           $scenario_length, $_[1],
	   $slack_length, $_[2],
	   $startpoint_length, $_[3],
           $endpoint_length, $_[4],
           $logic_gates_length, $_[5],
           $total_gates_length, $_[6]);
}
sub printLine
{
    printf("%-*s, %-*s, %*s, %-*s -> %-*s\n",
	   $pathgroup_length, $_[0],
           $scenario_length, $_[1],
	   $slack_length, $_[2],
	   $startpoint_length, $_[3],
           $endpoint_length, $_[4]);
}
sub printLineGates
{
    printf("%-*s, %-*s, %*s, %-*s -> %-*s, %-*s, %-*s\n",
	   $pathgroup_length, $_[0],
           $scenario_length, $_[1],
	   $slack_length, $_[2],
	   $startpoint_length, $_[3],
           $endpoint_length, $_[4],
           $logic_gates_length, $_[5],
           $total_gates_length, $_[6]);
}

sub printHeaderFullVerbose
{
    printf("%-*s, %-*s, %-*s, %-*s, %-*s, %-*s, %-*s, %-*s, %-*s -> %-*s\n",
	   $pathgroup_length, $_[0],
           $scenario_length, $_[1],
	   $slack_length, $_[2],
	   $required_length, $_[3],
	   $arrival_length, $_[4],
	   $arrival_length, $_[5],
	   $arrival_length, $_[6],
	   $arrival_length, $_[7],
	   $startpoint_length, $_[8],
           $endpoint_length, $_[9]);
}
sub printHeaderFullVerboseGates
{
    printf("%-*s, %-*s, %-*s, %-*s, %-*s, %-*s, %-*s, %-*s, %-*s -> %-*s, %-*s, %-*s\n",
	   $pathgroup_length, $_[0],
           $scenario_length, $_[1],
	   $slack_length, $_[2],
	   $required_length, $_[3],
	   $arrival_length, $_[4],
       $arrival_length, $_[5],
       $arrival_length, $_[6],
       $arrival_length, $_[7],
	   $startpoint_length, $_[8],
           $endpoint_length, $_[9],
           $logic_gates_length, $_[10],
           $total_gates_length, $_[11]);
}
sub printLineFullVerbose
{
    printf("%-*s, %-*s, %*s, %*s, %*s, %*s, %*s, %*s, %-*s -> %-*s\n",
	   $pathgroup_length, $_[0],
           $scenario_length, $_[1],
	   $slack_length, $_[2],
	   $required_length, $_[3],
	   $arrival_length, $_[4],
	   $arrival_length, $_[5],
	   $arrival_length, $_[6],
	   $arrival_length, $_[7],
	   $startpoint_length, $_[8],
           $endpoint_length, $_[9]);
}
sub printLineFullVerboseGates
{
    printf("%-*s, %-*s, %*s, %*s, %*s, %-*s, %-*s, %-*s, %-*s,-> %-*s , %-*s , %-*s\n",
	   $pathgroup_length, $_[0],
           $scenario_length, $_[1],
	   $slack_length, $_[2],
	   $required_length, $_[3],
	   $arrival_length, $_[4],
	   $arrival_length, $_[5],
	   $arrival_length, $_[6],
	   $arrival_length, $_[7]+1,
	   $startpoint_length, $_[8],
           $endpoint_length, $_[9],
           $logic_gates_length, $_[10],
           $total_gates_length, $_[11]);
}

sub printHeaderVerbose
{
    printf("%-*s, %-*s, %-*s, %-*s, %-*s, %-*s -> %-*s\n",
           $pathgroup_length, $_[0],
           $scenario_length, $_[1],
           $slack_length, $_[2],
           $required_length, $_[3],
           $arrival_length, $_[4],
           $startpoint_length, $_[5],
           $endpoint_length, $_[6]);
}
sub printHeaderVerboseGates
{
    printf("%-*s, %-*s, %-*s, %-*s, %-*s, %-*s -> %-*s, %-*s, %-*s\n",
           $pathgroup_length, $_[0],
           $scenario_length, $_[1],
           $slack_length, $_[2],
           $required_length, $_[3],
           $arrival_length, $_[4],
           $startpoint_length, $_[5],
           $endpoint_length, $_[6],
           $logic_gates_length, $_[7],
           $total_gates_length, $_[8]);
}

sub printLineVerbose
{
    printf("%-*s, %-*s, %*s, %*s, %*s, %-*s -> %-*s\n",
           $pathgroup_length, $_[0],
           $scenario_length, $_[1],
           $slack_length, $_[2],
           $required_length, $_[3],
           $arrival_length, $_[4],
           $startpoint_length, $_[5],
           $endpoint_length, $_[6]);
}
sub printLineVerboseGates
{
    printf("%-*s, %-*s, %*s, %*s, %*s, %-*s -> %-*s, %-*s, %-*s\n",
           $pathgroup_length, $_[0],
           $scenario_length, $_[1],
           $slack_length, $_[2],
           $required_length, $_[3],
           $arrival_length, $_[4],
           $startpoint_length, $_[5],
           $endpoint_length, $_[6],
           $logic_gates_length, $_[7],
           $total_gates_length, $_[8]);
}


# proc to determine if user wishes to see output for this scenario
sub requested_scenario
{
    my $test_scenario = shift;
    my $found = 0;
    if ($#scenarios >= 0) {
        for (my $i = 0; $i <= $#scenarios; $i++) {
            if ($test_scenario =~ m/$scenarios[$i]/) {
                $found = 1;
            }
        }
        return $found;
    } else {
        # no scenario list specified, so report all scenarios
        return 1;
    }
}

sub usage
{
    print <<EOF;
NAME
\t$0 - generate a summary of timing violations from a synthesis timing report file

SYNOPSIS
\t$0 [ OPTION ]... [report_path/ | report_file ]

DESCRIPTION
\tReads a timing report file and produces both a summary of all violations
\tand a summary of each worst violation per path group.

\treport_path
\t\tPath to the report files, defaults to \<track directory\>.

\treport_file
\t\tIf unspecified, then the following searchlist is used:
\t\treport_path/invcui.post/report/*max*.rpt*
\t\treport_path/invcui.cts/report/*max*.rpt*
\t\treport_path/invcui.pre.place/report/*max*.rpt*
\t\treport_path/dc.syn/report/*timing*rpt*

OPTIONS
\t-i, --invcui
\t\tForce to use Innovus CUI report format, defaults to PT format, it switches based on \"Cadence Innovus\" string in the report header

\t-a, --all
\t\tDisplay all paths, including those without timing violations.

\t-h, --help
\t\tDisplay this help message and exit.

\t-v, --verbose
\t\tAdditionally print required and arrival timings.

\t-fv, --full_verbose
\t\tPrint verbose information pulse clock skew & xtalk delay sum separated to data and clock.

\t-s, --summary
\t\tPrint only the path groups and worst slack per group

\t--sort=SORT
\t\tSort the \"worst violations\" summary by SORT: slack (default), pathgroup.

\t--threshold=THRESHOLD
\t\tDisplay all paths whose slack < THRESHOLD: measured in ns, default=0.000 .

AUTHOR
\tWritten by Michael Bertone.
EOF
}


