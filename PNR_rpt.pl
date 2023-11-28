#!/usr/local/bin/perl 
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
### * Author      : sllin, modifications by smeier
### * Description : 
### ************************************************************************

#################
#standard pragmas
#################
#use strict;
use warnings;

################
#standrd modules
################
#use Getopt::Long; #parse command line options
use Getopt::Std;
use Pod::Usage;
use Data::Dumper;
#print out help info 
#use FindBin;      #figure out script directory
#use File::Basename;
#use List::Util qw( min max );
#use List::MoreUtils qw(uniq);


=pod

  This is parser report

=cut


main();



sub main {
  #my $task;
  #my $user_name;
  my %opts;
  # get command line options:
  #GetOptions ('t' => \$task, 'u' => \$user_name);

  getopts('u:t:b:', \%opts);

  if (!checkusage(\%opts)){
    usage();
    exit();

  }
  
  my $task_name = $opts{'t'};
  my $user_name = $opts{"u"};
  my $block = $opts{"b"};

  my @tasks = split(",",$task_name);
  
  #'/proj/tools01/wa/sllin/impl
  #print Dumper(\%opts);
  #print Dumper(@tasks);


my %dc_area;
my %dc_flop_counts;
my %dc_macro_counts;
my %dc_max_cap;
my %dc_max_tran;
my %dc_vio_paths_all;
my %dc_density;
my %dc_tns_all;
my %dc_wns_all;
my %dc_power;
my %dc_time;
my %dc_stamp;
my %dc_mem;
    
my %post_wns_all;
my %post_tns_all;
my %post_vio_paths_all;
my %post_max_cap;
my %post_max_tran;
my %post_runtime;
my %post_power;
my %post_density;
my %post_time;
my %post_stamp;
my %post_mem;

my %cts_wns_all;
my %cts_tns_all;
my %cts_vio_paths_all;
my %cts_max_cap;
my %cts_max_tran;
my %cts_power;
my %cts_runtime;
my %cts_density;
my %cts_time;
my %cts_stamp;
my %cts_mem;

my %pre_place_wns_all;
my %pre_place_tns_all;
my %pre_place_vio_paths_all;
my %pre_place_max_cap;
my %pre_place_max_tran;
my %pre_place_power;
my %pre_place_runtime;
my %pre_place_density;
my %pre_place_time;
my %pre_place_stamp;
my %pre_place_mem;

my %pre_fp_wns_all;
my %pre_fp_tns_all;
my %pre_fp_vio_paths_all;
my %pre_fp_max_cap;
my %pre_fp_max_tran;
my %pre_fp_power;
my %pre_fp_runtime;
my %pre_fp_density;
my %pre_fp_time;
my %pre_fp_stamp;
my %pre_fp_mem;
  
    
  foreach my $task (@tasks) {
    my $directory = "/proj/tools01/wa/$user_name/impl/$task";

    my $invcui_post_report_path = " $directory/invcui.post/report";
    my $invcui_cts_report_path = "$directory/invcui.cts/report";
    my $invcui_pre_place_report_path = "$directory/invcui.pre.place/report";
    my $invcui_pre_fp_report_path = "$directory/invcui.pre.fp/report";
    my $dc_syn_report_path = "$directory/dc.syn/report";

    my $invcui_post_logfiles_path = " $directory/invcui.post/logfiles";
    my $invcui_cts_logfiles_path = "$directory/invcui.cts/logfiles";
    my $invcui_pre_place_logfiles_path = "$directory/invcui.pre.place/logfiles";
    my $invcui_pre_fp_logfiles_path = "$directory/invcui.pre.fp/logfiles";
    my $dc_syn_logfiles_path = "$directory/dc.syn/logfiles";

    my $dc_inp_path =  "$directory/inp";

    my $dc_time_seconds;
    my $dc_hr;
    my $dc_sec;
    my $dc_def_units;
    my $dc_def_x;
    my $dc_def_y;
    my $dc_cell_area;
    my $dc_util;

    my $index;

    $dc_area{$task} =`grep 'Total cell area' $dc_syn_report_path/area.finish.rpt | awk '{print \$4}'`;
    $dc_flop_counts{$task} =`grep 'Number of sequential cells' $dc_syn_report_path/area.finish.rpt | awk '{print \$5}' | tail -1`;
    $dc_macro_counts{$task} =`grep 'Number of macros/black boxes' $dc_syn_report_path/area.finish.rpt | awk '{print \$5}' | tail -1`;
    $dc_stamp{$task} = `ls -1 $dc_syn_logfiles_path/DC*.log | tail -1 | awk '{split(\$0,a,"[_.]"); print a[2] "|" a[3] "|" a[4] "|" a[5]}'`;
    $dc_time_seconds = `tail -n 300 $dc_syn_logfiles_path/DC*.log | grep "INFO: took" | awk '{print \$3}'`; 
    $dc_hr = int($dc_time_seconds/3600);
    $dc_min = int(($dc_time_seconds % 3600)/60);
    $dc_sec = int($dc_time_seconds % 60);
    $dc_wns_all{$task} = `grep "  Design  WNS:" $dc_syn_report_path/qor.finish.rpt | awk '{print "-" \$3}'`;
    $dc_wns_all{$task} = substr($dc_wns_all{$task}, 0, -2);
    $dc_tns_all{$task} = `grep "  Design  WNS:" $dc_syn_report_path/qor.finish.rpt | awk '{print "-" \$5}'`;
    $dc_tns_all{$task} = substr($dc_tns_all{$task}, 0, -2);
    $dc_vio_paths_all{$task} = `grep "  Design  WNS:" $dc_syn_report_path/qor.finish.rpt | awk '{print \$10}'`;
    $dc_max_cap{$task} = `grep "Max Cap Violations:"  $dc_syn_report_path/qor.finish.rpt | awk '{print \$4}'`;
    $dc_max_tran{$task} = `grep "Max Trans Violations:"  $dc_syn_report_path/qor.finish.rpt | awk '{print \$4}'`;
    $dc_power{$task} = "-";
    $dc_def_units = `grep "UNITS DISTANCE MICRONS" $dc_inp_path/*.def | awk '{print \$4}'`;
    $dc_def_x = `grep "DIEAREA" $dc_inp_path/*.def | awk '{print \$7}'`;
    $dc_def_y = `grep "DIEAREA" $dc_inp_path/*.def | awk '{print \$8}'`;
    $dc_cell_area = `grep "Cell Area:" $dc_syn_report_path/qor.finish.rpt | awk '{print \$3}'`;
    $dc_util = (100 * $dc_cell_area)/(($dc_def_x/$dc_def_units) * ($dc_def_y/$dc_def_units));
    $dc_density{$task} = sprintf("%2.3f\%", $dc_util);
    $dc_time{$task} = sprintf("%d:%.2d:%.2d", $dc_hr, $dc_min, $dc_sec);
    $dc_stamp{$task} = `ls -1 $dc_syn_logfiles_path/DC*.log | tail -1 | awk -F"/" '{print \$NF}' |  awk '{split(\$0,a,"[_.]"); print a[2] "|" a[3] "|" a[4] "|" a[5]}'`;
    $dc_raw_mem = `tail -n 300 $dc_syn_logfiles_path/DC*.log | grep "Multicore mem-peak:" | awk '{print \$3}'`; 
    $dc_mem{$task} = sprintf("%d.0M", $dc_raw_mem);

    $post_wns_all{$task} = `zgrep WNS $invcui_post_report_path/$block.invcui.post.post:opt.summary.gz | awk -F'|' '{print \$2}'`;
    $post_tns_all{$task} = `zgrep TNS $invcui_post_report_path/$block.invcui.post.post:opt.summary.gz | awk -F'|' '{print \$2}'`;
    $post_vio_paths_all{$task} = `zgrep 'Violating Paths' $invcui_post_report_path/$block.invcui.post.post:opt.summary.gz | awk -F'|' '{print \$2}'`;
    $post_max_cap{$task} = `zgrep max_cap $invcui_post_report_path/$block.invcui.post.post:opt.summary.gz | awk -F'|' '{print \$2}'`;
    $post_max_tran{$task}  = `zgrep max_tran $invcui_post_report_path/$block.invcui.post.post:opt.summary.gz | awk -F'|' '{print \$2}'`;
    $post_runtime{$task}  = `tail $invcui_post_report_path/../logfiles/**log.inv.logv | grep \"Innovus\"`;
    $post_power{$task}  = `zgrep 'Total leakage power' $invcui_post_report_path/$block.invcui.post*power.rpt.gz | awk '{print \$5}'`;
    $post_density{$task}  = `zgrep Density $invcui_post_report_path/$block.invcui.post.post:opt.summary.gz | awk '{print \$2}'`;
    $post_time{$task} = `tail $invcui_post_logfiles_path/**log.inv.logv | grep \"Innovus\" | sed 's/.*real=//' | awk -F ',' '{print \$1}' | tail -1`;
    $post_stamp{$task} = `ls -1 $invcui_post_logfiles_path/**.log | tail -1 | awk -F"/" '{print \$NF}' |  awk '{split(\$0,a,"[_.]"); print a[2] "|" a[3] "|" a[4] "|" a[5]}'`;
    $post_mem{$task} = `tail $invcui_post_logfiles_path/**log.inv.logv | grep \"Innovus\" | sed 's/.*mem=//' | awk -F ')' '{print \$1}' | tail -1`;
    chomp $post_time{$task};
    chomp $post_mem{$task};
    
    $cts_wns_all{$task} = `zgrep WNS $invcui_cts_report_path/$block.invcui*summary.gz | awk -F'|' '{print \$2}'`;
    $cts_tns_all{$task} = `zgrep TNS $invcui_cts_report_path/$block.invcui*summary.gz | awk -F'|' '{print \$2}'`;
    $cts_vio_paths_all{$task} = `zgrep 'Violating Paths' $invcui_cts_report_path/$block.invcui*summary.gz | awk -F'|' '{print \$2}'`;
    $cts_max_cap{$task} = `zgrep max_cap $invcui_cts_report_path/$block.invcui*summary.gz | awk -F'|' '{print \$2}'`;
    $cts_max_tran{$task}  = `zgrep max_tran $invcui_cts_report_path/$block.invcui*summary.gz | awk -F'|' '{print \$2}'`;
    $cts_power{$task}  = `grep 'Total leakage power' $invcui_cts_report_path/*.power | awk '{print \$5}'`;
    $cts_runtime{$task}  = `tail $invcui_cts_report_path/../logfiles/**log.inv.logv | grep \"Innovus\"`;
    $cts_density{$task}  = `zgrep Density $invcui_cts_report_path/$block.invcui.cts.cts:opt.summary.gz | awk -F'|' '{print \$2}'`;
    $cts_time{$task} = `tail $invcui_cts_logfiles_path/**log.inv.logv | grep \"Innovus\" | sed 's/.*real=//' | awk -F ',' '{print \$1}' | tail -1`;
    $cts_stamp{$task} = `ls -1 $invcui_cts_logfiles_path/**.log | tail -1 | awk -F"/" '{print \$NF}' | awk '{split(\$0,a,"[_.]"); print a[2] "|" a[3] "|" a[4] "|" a[5]}'`;
    $cts_mem{$task} = `tail $invcui_cts_logfiles_path/**log.inv.logv | grep \"Innovus\" | sed 's/.*mem=//' | awk -F ')' '{print \$1}' | tail -1`;    
    chomp $cts_time{$task};
    chomp $cts_mem{$task};

    $pre_place_wns_all{$task} = `zgrep WNS $invcui_pre_place_report_path/$block.invcui*summary.gz | awk -F'|' '{print \$2}'`;
    $pre_place_tns_all{$task} = `zgrep TNS $invcui_pre_place_report_path/$block.invcui*summary.gz | awk -F'|' '{print \$2}'`;
    $pre_place_vio_paths_all{$task} = `zgrep 'Violating Paths' $invcui_pre_place_report_path/$block.invcui*summary.gz | awk -F'|' '{print \$2}'`;
    $pre_place_max_cap{$task} = `zgrep max_cap $invcui_pre_place_report_path/$block.invcui*summary.gz | awk -F'|' '{print \$2}'`;
    $pre_place_max_tran{$task}  = `zgrep max_tran $invcui_pre_place_report_path/$block.invcui*summary.gz | awk -F'|' '{print \$2}'`;
    $pre_place_power{$task}  = "-";
    $pre_place_runtime{$task}  = `tail $invcui_pre_place_report_path/../logfiles/**log.inv.logv | grep \"Innovus\"`;
    $pre_place_density{$task}  = `zgrep Density $invcui_pre_place_report_path/$block.invcui.pre.place.pre:place.summary.gz | awk -F'|' '{print \$2}'`;
    $pre_place_time{$task} = `tail $invcui_pre_place_logfiles_path/**log.inv.logv | grep \"Innovus\" | sed 's/.*real=//' | awk -F ',' '{print \$1}' | tail -1`;
    $pre_place_stamp{$task} = `ls -1 $invcui_pre_place_logfiles_path/**.log | tail -1 | awk -F"/" '{print \$NF}' | awk '{split(\$0,a,"[_.]"); print a[2] "|" a[3] "|" a[4] "|" a[5]}'`;
    $pre_place_mem{$task} = `tail $invcui_pre_place_logfiles_path/**log.inv.logv | grep \"Innovus\" | sed 's/.*mem=//' | awk -F ')' '{print \$1}' | tail -1`;        
    chomp $pre_place_time{$task};
    chomp $pre_place_mem{$task};

    $pre_fp_wns_all{$task} = `zgrep WNS $invcui_pre_fp_report_path/$block.invcui*summary.gz | awk -F'|' '{print \$2}'`;
    $pre_fp_tns_all{$task} = `zgrep TNS $invcui_pre_fp_report_path/$block.invcui*summary.gz | awk -F'|' '{print \$2}'`;
    $pre_fp_vio_paths_all{$task} = `zgrep 'Violating Paths' $invcui_pre_fp_report_path/$block.invcui*summary.gz | awk -F'|' '{print \$2}'`;
    $pre_fp_max_cap{$task} = "-";
    $pre_fp_max_tran{$task}  = "-";
    $pre_fp_power{$task} = "-";
    $pre_fp_runtime{$task}  = `tail $invcui_pre_fp_report_path/../logfiles/**log.inv.logv | grep \"Innovus\"`;
    $pre_fp_density{$task}  = "-";
    $pre_fp_time{$task} = `tail $invcui_pre_fp_logfiles_path/**log.inv.logv | grep \"Innovus\" | sed 's/.*real=//' | awk -F ',' '{print \$1}' | tail -1`;
    $pre_fp_stamp{$task} = `ls -1 $invcui_pre_fp_logfiles_path/**.log | tail -1 | awk -F"/" '{print \$NF}' | awk '{split(\$0,a,"[_.]"); print a[2] "|" a[3] "|" a[4] "|" a[5]}'`;
    $pre_fp_mem{$task} = `tail $invcui_pre_fp_logfiles_path/**log.inv.logv | grep \"Innovus\" | sed 's/.*mem=//' | awk -F ')' '{print \$1}' | tail -1`;        
    chomp $pre_fp_time{$task};
    chomp $pre_fp_mem{$task};
  }

  my $output_file = 'report_summary.rpt';
  open(OFH, '>', $output_file) or die $!;  
    foreach my $task (@tasks) {
      print OFH "$task\n";
      print OFH "--------------------------------------------------------\n";
      print OFH "invcui.post\n";
      #print OFH "--------------------------------------------------------\n";
      print OFH "All WNS: $post_wns_all{$task}";
      print OFH "All TNS: $post_tns_all{$task}";
      print OFH "All Violations Paths: $post_vio_paths_all{$task}";
      print OFH "Total max_cap: $post_max_cap{$task}";
      print OFH "Total max_tran: $post_max_tran{$task}";
      print OFH "Total leakage power(mW): $post_power{$task}";
      print OFH "$post_runtime{$task}";
      print OFH "--------------------------------------------------------\n";
      print OFH "invcui.cts\n";
      
      print OFH "All WNS: $cts_wns_all{$task}";
      print OFH "All TNS: $cts_tns_all{$task}";
      print OFH "All Violations Paths: $cts_vio_paths_all{$task}";
      print OFH "Total max_cap: $cts_max_cap{$task}";
      print OFH "Total max_tran: $cts_max_tran{$task}";
      print OFH "Total leakage power(mW): $cts_power{$task}";
      print OFH "$cts_runtime{$task}";
      print OFH "--------------------------------------------------------\n";
      print OFH "invcui.pre.place\n";
      
      print OFH "All WNS: $pre_place_wns_all{$task}";
      print OFH "All TNS: $pre_place_tns_all{$task}";
      print OFH "All Violations Paths: $pre_place_vio_paths_all{$task}";
      print OFH "Total max_cap: $pre_place_max_cap{$task}";
      print OFH "Total max_tran: $pre_place_max_tran{$task}";
      print OFH "$pre_place_runtime{$task}";
      print OFH "--------------------------------------------------------\n";
      print OFH "invcui.pre_fp\n";
      
      print OFH "All WNS: $pre_fp_wns_all{$task}";
      print OFH "All TNS: $pre_fp_tns_all{$task}";
      print OFH "All Violations Paths: $pre_fp_vio_paths_all{$task}";
      #print OFH "Total max_cap: $pre_fp_max_cap{$task}";
      #print OFH "Total max_tran: $pre_fp_max_tran{$task}";
      print OFH "$pre_fp_runtime{$task}";  
      
      print OFH "--------------------------------------------------------\n";
      print OFH "dc.syn\n";
      print OFH "Area: $dc_area{$task}";
      print OFH "Flop counts: $dc_flop_counts{$task}";
      print OFH "Macro counts: $dc_macro_counts{$task}";      
      print OFH "\n";
    };

  close(OFH);


  ###########compare_report
  
  my %table = (
               'post' => ['invcui.post','$post_wns_all{$task_c}','$post_tns_all{$task_c}','$post_vio_paths_all{$task_c}','$post_max_cap{$task_c}','$post_max_tran{$task_c}','$post_power{$task_c}','$post_density{$task_c}','$post_time{$task_c}','$post_mem{$task_c}','$post_stamp{$task_c}'],
               'cts' => ['invcui.cts','$cts_wns_all{$task_c}','$cts_tns_all{$task_c}','$cts_vio_paths_all{$task_c}','$cts_max_cap{$task_c}','$cts_max_tran{$task_c}','$cts_power{$task_c}','$cts_density{$task_c}','$cts_time{$task_c}','$cts_mem{$task_c}','$cts_stamp{$task_c}'],
               'pre_place' => ['invcui.pre_place','$pre_place_wns_all{$task_c}','$pre_place_tns_all{$task_c}','$pre_place_vio_paths_all{$task_c}','$pre_place_max_cap{$task_c}','$pre_place_max_tran{$task_c}','$pre_place_power{$task_c}','$pre_place_density{$task_c}','$pre_place_time{$task_c}','$pre_place_mem{$task_c}','$pre_place_stamp{$task_c}'],
               'pre_fp' => ['invcui.pre_fp','$pre_fp_wns_all{$task_c}','$pre_fp_tns_all{$task_c}','$pre_fp_vio_paths_all{$task_c}','$pre_fp_max_cap{$task_c}','$pre_fp_max_tran{$task_c}','$pre_fp_power{$task_c}','$pre_fp_density{$task_c}','$pre_fp_time{$task_c}','$pre_fp_mem{$task_c}','$pre_fp_stamp{$task_c}'],
               'dc_syn' => ['dc_syn', '$dc_wns_all{$task_c}','$dc_tns_all{$task_c}','$dc_vio_paths_all{$task_c}','$dc_max_cap{$task_c}','$dc_max_tran{$task_c}','$dc_power{$task_c}','$dc_density{$task_c}','$dc_time{$task_c}','$dc_mem{$task_c}','$dc_stamp{$task_c}']

              );

  my $stage='';
  my $wns;
  my $tns='';
  my $violations='';
  my $maxcap='';
  my $maxtran='';
  my $leakage='';
  my $utilization='';
  my $time='';
  my $date='';
  my $mem='';
#  my $area='';
#  my $flop_counts='';
#  my $macro_counts='';

  
  my $output_file2 = 'report_comparison.rpt';
  open(Task, '>', $output_file2) or die $!;
  $~ = "Task";
  $^ = "Task_TOP";
  format Task =
@<<<<<<<<<<<< @>>>>>>>>  @>>>>>> @>>>>>> @>>>>>>>> @>>>>>>>>  @>>>>>>>>>>>>>>  @>>>>>> @>>>>>>>> @>>>>>>>> @>>>>>>>>>>>>>>>>
$stage, $wns ,$tns , $violations, $maxcap, $maxtran, $leakage, $utilization, $time, $mem, $date
.
  
#  format Task_TOP =
#
#   --------------------------------------------------------------------------------------------------------------------------------------------------             
#   STEP               WNS      TNS     Paths   max_cap  max_tran     eakage_pwr(mW)            Util time   mem (MB)
#   ---------------------------------------------------------------------------------------------------------------------------------------------------   
#.

  #print Dumper(\%table);
  #reverse sort keys

    foreach my $task_c (@tasks) {
      print Task "\n*****$task_c******\n";
      print Task "----------------------------------------------------------------------------------------------------------------------------\n";
      print Task "STEP                WNS      TNS   Paths   max_cap  max_tran  leakage_pwr(mW)     Util      time       mem              date\n";
      print Task "----------------------------------------------------------------------------------------------------------------------------\n";
      foreach my $value (sort values %table) {
        #print Task "*****$value******\n";
        #print Dumper(%table);
        #print Dumper(\$value);
        #print("@$value[0]","\n");
        $stage = @$value[0];
        $wns= eval @$value[1];
        $tns= eval @$value[2];
        $violations= eval @$value[3];
        $maxcap= eval @$value[4];
        $maxtran= eval @$value[5];
        $leakage= eval @$value[6];
        $utilization =  eval @$value[7];
        $time = eval @$value[8];
        $mem = eval @$value[9];
        $date = eval @$value[10];

        write Task;
      }
    }
  system ("cat $output_file2");
  close Task;

  printf("\n\n");
  printf("%-50s %-8s\n", "Track", "Shorts");
  printf("%-50s %-8s\n", "--------------------------------------", "------");
  foreach my $task_c (@tasks) {
    $report_dir = "/proj/tools01/wa/$user_name/impl/$task_c/invcui.post/report";
    $drc_file =  "$report_dir/$block.invcui.post.post:opt.drc.rpt";
    if (-e $drc_file) {
     $shorts = `grep 'Metal Short' $drc_file | awk '{print \$3}'`;
     $shorts_str = sprintf("%d", $shorts);
     printf("%-50s %-8s\n", $task_c, $shorts_str);
    } else {
       printf("%-50s %s \n", $task_c, "No drc report file");
    }
  }

}


sub checkusage {
  my $opts = shift;
  my $t = $opts->{"t"};
  my $u = $opts->{"u"};
  my $b = $opts->{"b"};
  if(!defined($t) or !defined($u) or !defined($b)){
    print("Missing options");
    return 0;

  }

  return 1;

}

sub usage {
  print <<USAGE;

 usage: parse_report.pl <options>
   -t <task name> specify task name
   -u <username> specify username
   -b <block_name> specify block 
   example usage :
   perl parse_report.pl -t npc_pnra1.DE1/track.baseline,npc_pnra1.DE1/track.baseline_shrink  -u  sllin -b npc_pnra1
   Two output files:
   report_summary.rpt : Contains most of the information 
   report_comparison.rpt : Timing comparision between each of steps
USAGE

}



