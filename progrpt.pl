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
### *  Copyright 2019-2019, Marvell, Inc.  All rights reserved.            *
### *                                                                      *
### ************************************************************************
### * Author      : 
### * Description : 
### ************************************************************************

use warnings;
use strict;
use Getopt::Long;
use feature qw(say);
use Data::Dumper;
use Cwd;
use File::Basename;
#use FindBin qw($RealBin);
#use lib "$RealBin/utils/perl";
#use MailHelper;

#
my $help      = 0;
my $step      = "invcui.post.opt";
my $dir;
my $track;
my $username;
my $wa;
my $outfile;
my $csv;
my $html;
my $proj_root = $ENV{'PROJ_ROOT'};
my $rpt_num = 1;
my $clk;

my $full_path = getcwd;

($username) =  $full_path =~ m|/([A-Za-z0-9_.]+)/impl|;
($wa) = $full_path =~ m|/([A-Za-z0-9_.]+)/$username|;
($dir) = $full_path =~ m|impl/([A-Za-z0-9_.]+)/|;
($track) = $full_path =~ m|(track[A-Za-z0-9_.]+)|;



GetOptions(
           'step=s'      => \$step,
           'help'        => \$help,
           'dir=s'       => \$dir,
           'track=s'     => \$track,
           'user=s'      => \$username,
           'o=s'         => \$outfile,
           'csv'         => \$csv,
           'html'        => \$html,
           'num=s'       => \$rpt_num,
           'clk' => \$clk,
           )
  or die "Error parsing command line";

&print_usage if ($help);

die("Error: working directory must be specified.") unless defined $dir;
die("Error: track must be specified.") unless defined $track;




my @tracks = split(",",$track);
my $track_num = $#tracks+1;
#print $track_num,"\n";
if ($track_num >1) {
  $rpt_num = 1 
}

my $block = $dir;
$block =~ s/\.\w+//g;
#print $block;


#print(@tracks);


# map the bfw step name to a report file ....<Need to be updated>
my %step_map = (
                '0'   => 'defacto.rtl',
                'defacto.rtl'   => 'defacto.rtl',
                '1'  => 'ipbu_import_compmem.rtl',
                'ipbu_import_compmem.rtl' => 'ipbu_import_compmem.rtl',
                '2'               => 'dc.syn',
                'dc.syn' => 'dc.syn',
                '3'             => 'invcui.pre.fp',
                'invcui.pre.fp'          => 'invcui.pre.fp',
                '4'             => 'invcui.pre.place',
                'invcui.pre.place'     => 'invcui.pre.place',
                '5'         => 'invcui.cts',
                'invcui.cts' => 'invcui.cts',
                '6'             => 'invcui.post.route',
                'invcui.post.route' => 'invcui.post.route',
                '7'             => 'invcui.post.opt',
                'invcui.post.opt' => 'invcui.post.opt',
               );


my %max_file = (
                
                'dc.syn' => "$block.dc.syn.syn:opt.timing.opt.rpt.gz",
                'invcui.pre.fp'          => "invcui.pre.fp.max1.timing.rpt.gz",
                'invcui.pre.place'     => "invcui.pre.place.max1.timing.rpt.gz",
                'invcui.cts' => "invcui.cts.max1.timing.rpt.gz",
                'invcui.post.route' => "invcui.post.route.max1.timing.rpt.gz",
                'invcui.post.opt' => "invcui.post.opt.max1.timing.rpt.gz",
               );


my %log_file = (
                'dc.syn' => "dc.syn.log",
                'invcui.pre.fp'          => "invcui.pre.fp.log",
                'invcui.pre.place'     => "invcui.pre.place.log",
                'invcui.cts' => "invcui.cts.log",
                'invcui.post.opt' => "invcui.post.opt.log",
                'invcui.post.route' => "invcui.post.route.log",
               );


my $rpt_file = $max_file{$step_map{$step}};


#print $rpt_file;

chdir "/$proj_root/$wa/$username/impl/$dir";


#print Dumper(\@dirs);


my %files;
my %files_log;

foreach my $t (@tracks) {
  chomp $t;
  
  my @dirs = `ls -d $t/rpts/rpt-*`;
  

  foreach my $r (@dirs) {
    chomp $r;
    my @rpt_dir = split "/",$r;
    
    my @files = glob("$r/$rpt_file");

    if ($#files >= 0) {
      $files{$t}{$rpt_dir[2]} = $files[0];
    }
  }
}






#print Dumper(\%files);
#print Dumper(\%files_log);

#%files = {
#          'track.baseline' => [
#                                'track.baseline/invcui.cts/fast_syntest_mems.invcui.cts.cts:opt.max1.timing.rpt.gz'
#                              ],
#          'track.only_ulvt' => [
#                                 'track.only_ulvt/invcui.cts/fast_syntest_mems.invcui.cts.cts:opt.max1.timing.rpt.gz '
#                               ]
#        };




my %diff;
my %diff_clk;
my %diff_dc;

#my $count = 0;




foreach my $t (@tracks) {
  chomp $t;
  chdir "/$proj_root/$wa/$username/impl/$dir";
  my $count = 0;
  foreach my $r (reverse sort keys $files{$t}) {
    chomp $r;
    my $file = $files{$t}{$r};
    #print $file,"\n";
    #print "$t,$r\n";
    last
      if ((defined $rpt_num) && ($count >= $rpt_num));


    ###############
    #### DC #######
    ###############
    if ($step_map{$step} eq 'dc.syn') {
      #clock info

      
      my $dc_clk_file = $file;
      my @dc_clk_array = split "/", $dc_clk_file;
      $dc_clk_array[3]="$block.finish.setup.max1.design.clock_gating.rpt.gz";
      $dc_clk_file = join("/",@dc_clk_array);
      if(-e $dc_clk_file) {
        
        $diff_dc{"Clock gating percentage:"}{$t}{$r} = `zgrep 'Number of Gated register' $dc_clk_file  | awk '{print (\$8)}' | sed -r 's/\\(|\\)//g' `;
      } else {
        
        print "Warning: No $dc_clk_file file \n";
      }
      
      #multibit info
      my $multi_banking_file_dc = $file;
      my @multi_banking_file_dc_array = split "/", $multi_banking_file_dc;
      $multi_banking_file_dc_array[3] = "$block.multibit.banking.rpt.gz";
      $multi_banking_file_dc = join("/",@multi_banking_file_dc_array);
      
      if(-e $multi_banking_file_dc) {
        $diff_dc{"Multibit banking percentage:"}{$t}{$r} = `zgrep 'Sequential cells banking ratio' $multi_banking_file_dc | awk '{print (\$16)}' `;
        
      } else {
        print "Warning: No $multi_banking_file_dc file \n";
      }

      #vt info
      my $vt_file_dc = $file;
      my @vt_file_dc_array = split "/", $vt_file_dc;
      $vt_file_dc_array[3] = "$block.finish.vt_groups.rpt.gz";
      $vt_file_dc = join("/",@vt_file_dc_array);
      
      if(-e $vt_file_dc) {
        $diff_dc{"VT Cell(%) LVT:"}{$t}{$r} = `zgrep "^LVT " $vt_file_dc | awk '{print (\$13)}'` ? `zgrep "^LVT " $vt_file_dc | awk '{print (\$13)}'` : '0%';
        $diff_dc{"VT Cell(%) LVTLL :"}{$t}{$r} =`zgrep ^LVTLL $vt_file_dc | awk '{print (\$13)}'` ? `zgrep ^LVTLL $vt_file_dc | awk '{print (\$13)}'` : '0%';
        $diff_dc{"VT Cell(%) SVT :"}{$t}{$r} = `zgrep '^SVT ' $vt_file_dc | awk '{print (\$13)}'` ? `zgrep '^SVT ' $vt_file_dc | awk '{print (\$13)}'` : '0%';
        $diff_dc{"VT Cell(%) ULVT :"}{$t}{$r} = `zgrep "^ULVT " $vt_file_dc | awk '{print (\$13)}'` ? `zgrep "^ULVT " $vt_file_dc | awk '{print (\$13)}'` : '0%';
        $diff_dc{"VT Cell(%) ULVTLL :"}{$t}{$r} = `zgrep "^ULVTLL" $vt_file_dc | awk '{print (\$13)}'` ? `zgrep "^ULVTLL" $vt_file_dc | awk '{print (\$13)}'` : '0%';
      } else {
        print "Warning: No $vt_file_dc file \n";
      }

      #area info
      my $area_file_dc = $file;
      my @area_file_dc_array = split "/", $area_file_dc;
      $area_file_dc_array[3] = "$block.finish.area.rpt.gz";
      $area_file_dc = join("/",@area_file_dc_array);
      #my $area_file_dc = "$t/dc.syn/report/$block.finish.area.rpt.gz";

      if(-e $area_file_dc) {
        $diff_dc{"Number of sequential cells:"}{$t}{$r} = `zgrep 'Number of sequential cells' $area_file_dc | awk '{print \$5}'`;
        
        $diff_dc{"Number of macros/black boxes:"}{$t}{$r} = `zgrep 'Number of macros/black boxes' $area_file_dc | awk '{print \$5}'`;

      } else {
        print "Warning: No $area_file_dc file \n";
      }

      #qor info
      my $qor_file_dc = $file;
      my @qor_file_dc_array = split "/", $qor_file_dc;
      $qor_file_dc_array[3] = "$block.finish.setup.max1.qor.rpt.gz";
      $qor_file_dc = join("/",@qor_file_dc_array);
      

      if(-e $qor_file_dc) {
        my @scenarios = ('max1','max2','min1');
        
        my %gp_wns = split "[:\n]", `zgrep -E  "(Scenario ')|(Timing Path Group)|(Critical Path Slack)" $qor_file_dc | xargs -n 10 | sed -r 's/Scenario|Timing Path Group|Critical Path Slack|_[a-zA-Z0-9]+_[a-zA-Z0-9]+_[a-zA-Z0-9]+//g'`;
      
        foreach my $pathgroup (keys %gp_wns) {
          $diff_dc{"Timing$pathgroup"}{$t}{$r} = sprintf("%.3f",$gp_wns{$pathgroup})
        }

      } else {
        print "Warning: No $qor_file_dc file \n";
      }

      #log file
      my $log_file_dc = $file;
      my @log_file_dc_array = split "/", $log_file_dc;
      $log_file_dc_array[3] = "$log_file{$step_map{$step}}";
      $log_file_dc = join("/",@log_file_dc_array);
      
      #my $log_file_dc = "$t/$step_map{$step}/logfiles/$files_log{$t}";
      
      if(-e $log_file_dc) {
        $diff_dc{"Runtime:"}{$t}{$r} = `tail -n 100 $log_file_dc | grep 'INFO: took' | awk '{hours = \$3 / 3600; mins = ( \$3 / 60 ) % 60; secs = \$3 % 60 ; print int(hours) ":" int(mins) ":" int(secs)}'`;
       
        $diff_dc{"Step errors:"}{$t}{$r} = `egrep -ic '^ERROR' $log_file_dc`;
        
        
      } else {
        print "Warning: No $log_file_dc file \n";
      }
      
      $count ++;
    } else {

      
      ###############
      #### innovus ##
      ###############
      #max/min timing info
      my $sum_file = $file;
      $sum_file =~ s/\.max1\.timing\.rpt\.gz/\.time_design\.summary\.gz/g;
      
      if(-e $sum_file) {
        
        if (!open(CMD, "gunzip -c $sum_file |")) {
          warn "Warning: cannot open file $sum_file";
          next;
        }
        my %timehash;
        my @timehead;
        while (my $line = <CMD>) {
          chomp $line;
          if ($line =~ /Setup/) {
            @timehead = split(/\|/,$line);
            for (my $i = 3; $i<=$#timehead;$i++) {
              $timehash{$timehead[$i]} = [];
            }
          }
          
          if ($line =~ /\|\s{20}\|/) {
            my @data =  split(/\|/,$line);
            
            for (my $i =3; $i<=$#data;$i++) {
              
              my $data_f = $data[$i];
              $data_f =~ s/\s+$//;
              push ($timehash{$timehead[$i]},$data_f)
                
            }
          }
        }
        
        close(CMD);  
        foreach my $mode (keys %timehash) {
          $diff{"Max2 $mode WNS (ns):"}{$t}{$r} = $timehash{$mode}[0];
          $diff{"Max2 $mode TNS (ns):"}{$t}{$r} = $timehash{$mode}[1];
          $diff{"Max2 $mode NVP (ns):"}{$t}{$r} = $timehash{$mode}[2];
          $diff{"Max1 $mode WNS (ns):"}{$t}{$r} = $timehash{$mode}[4];
          $diff{"Max1 $mode TNS (ns):"}{$t}{$r} = $timehash{$mode}[5];
          $diff{"Max1 $mode NVP (ns):"}{$t}{$r} = $timehash{$mode}[6];          
        }
        
        #min time info
        my $min_file = $file;
        $min_file =~ s/\.max1\.timing\.rpt\.gz/\.min3\.timing\.rpt\.gz/g;
        #print $sum_file;
        #print "\n";
        
        
        if(-e $min_file) {
          $diff{"Min3 WNS (ns):"}{$t}{$r} = `zgrep -m 1 'Path 1' $min_file | awk '{print \$4}' | sed -e 's/(//g' `;
        } else {
          print "Warning: No $min_file file \n";
          
        }
        
        
        
        # vt% info
        my $vt_file = $file;
        $vt_file =~ s/\.max1\.timing\.rpt\.gz/\.vt_groups\.rpt\.gz/g;
        #print $check_place_file;
        if(-e $vt_file) {
          $diff{"VT Cell(%) LVT:"}{$t}{$r} = `zgrep "instances.vth:LVT.ratio" $vt_file | awk '{print (\$2)}'` ? `zgrep "instances.vth:LVT.ratio" $vt_file | awk '{print (\$2)}'` : '0%';
          $diff{"VT Cell(%) LVTLL:"}{$t}{$r} = `zgrep "instances.vth:LVTLL.ratio" $vt_file | awk '{print (\$2)}' ` ? `zgrep "instances.vth:LVTLL.ratio" $vt_file | awk '{print (\$2)}'` : '0';
          $diff{"VT Cell(%) SVT:"}{$t}{$r} = `zgrep "instances.vth:SVT.ratio" $vt_file | awk '{print (\$2)}' ` ? `zgrep "instances.vth:SVT.ratio" $vt_file | awk '{print (\$2)}'` : '0';
          $diff{"VT Cell(%) ULVT:"}{$t}{$r} = `zgrep "instances.vth:ULVT.ratio" $vt_file | awk '{print (\$2)}' ` ? `zgrep "instances.vth:ULVT.ratio" $vt_file | awk '{print (\$2)}'` : '0';
          $diff{"VT Cell(%) ULVTLL:"}{$t}{$r} = `zgrep "instances.vth:ULVTLL.ratio" $vt_file | awk '{print (\$2)}' ` ? `zgrep "instances.vth:ULVTLL.ratio" $vt_file | awk '{print (\$2)}'` : '0';
          #$diff{"VT Cell(%) LVT:"}{$t}{$r} = `zgrep "^LVT " $vt_file | awk '{print (\$13)}'` ? `zgrep "^LVT " $vt_file | awk '{print (\$13)}'` : '0%';
          #$diff{"VT Cell(%) LVTLL :"}{$t}{$r} =`zgrep ^LVTLL $vt_file | awk '{print (\$13)}'` ? `zgrep ^LVTLL $vt_file | awk '{print (\$13)}'` : '0%';
          #$diff{"VT Cell(%) SVT :"}{$t}{$r} = `zgrep '^SVT ' $vt_file | awk '{print (\$13)}'` ? `zgrep '^SVT ' $vt_file | awk '{print (\$13)}'` : '0%';
          #$diff{"VT Cell(%) ULVT :"}{$t}{$r} = `zgrep "^ULVT " $vt_file | awk '{print (\$13)}'` ? `zgrep "^ULVT " $vt_file | awk '{print (\$13)}'` : '0%';
          #$diff{"VT Cell(%) ULVTLL :"}{$t}{$r} = `zgrep "^ULVTLL" $vt_file | awk '{print (\$13)}'` ? `zgrep "^ULVTLL" $vt_file | awk '{print (\$13)}'` : '0%';
        } else {
          print "Warning: No $vt_file file \n";
          
        }
        
        #power info
        my $power_file = $file;
        $power_file =~ s/\.max1\.timing\.rpt\.gz/\.power\.rpt\.gz/g;
        
        if(-e $power_file) {
          $diff{"Total Power (Leakage) (mW):"}{$t}{$r} = `zgrep 'Total Leakage Power' $power_file | awk '{print \$4}'`;
          $diff{"Total Power (Switching) (mW):"}{$t}{$r} = `zgrep 'Total Switching Power' $power_file | awk '{print \$4}'`;
          $diff{"Total Power (Internal) (mW):"}{$t}{$r} = `zgrep 'Total Internal Power' $power_file | awk '{print \$4}'`;
        } else {
          print "Warning: No $power_file file \n";
          
        }
        
        #placement info
        my $check_place_file = $file;
        
        #$check_place_file =~ s/\.max1\.timing\.rpt\.gz/\.check_place\.rpt\.gz/g;
        $check_place_file =~ s/\.max1\.timing\.rpt\.gz/\.summary\.rpt\.gz/g;
        
        if(-e $check_place_file) {
          $diff{"Total Gate Density (Subtracting BLOCKAGES) (%):"}{$t}{$r} = `zgrep 'Pure Gate Density #1' $check_place_file | awk '{print (\$8)}'`;
          $diff{"Total Gate Density (Subtracting BLOCKAGES and Physical Cells) (%):"}{$t}{$r} = `zgrep 'Pure Gate Density #2' $check_place_file | awk '{print (\$11)}'`;
          $diff{"Total Gate Density (Subtracting MACROS) (%):"}{$t}{$r} = `zgrep 'Pure Gate Density #3' $check_place_file | awk '{print (\$8)}'`;
          $diff{"Total Gate Density (Subtracting MACROS and Physical Cells) (%):"}{$t}{$r} = `zgrep 'Pure Gate Density #4' $check_place_file | awk '{print (\$11)}'`;
          $diff{"Total Gate Density (Subtracting MACROS and BLOCKAGES) (%):"}{$t}{$r} = `zgrep 'Pure Gate Density #5' $check_place_file | awk '{print (\$10)}'`;
          $diff{"Total area of Standard cells (um2):"}{$t}{$r} = `zgrep 'Total area of Standard cells:' $check_place_file | awk '{print (\$6)}'`;
          $diff{"Total area of Standard cells (Subtracting Physical Cells)(um2):"}{$t}{$r} = `zgrep 'Total area of Standard cells(Subtracting Physical Cells):' $check_place_file | awk '{print (\$8)}'`;
          $diff{"Total area of Macros (um2):"}{$t}{$r} = `zgrep 'Total area of Macros' $check_place_file | awk '{print (\$5)}'`;
          $diff{"Total area of Blockages (um2):"}{$t}{$r} = `zgrep 'Total area of Blockages' $check_place_file | awk '{print (\$5)}'`;
          $diff{"Total area of Core (um2):"}{$t}{$r} = `zgrep 'Total area of Core' $check_place_file | awk '{print (\$5)}'`;
          #$diff{"Total Density(no Macros) (%):"}{$t}{$r} = `zgrep 'Placement Density (' $check_place_file | awk '{print (\$6)}' | sed -e 's/cells)://g' | sed -e 's/%(.*)//g'`;
          #$diff{"Total std cells area:"}{$t}{$r} = `zgrep 'Placement Density (' $check_place_file | awk '{print (\$6)}' | sed -e 's/cells):[0-9]*.[0-9]*%(//g' | sed -e 's/[0-9]*)//g' | sed -e 's+/++g' `;
          #$diff{"Total block area:"}{$t}{$r} = `zgrep 'Placement Density (' $check_place_file | awk '{print (\$6)}' | sed -e 's/cells):[0-9]*.[0-9]*%(//g'| sed -e 's+[0-9]*/++g'| sed -e 's+)++g' `;
        } else {
          print "Warning: No $check_place_file file \n";
          
        }
        #clock info 
        my $clk_file = $file;
        my @clk_array = split "/", $clk_file;
        $clk_array[3]='clock_qor.rpt.gz';
        $clk_file = join("/",@clk_array);
        if(-e $clk_file) {
          
          $diff_clk{"Clock Latency(Max1):"}{$t}{$r} =`zgrep -B 1 -A 1 max1_setup $clk_file | grep -B 3 'Max latency'| grep -v Scenario | grep -v -  | sed -e 's/Clock//g' | sed -e 's/Max latency//g' |xargs -n 100 `;
          
          $diff_clk{"Clock Skew(Max1):"}{$t}{$r}=`zgrep -B 1 -A 1 max1_setup $clk_file | zgrep -B 3 'Max skew' | grep -v Scenario| grep -v - | sed -e 's/Clock//g' | sed -e 's/Max skew//g'| xargs -n 100`;
          
          $diff_clk{"Clock Depth:"}{$t}{$r} = `zgrep -B 1 depth $clk_file | xargs -n 7 | sed -e 's/Clock tree: //g' | sed -e 's/Max depth ://g' | grep -v TAP| xargs -n 100` ;
        } else {
          
          print "Warning: No $clk_file file \n";
        }
        
        
        
        #drc info
        #my $drc_file = "$t/rpts/$r/$block.invcui.post.opt.route.drc.rpt.gz";
        my $drc_file = $file;
        $drc_file =~ s/\.max1\.timing\.rpt\.gz/\.route\.drc\.rpt\.gz/g;
        
        if(-e $drc_file) {
          $diff{"Total DRC:"}{$t}{$r} = `zgrep 'Total DRC' $drc_file | awk '{print \$4}'`;        
          $diff{"Total Metal Short:"}{$t}{$r} = `zgrep 'Metal_Short' $drc_file | awk '{print \$2}'`;
          
        } else {
          print "Warning: No $drc_file file \n";
          
        }
        
        #log info
        my $log_file = $file;
        my @log_array = split "/", $log_file;
        $log_array[3]=$log_file{$step_map{$step}};
        $log_file = join("/",@log_array);
        #print $log_file,"\n";
        if(-e $log_file) {
          #print "$file_log\n";
          $diff{"Runtime:"}{$t}{$r} = `tail $log_file | grep \"Innovus\"| awk '{print (\$5)}' | sed -e 's/real=//g' | sed -e 's/,//g'`;
          $diff{"Step errors:"}{$t}{$r} = `egrep -ic "^\\*\\*error|^\\[IPBU\\]\\[ERROR\\]" $log_file`
            # $diff{"Step errors:"}{$t} = `egrep -ic "^\*\*error|^\[IPBU\]\[ERROR\]" $file_log`;
            # $diff{"Step errors:"}{$t} = `grep -ic ^**error $file_log`;
            
        }else {
          print "Warning: No $log_file file \n";
          
          
          
          
        }
        
        $count++;
      }
    }
    
    
    
  }
  
}
#print Dumper(\%diff);
#print Dumper(\%diff_dc);
  
#print Dumper(\%diff_clk);

if (defined($outfile)) {
  $outfile = "$full_path\/$outfile";
  #print $outfile,"\n";
  open(FP, ">$outfile")
    or die "Cannout open output file: $outfile";
  select FP;
}


if ($html) {
  print
    '<style>', "\n",
    'body       { font-family: monospace; }', "\n",
    'th         { padding-right: 2px; padding-left:  2px; white-space: nowrap; text-align: left;  background: lavender; }', "\n",
    'td         { padding-right: 8px; padding-left:  8px; white-space: nowrap; text-align: right; background: aliceblue;}', "\n",
    'th.center  { text-align: center; }', "\n",
    'td.warning { color: red; font-weight: bold; }', "\n",
    '</style>', "\n",
    '<table frame=hsides rules=all>', "\n",
    "<tr><th colspan=$rpt_num class=\"center\">$ENV{PWD}\n",
    '';
}



if ($track_num == 1) {
  my $track_report = $tracks[0];

  
  my $h_len = 40;
  foreach my $path (keys %diff) {
    my $heading = $path;
    my $len = length $heading;
    $h_len = $len if ($len > $h_len);
  }
  #printf "%-${h_len}s ", 'TRACK';

  print "<tr><th>" if $html;
  printf "%-${h_len}s ", 'REPORT';
  
  if ($step_map{$step} eq 'dc.syn') {
    
    foreach my $path (sort keys %diff_dc) {
      foreach my $r (sort keys $diff_dc{$path}{$track_report}) {
        print "<td>" if $html;
        if($csv) {
          printf ",";
        }
        printf "%40s ", $r;
      }
      last;
    }
    
    
  } else {
    foreach my $path (sort keys %diff) {
      foreach my $r (sort keys $diff{$path}{$track_report}) {
        print "<td>" if $html;
        if($csv) {
          printf ",";
        }
        printf "%40s ", $r;
      }
      last;
    }
    
  }
  
  
  printf "\n";
  print "<tr><th>" if $html;
  printf "%-${h_len}s","STEP:$step_map{$step}";
  
  printf "\n";
  
  if ($step_map{$step} eq 'dc.syn') {
    
    foreach my $path (sort keys %diff_dc) {
      my $heading = $path;
      print "<tr><th>" if $html;
      printf "%-${h_len}s ", $heading;
      
      foreach my $r (sort keys $diff_dc{$path}{$track_report}) {
        chomp $diff_dc{$path}{$track_report}{$r};
        
        if($csv) {
          printf ",";
        }
        print "<td>" if $html;
        printf "%40s ", $diff_dc{$path}{$track_report}{$r};
        
      }
      printf "\n"; 
    }
    
  } else {
    
    foreach my $path (sort keys %diff) {
      
      my $heading = $path;
      print "<tr><th>" if $html;
      printf "%-${h_len}s ", $heading;
      
      foreach my $r (sort keys $diff{$path}{$track_report}) {
        chomp $diff{$path}{$track_report}{$r};
        
        if($csv) {
          printf ",";
        }
        print "<td>" if $html;
        printf "%40s ", $diff{$path}{$track_report}{$r};
        
      }
      printf "\n"; 
    }
    
  }
  
  if (defined($clk)) {
    foreach my $path (sort keys %diff_clk) {
      printf "\n*****$path*****\n";
      foreach my $r (sort keys $diff_clk{$path}{$track_report}) {
        printf "$r\n";
        printf "%s ", $diff_clk{$path}{$track_report}{$r};
        printf "\n";
        
      }
    }
    
  }
  
}


if ($track_num > 1) {

 
  my $h_len = 40;
  foreach my $path (keys %diff) {
    my $heading = $path;
    my $len = length $heading;
    $h_len = $len if ($len > $h_len);
  }
  print "<tr><th>" if $html;
  printf "%-${h_len}s ", 'TRACK';
  
 
  if ($step_map{$step} eq 'dc.syn') {
    
    foreach my $path (sort keys %diff_dc) {
      foreach my $t (sort keys $diff_dc{$path}) {
          print "<td>" if $html;
        if($csv) {
          printf ",";
        }
        printf "%40s ", $t;
      }
      last;
    }
    
    
  } else {
    foreach my $path (sort keys %diff) {
      foreach my $t (sort keys $diff{$path}) {
        print "<td>" if $html;
        if($csv) {
          printf ",";
        }
        printf "%40s ", $t;
      }
      last;
    }
    
  }
  
  
  printf "\n";
  print "<tr><th>" if $html;
  printf "%-${h_len}s","STEP:$step_map{$step}";
  
  printf "\n";

  if ($step_map{$step} eq 'dc.syn') {

    foreach my $path (sort keys %diff_dc) {
      
      my $heading = $path;
      print "<tr><th>" if $html;
      printf "%-${h_len}s ", $heading;
      
      foreach my $t (sort keys $diff_dc{$path}) {
        
        foreach my $v (sort values $diff_dc{$path}{$t}) {
          chomp $v;
          if($csv) {
            printf ",";
          }
          print "<td>" if $html;
          printf "%40s ",$v;
        }      
      }
      printf "\n"; 
    }

  } else {
    
    foreach my $path (sort keys %diff) {
      
      my $heading = $path;
      print "<tr><th>" if $html;
      printf "%-${h_len}s ", $heading;
      
      foreach my $t (sort keys $diff{$path}) {
        
        foreach my $v (sort values $diff{$path}{$t}) {
          chomp $v;
          if($csv) {
            printf ",";
          }
          print "<td>" if $html;
          printf "%40s ",$v;
        }      
      }
      printf "\n"; 
    }
    
  }
  
  if (defined($clk)) {
    foreach my $path (sort keys %diff_clk) {
      printf "\n*****$path*****\n";
      foreach my $t (sort keys $diff_clk{$path}) {
        foreach my $v (sort values $diff_clk{$path}{$t}) {
         
          printf "$t\n";
          printf "%s ", $v;
          printf "\n";

        }
      }
    }
  }
}
  
#printf "\n";


#foreach my $path (sort keys %diff) {
#  foreach my $t (sort keys $diff{$path}) {
#    foreach my $r (sort keys $diff{$path}{$t}) {

#      print $r,"\n";
#    }
#  }

#}



if (defined($outfile)) {
    select STDOUT;
    close(FP);

    #if (@mailusers) {
	#my $subj = defined $mailsubj ? $mailsubj : "progrpt results";
	#system("cat $outfile | mailhtml -s '$subj' @mailusers");
    #email to marvell as well
    #my @mailusers_marvell = map {MailHelper::marvellify($_)} @mailusers;
	#system("cat $outfile | mailhtml -s '$subj' @mailusers_marvell");
    #}

    #if ($firefox) {
	#system("firefox $outfile > /dev/null 2>&1");
    #}

    #if (@mailusers || $firefox) {
	#system("rm $outfile");
    #}
}




sub print_usage {
    print <<ENDF;
  USAGE:
    progrpt.pl [-step <step>] [-track] [-dir] [-help]

  OPTIONS:
    -step <step>        show the specified step result ('0' => 'defacto.rtl','1' => 'ipbu_import_compmem.rtl','2' => 'dc.syn','3' => 'invcui.pre.fp','4' => 'invcui.pre.place','5' => 'invcui.cts','6'=> 'invcui.post.route', '7' => 'invcui.post.opt'); Default is post.opt
    -track <Track name> show the specified track result;muliple track supported
    -dir <Working directory>   working directory format is <block_name>.DE<version_number>
    -user <username>    The default is working directory username
    -o <output file name> Generate the report file(optional)
    -csv                print csv format
    -html               print html format  
    -clk                print clock information
    -help               print this screen
    -num <number>       print the numbers of the latest report
  Example:
    ./tools/projflow/common/report/progrpt.pl 
    ./tools/projflow/common/report/progrpt.pl -num 2 
    ./tools/projflow/common/report/progrpt.pl -track track.210,track.210_2 


ENDF
    exit(0);

}

