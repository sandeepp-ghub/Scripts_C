#!/usr/bin/env ipbu_perl
# -*- mode: cperl -*-

#stardard pragmas
use strict;
use warnings;
use 5.010;

#standard modules
use Getopt::Long qw(GetOptionsFromString);
use Pod::Usage;
use Data::Dumper;
use Tie::IxHash;
use IO::Compress::Gzip;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use Storable qw(store_fd fd_retrieve);
use POSIX;
use Cwd qw/abs_path cwd/;
use File::Basename;
use File::Path qw/make_path/;
use List::MoreUtils qw/uniq/;
use Carp;

#Cavium modules
use Path::PT;
use TimParser::PT;
use CnTimDB;
use CnTimUtils;

no warnings 'experimental::smartmatch';

#Global variables
our (%opt, %parts, %slacks, %hierarchy);
tie %parts, 'Tie::IxHash';
use vars qw($Debug);
local $Storable::Deparse = 1;
local $Storable::forgive_me = 1;

#parse command line arguments
sub parse_args {
  my ($opt_name1, $opt_name2, $msg, $rpt_count);
  #set default argument values
  $opt{debug} = 0;
  $opt{source_dir} = cwd();
  $opt{out_dir} = "split_blocks";
  $opt{depth} = 1;
  $opt{parent} = "TOP_MODULE";
  $opt{date} = `date +%m/%d`;
  $opt{date_code} = strftime("%y%m%d%H%M%S", localtime);
  chomp $opt{date};

  GetOptions(\%opt,
   	     "help",
   	     "man",
   	     "debug=i",
   	     "hier_csv=s",
   	     "report_attribute_ref_name=s",
   	     "trans_rpt=s",
  	     "period_rpt=s",
             "pulse_rpt=s",
  	     "cap_rpt=s",
	     "pins_rpt=s",
   	     "tim_db=s",
   	     "tim_rpt=s",
   	     "ctd=s",
   	     "out_dir=s",
   	     "feedthrus",
   	     "recap_only",
   	     "resplit",
   	     "always_make",
   	     "parallel",
   	     "old_hist",
   	     "old_sum",
   	     "depth=i",
   	     "parent=s",
	     "mem_tokens=i",
   	    ) or pod2usage(2);

  #print help, if requested
  pod2usage(1) if (defined $opt{help});
  pod2usage(-verbose => 2) if (defined $opt{man});

  #Mat Zeno has requested that we do not blow away a directory structure
  #rmtree $opt{out_dir} if (-d $opt{out_dir});
  make_path($opt{out_dir});

  #verify commandline options
  $rpt_count = 0;
  foreach $opt_name1 ("hier_csv", "report_attribute_ref_name", "ctd", "tim_db", "tim_rpt", "trans_rpt", "period_rpt", "pulse_rpt", "cap_rpt", "pins_rpt") {
    if (defined $opt{$opt_name1}) {
      if ($opt_name1 eq "ctd") {
	die "\n\n***ERROR: directory $opt{ctd} does not exist\n\n" if (! -d $opt{ctd});
      } else {
	die "\n\n***ERROR: file $opt{$opt_name1} does not exist\n\n" if (! -f $opt{$opt_name1});
      }
      $opt{$opt_name1} = abs_path($opt{$opt_name1});
      next if ($opt_name1 eq "hier_csv" || $opt_name1 eq "report_attribute_ref_name");
      #verify that only one type of report is being split
      $rpt_count++;
      foreach $opt_name2 ("ctd", "tim_db", "tim_rpt", "trans_rpt", "period_rpt", "pulse_rpt", "cap_rpt", "pins_rpt") {
	next if ($opt_name1 eq $opt_name2);
	$msg = "\n\n****ERROR: can not specify both -" . $opt_name1 . " & -" . $opt_name2 . "\n";
	die $msg if (defined $opt{$opt_name2});
      }
      #special handling of pin reports
      next if ($opt_name1 ~~ ["ctd", "tim_db", "tim_rpt"]);
      $opt{pin_rpt_type} = $opt_name1;
      $opt{rpt_ext} = $opt_name1;
      $opt{rpt_ext} =~ s/_rpt//;
      die "\n\n****ERROR: can not specify -$opt{pin_rpt_type} and -feedthrus\n\n" if ((defined $opt{pin_rpt_type}) && $opt{feedthrus});
    }
  }
  die "\n\n***ERROR: must specify exactly one of -ctd, -tim_db, -tim_rpt, -trans_rpt, -period_rpt, -pulse_rpt, -cap_rpt, -pins_rpt\n\n" if ($rpt_count != 1);

  if (defined $opt{tim_rpt}) {
    $opt{ctd} = $opt{out_dir} . "/" . basename($opt{tim_rpt}, (".rpt", ".rpt.gz")) . "_ctd";
    convert_to_ctd($opt{tim_rpt}, $opt{ctd});
    print "INFO: setting -ctd $opt{ctd}\n\n";
  }
  print "\n\n****WARNING: -tim_db soon to be deprecated\n" if (defined $opt{tim_db});

  die "\n\n****ERROR: must have -hier_csv or -report_attribute_ref_name option\n\n" unless (defined $opt{hier_csv} || defined $opt{report_attribute_ref_name});
  die "\n\n****ERROR: can not specify -parallel without specifying -resplit\n\n" if ($opt{parallel} && !$opt{resplit});
  die "\n\n****ERROR: can not specify -mem_tokens without specifying -parallel\n\n" if ((defined $opt{mem_tokens}) && !$opt{parallel});

  if (!defined $opt{mem_tokens}) {$opt{mem_tokens} = 10;}

  #debug printing of commandline args
  print Dumper %opt if ($opt{debug} > 0);
  dbg(1, "Finished parsing commandline args");

}

sub get_parent_inst_name {
  my $inst_name = shift;
  #dbg(10, "finding parent inst name of $inst_name");
  my ($possible_parent, @lineArray, $i, $retVal);
  $retVal = "TOP_MODULE";
  @lineArray = split(/\//, $inst_name);
  for ($i=($#lineArray - 1); $i>=0; $i--) {
    $possible_parent = join("/", @lineArray[0 .. $i]);
    if (defined $hierarchy{$possible_parent}{DEPTH}) {
      $retVal = $possible_parent;
      last;
    }
  }
  #dbg(10, "found $retVal as parent inst name of $inst_name");
  return $retVal;
}

sub get_block_name {
  my $inst_name = shift;
  my $retVal;
  #dbg(10, "finding block name of $inst_name");
  my $parent = &get_parent_inst_name($inst_name);
  $retVal = $hierarchy{$parent}{REF_NAME};
  #dbg(10, "found $retVal as block name of $inst_name");
  return $retVal;
}

sub has_children {
  my $ref_name = shift;
  dbg(4, "finding if $ref_name has children");
  my $retVal = 0;
  foreach my $inst_name (keys %hierarchy) {
    next unless (defined $hierarchy{$inst_name}{REF_NAME});
    if ($hierarchy{$inst_name}{REF_NAME} eq $ref_name) {
      if ($hierarchy{$inst_name}{CHILD_COUNT} > 0) {
 	$retVal = 1;
	dbg(4, "$ref_name has children");
 	last;
      }
    }
  }
  dbg(4, "$ref_name has no children") if ($retVal == 0);
  return $retVal;
}

# To generate this report in pt:
# report_attribute [get_cells -hierarchical -filter is_hierarchical] -attributes ref_name -nosplit
sub parse_pt_report_attribute_ref_name {
  my ($line, $fh, $cell_name, $ref_name);
  &dbg(1, "Started parsing report_attribute_ref_name $opt{report_attribute_ref_name}");
  open ($fh, "<", $opt{report_attribute_ref_name}) or die "Could not open $opt{report_attribute_ref_name}: $!\n";
  while (defined ($line = <$fh>)) {
    chomp $line;
    # Expected header:
    # Design          Object             Type      Attribute Name          Value
    if ($line =~ /^\s*\S+\s+(\S+)\s+string\s+ref_name\s+(\S+)\s*$/) {
      $cell_name = $1;
      $ref_name = $2;
      # Record cell associated with this line
      $hierarchy{$cell_name}{REF_NAME} = $ref_name;
    }
  }
  close $fh or die "Could not close $opt{report_attribute_ref_name}: $!\n";
  $hierarchy{"TOP_MODULE"}{REF_NAME} = "TOP_MODULE";
  &dbg(1, "Finished parsing report_attribute_ref_name $opt{report_attribute_ref_name}");
}

#parse hier csv
sub parse_pt_hier_csv {
  my ($line, $fh, @lineArray);
  &dbg(1, "Started parsing hier_csv $opt{hier_csv}");
  open ($fh, "<", $opt{hier_csv}) or die "Could not open $opt{hier_csv}: $!\n";
  $line = <$fh>;		#skip first line
  while (defined ($line = <$fh>)) {
    chomp $line;
    @lineArray = split(/,\s*/, $line);
    if ($lineArray[1] ne "custom") { #skip customs
      $hierarchy{$lineArray[0]}{BLOCK_TYPE} = $lineArray[1];
      $hierarchy{$lineArray[0]}{REF_NAME} = $lineArray[2];
      if ($lineArray[0] eq "TOP_MODULE") {
	$hierarchy{$lineArray[0]}{REF_NAME} = "TOP_MODULE";
      }
    }
  }
  close $fh or die "Could not close $opt{hier_csv}: $!\n";
  &dbg(1, "Finished parsing hier_csv $opt{hier_csv}");
}

# Finishes hierarchy hash.  When run, hierarchy musthave REF_NAME fields populated.
# Originally was part of parse_pt_hier_csv, but when generalizing to use report_attribute_ref_name made sense to separate this out.
sub clean_hierarchy {
  my ($inst_name, $parent, @buckets);
  $hierarchy{TOP_MODULE}{DEPTH}= 0;
  $hierarchy{TOP_MODULE}{PARENT} = "NA";
  $hierarchy{TOP_MODULE}{PARENT_REF} = "NA";
  $hierarchy{TOP_MODULE}{CHILD_COUNT} = 0;
  foreach $inst_name (sort keys %hierarchy) {
    next if ($inst_name eq "TOP_MODULE");
    $parent = &get_parent_inst_name($inst_name);
    $hierarchy{$inst_name}{DEPTH} = $hierarchy{$parent}{DEPTH} + 1;
    $hierarchy{$inst_name}{PARENT} = $parent;
    $hierarchy{$inst_name}{PARENT_REF} = &get_block_name($inst_name);
    $hierarchy{$inst_name}{CHILD_COUNT} = 0;
    $hierarchy{$parent}{CHILD_COUNT}++;
    &dbg(3, "$inst_name child of $parent ($hierarchy{$inst_name}{PARENT_REF}) at depth $hierarchy{$inst_name}{DEPTH}");
  }

  #prune hierarchy
  $hierarchy{$opt{parent}}{REF_NAME} = "TOP_MODULE";
  $hierarchy{$opt{parent}}{DEPTH} = 0;
  $hierarchy{$opt{parent}}{PARENT_REF} = "NA";
  foreach $inst_name (sort keys %hierarchy) {
    next if ($inst_name eq "TOP_MODULE");
    if (($hierarchy{$inst_name}{DEPTH} != $opt{depth}) || ($hierarchy{$inst_name}{PARENT_REF} ne $opt{parent})) {
      &dbg(3, "pruning $inst_name because its parent is $hierarchy{$inst_name}{PARENT_REF} and depth is $hierarchy{$inst_name}{DEPTH}");
      delete $hierarchy{$inst_name};
    } else {
      &dbg(3, "keeping $inst_name because its parent is $hierarchy{$inst_name}{PARENT_REF} and depth is $hierarchy{$inst_name}{DEPTH}");
    }
  }

  #initialize data structures for storing report data
  if (defined $opt{pin_rpt_type}) {
    @buckets = ("top");
    foreach $inst_name (sort keys %hierarchy) {
      push(@buckets, $hierarchy{$inst_name}{REF_NAME}) if ($hierarchy{$inst_name}{REF_NAME} ne "TOP_MODULE");
    }
    foreach my $part (uniq @buckets) {
      $parts{$part} = "";
      $slacks{$part} = [];
    }
  } else {
    my @extensions = ("internal", "interface");
    push(@extensions, "both") if ($opt{resplit});
    push(@extensions, "feedthrus") if ($opt{feedthrus});
    my @buckets = ("top", "top-non_interface");
    foreach $inst_name (sort keys %hierarchy) {
      next if ($inst_name eq "TOP_MODULE");
      foreach my $extension (@extensions) {
 	push(@buckets, "$hierarchy{$inst_name}{REF_NAME}-${extension}");
      }
    }
    foreach my $part (uniq @buckets) {
      if (defined $opt{ctd}) {
 	$parts{$part} = CnTimDB->new(ctd => "$opt{out_dir}/${part}_ctd", debug => $opt{debug});
      } else {
 	$parts{$part} = [];
      }
      $slacks{$part} = [];
    }
  }
  &dbg(1, "Finished cleaning hierarchy");
}

sub find_buckets {
  my $path = shift;
  my ($block, $previous_block, $end_block, @blocks, @buckets, $point, $i);
  $block = &get_block_name($path->startpoint());
  $end_block = &get_block_name($path->endpoint());
  #dbg(10, "start->$block end->$end_block");
  push(@blocks, $block);
  if ($opt{feedthrus}) {
    $previous_block = $block;
    my @points = get_path_points($path);
    foreach $point (@points) {
      $block = &get_block_name($point);
      if ($block ne $previous_block) {
	#dbg(10, "possible feedthru $block due to point $point");
 	push(@blocks, $block);
 	$previous_block = $block;
      }
    }
  }
  push(@blocks, $end_block) if ($block ne $end_block);
  if (&get_parent_inst_name($path->startpoint()) eq &get_parent_inst_name($path->endpoint())) {
    if ($block ne "TOP_MODULE") {
      @buckets = ("${block}-internal");
      push(@buckets, "${block}-both") if ($opt{resplit});
    } else {
      @buckets = ("top-non_interface");
    }
  } else {
    @buckets = ("top");
    for ($i=0; $i<=$#blocks; $i++) {
      $block = $blocks[$i];
      if ($block ne "TOP_MODULE") {
 	push(@buckets, "${block}-both") if ($opt{resplit});
 	if (($i==0) || ($i==$#blocks)) { #first & last blocks are interface, all others are interface
 	  push(@buckets, "${block}-interface");
 	} else {
 	  push(@buckets, "${block}-feedthrus");
 	}
      }
    }
  }
  @buckets = uniq @buckets;
  if ($opt{debug} > 4) {
    my $start = $path->startpoint();
    my $end = $path->endpoint();
    dbg(4, "path from $start to $end goes into $#buckets blocks");
  }
  return @buckets
}

sub parse_timing_db {
  &dbg(1, "Started parsing timing db $opt{tim_db}");
  my ($fh, $path);
  if ((-s $opt{tim_db}) > 0) {
    open $fh, "/usr/local/bin/gzip -dc $opt{tim_db} |" or die "\n\n***ERROR: Could not open $opt{tim_db} for reading: $!\n\n";
    my $cached_parser = fd_retrieve($fh);
    close $fh or die "\n\n***ERROR: Could not close $opt{tim_db} for writing: $!\n\n";
    foreach $path (@{$cached_parser->{PATHS}}) {
      my_call_back_db($path, $cached_parser);
    }
  }
  &dbg(1, "Finished parsing timing db $opt{tim_db}");
}

sub parse_timing_ctd {
  &dbg(1, "Started parsing ctd $opt{ctd}");
  my $ctd = CnTimDB->new(ctd => $opt{ctd}, debug => $opt{debug});
  my $default_timparser = $ctd->get_timparser();
  foreach my $part (keys %parts) {
    $parts{$part}->set_timparser($default_timparser);
  }
  $ctd->parse_ctd(\&my_call_back_db);
  &dbg(1, "Finished parsing ctd $opt{ctd}");
}

sub my_call_back_db {
  my ($path, $timparser) = @_;
  my @buckets = &find_buckets($path);
  foreach my $part (@buckets) {
    push(@{$slacks{$part}}, $path->slack());
    if (defined $opt{ctd}) {
      $parts{$part}->add_path($path);
    } else {
      push(@{$parts{$part}}, $path);
    }
  }
}

sub convert_ns {
  my $ns = shift;
  if ($ns <= -1) {
    $ns = int($ns) . "ns";
  } else {
    $ns = int($ns * 1000) . "ps";
  }
  return $ns;
}

sub old_text_histogram {
  #####use List::MoreUtils qw( minmax );
  my($fh, $valuesRef) = @_;
  my(%bin, $limit, $value, @limits, @values, $limit_string, $other_limit);
  @values = @{$valuesRef};
  @limits = (-10.000, -5.000, -1.000, -0.750, -0.500, -0.250, -0.100, -0.050, -0.010, -0.004, 0.000);
  push(@limits, 9**9**9);
  foreach $limit (@limits) {
    $bin{$limit} = 0;
  }
  foreach $value (@values) {
    foreach $limit (sort { $a <=> $b } keys %bin) {
      if ($limit > $value) {
     	$bin{$limit}++;
      	undef $value;
      	last;
      }
    }
    $bin{$limit}++ if (defined $value) ; #put the remaining in the last bucket
  }
  printf $fh ("%18s| %5s |\n", '', $opt{date});
  print $fh '-' x 27 . "\n";
  for (my $i=0; $i <= $#limits; $i++) {
    $limit = $limits[$i];
    $limit_string = &convert_ns($limits[$i]);
    if ($i == 0) {
      printf $fh ("%6s <   %6s | %5d |\n", '', $limit_string, $bin{$limit});
    } elsif ($i < $#limits) {
      $other_limit = &convert_ns($limits[$i - 1]);
      printf $fh ("%6s <-> %6s | %5d |\n", $other_limit, $limit_string, $bin{$limit});
    } else {
      printf $fh ("%6s >   %6s | %5d |\n", $other_limit, '', $bin{$limit});
    }
  }
}

sub write_parts {
  &dbg(1, "Started writing parts files");
  my ($slack, $part, $sum_fh, $rpt_fh, $db_fh, $path, $parser);
  $Storable::Deparse = 1;
  if (defined $opt{ctd}) {
    foreach $part (keys %parts) {
      dbg(2, "storing $part");
      $parts{$part}->store_bucket();
      $parts{$part}->change_mode("read");
      open $sum_fh , "|/usr/local/bin/gzip -c9 > $opt{out_dir}/${part}.sum.gz";
      if (!$opt{recap_only}) {
	 open $rpt_fh , "|/usr/local/bin/gzip -c9 > $opt{out_dir}/${part}.rpt.gz";
      }
      $path = $parts{$part}->get_path();
      while (defined $path) {
	 if ($opt{old_sum}) {
       	  print $sum_fh $path->summary();
       	} else {
       	  print $sum_fh get_new_path_summary($path);
       	}
       	if (!$opt{recap_only}) {
       	  if ($path->{_classification} eq "phase") {
       	    print $rpt_fh "INFO: PHASE ADJUSTED SLACK\n";
       	  }
       	  print $rpt_fh $path->record();
       	}
       	$path = $parts{$part}->get_path();
      }
      close $sum_fh;
      if (!$opt{recap_only}) {
	 close $rpt_fh;
      }
    }
  } else {
    foreach $part (keys %parts) {
       dbg(2, "Writing files for $part");
       open $db_fh , "|/usr/local/bin/gzip -c9 > $opt{out_dir}/${part}.db.gz";
       open $sum_fh , "|/usr/local/bin/gzip -c9 > $opt{out_dir}/${part}.sum.gz";
       if (!$opt{recap_only}) {
	 open $rpt_fh , "|/usr/local/bin/gzip -c9 > $opt{out_dir}/${part}.rpt.gz";
      }
       $parser = new TimParser::PT();
       foreach $path (@{$parts{$part}}) {
	 push(@{$parser->{PATHS}}, $path);
  	if ($opt{old_sum}) {
  	  print "\n\n****WARNING: -old_sum flag is soon to be deprecated\n\n";
  	  print $sum_fh $path->summary();
  	} else {
  	  print $sum_fh get_new_path_summary($path);
  	}
  	if (!$opt{recap_only}) {
  	  if ($path->{_classification} eq "phase") {
 	    print $rpt_fh "INFO: PHASE ADJUSTED SLACK\n";
 	  }
  	  print $rpt_fh $path->record();
  	}
      }
       store_fd $parser, $db_fh;
       close $db_fh;
       if (!$opt{recap_only}) {
	 close $rpt_fh;
      }
     }
   }
  &dbg(1, "Finished writing parts files");
}

sub summary_print {
  &dbg(1, "printing summaries\n");
  my ($file_name, $fh, $part, $hist_fh);
  $file_name = "$opt{out_dir}/SUMMARY.gz";
  $fh = new IO::Compress::Gzip($file_name) or die "Could not open $file_name : $!";
  print $fh text_summary(\%slacks, "slack");
  close $fh or die "Could not close $file_name : $!";
  &dbg(1, "printing histograms\n");
  foreach $part (keys %parts) {
    open $hist_fh , "|/usr/local/bin/gzip -c9 > $opt{out_dir}/${part}.hist.gz";
    if (defined $opt{old_hist}) {
      print "\n\n****WARNING: -old_hist flag is soon to be deprecated\n\n";
      &old_text_histogram($hist_fh, $slacks{$part});
    } else {
      print $hist_fh text_histogram(\@{$slacks{$part}}, {fixed=>"SLACK"});
    }
    close $hist_fh;
  }
  &dbg(1, "finished printing histograms\n");
}

#optionally call derivative of the same command on reports produced so far
#to resplit reports which have already been split
sub resplit {
  my ($cmd, $depth, $instance, $to_split, $csh_script, $fh, $job_name, $log_name, %split_blocks, $qqstat_report, $part, $rpt_type, $hierarchy_flag);
  my (@buckets_to_resplit, $bucket);
  &dbg(1, "Begining resplitting");
  if (defined $opt{pin_rpt_type}) {
    @buckets_to_resplit = keys %parts;
  } else {
    @buckets_to_resplit = map {basename($_, "-both")} grep {/-both/} keys %parts;
  }
  $depth = $opt{depth} + 1;
  if ($opt{parallel}) {
    mkdir "$opt{out_dir}/parallel";
  }
  foreach $bucket (@buckets_to_resplit) {
    next if ($bucket eq "TOP_MODULE");
    &dbg(1, "may need to resplit $bucket");
    next unless &has_children($bucket);
    &dbg(1, "need to resplit $bucket");
    if (!$opt{always_make}) {
      if (defined $opt{pin_rpt_type}) {
	next unless ((scalar @{$slacks{${bucket}}}) > 0);
      } else {
	next unless ((scalar @{$slacks{"${bucket}-both"}}) > 0);
      }
    }
    $hierarchy_flag = "-hier_csv $opt{hier_csv}" if defined $opt{hier_csv};
    $hierarchy_flag = "-report_attribute_ref_name $opt{report_attribute_ref_name}" if defined $opt{report_attribute_ref_name};
    $cmd = abs_path($0) . " -resplit -debug $opt{debug} $hierarchy_flag -depth $depth -parent $bucket -out_dir $bucket";
    if ($opt{always_make}) {
      $cmd .= " -always_make";
    }
    if (defined $opt{feedthrus}) {
      $cmd .= " -feedthrus";
    }
    if (defined $opt{parallel}) {
      $cmd .= " -parallel";
    }
    if (defined $opt{recap_only}) {
      $cmd .= " -recap_only";
    }
    if (defined $opt{pin_rpt_type}) {
      $cmd .= " -$opt{pin_rpt_type} ${bucket}.$opt{rpt_ext}.rpt.gz";
    } elsif (defined $opt{ctd}) {
      $cmd .= " -ctd ${bucket}-both_ctd";
    } elsif (defined $opt{tim_db}) {
      $cmd .= " -tim_db ${bucket}-both.db.gz";
    }
    if (!$opt{parallel}) {
      print "SERIAL RESPLIT: cd $opt{out_dir}; $cmd; cd ..\n";
      system("cd $opt{out_dir}; $cmd; cd ..");
    } else {
      $csh_script = "$opt{out_dir}/parallel/${bucket}.resplit.csh";
      open($fh, ">", $csh_script) or die "\n\n***ERROR: Could not open $csh_script for writing: $!\n\n";
      print $fh "#!/bin/csh\n";
      print $fh "setproj $ENV{PHYSPROJ}\n";
      print $fh "cd $opt{out_dir}\n";
      print $fh "touch $opt{out_dir}/parallel/.START.${bucket}.resplit.csh\n";
      print $fh "$cmd\n";
      print $fh "touch $opt{out_dir}/parallel/.DONE.${bucket}.resplit.csh\n";
      close $fh or die "\n\n***ERROR: Could not close $csh_script from writing: $!\n\n";
      chmod 0755, $csh_script;
      $job_name = "JOB_${bucket}_resplit_$opt{date_code}";
      $log_name = dirname($csh_script) . "/" . basename($csh_script, ".csh") . ".parallel.log";
      $cmd = "qsub -N $job_name -sync no -q pnr -v project -l mem_tokens=$opt{mem_tokens} -o $log_name $csh_script";
      print "INFO: PARALLEL RESPLIT: $cmd\n";
      system($cmd);
      system("touch $opt{out_dir}/parallel/.LAUNCH.${bucket}.resplit.csh");
      $split_blocks{$bucket} = 1;
    }
  }
  if (defined $opt{parallel}) {
    while (scalar keys %split_blocks > 0) {
      foreach $bucket (keys %split_blocks) {
 	if (!-f "$opt{out_dir}/parallel/.DONE.${bucket}.resplit.csh") {
 	  &dbg(1, "WAITING ON $bucket");
 	} else {
 	  delete $split_blocks{$bucket};
 	  print "INFO: JOB_${bucket}_resplit_$opt{date_code} has completed. Remaining jobs: " . (scalar keys %split_blocks) . "\n";
 	}
      }
      sleep(5);
      $qqstat_report = `qqstat`;
      foreach $bucket (keys %split_blocks) {
	$job_name = "JOB_${bucket}_resplit_$opt{date_code}";
	if ($qqstat_report =~ m/$job_name/) {
 	  &dbg(1, "WAITING on $job_name");
 	} else {
 	  delete $split_blocks{$bucket};
 	  print "INFO: JOB_${bucket}_resplit_$opt{date_code} has completed. Remaining jobs: " . (scalar keys %split_blocks) . "\n";
 	}
      }
      sleep(5);
    }
  }
  &dbg(1, "Finished resplitting");
}

sub cleanup {
  if (!defined $opt{pin_rpt_type}) {
    system("/bin/rm -Rf $opt{out_dir}/*-both*\n");
    if ($opt{recap_only}) {
      foreach my $part (keys %parts) {
 	my $dir = $parts{$part}->get_directory();
 	&dbg(1, "recap_only cleanup of $dir\n");
 	system("/bin/rm -Rf $dir");
      }
      system("/bin/rm -Rf $opt{ctd}") if (defined $opt{tim_rpt});
    }
  } elsif ($opt{recap_only}) {
    system("/bin/rm -Rf $opt{out_dir}/*.$opt{rpt_ext}.rpt.gz");
  }
}

sub dbg {
  my ($debug_limit, $msg) = @_;
  if ($opt{debug} >= $debug_limit) {
    if ($opt{debug} > 2) {
      print "DEBUG: (" . scalar localtime() . ") $msg \n";
    } else {
      print "DEBUG: $msg\n";
    }
  }
}

sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

sub parse_pin_rpt {
  my ($rpt, $rpt_type, $hist_buckets_type, $summary_type, $line, $header, $fh, $hist_fh, $value_index, $pin_index, @lineArray, $block, $file_name, $part, $new_line, $cvm_trans_format);
  $cvm_trans_format = 0;
  $rpt_type = $opt{pin_rpt_type};
  $rpt = $opt{$rpt_type};
  &dbg(1, "Begining to parse $rpt");
  if ($opt{$rpt_type}=~ m/.gz$/) {
    $fh = new IO::Uncompress::Gunzip $rpt or die "Unable to open log $rpt : !$\n";
  } else {
    open ($fh, "<", $rpt) or die "Could not open $rpt: $!";
  }
  #trim header & determine report format
  while (defined ($line = <$fh>)) {
    next if ($line =~ m/^Error:/);
    $header .= $line;
    if ($line =~ m/\-\-\-\-/) {
      last;
    }
  }
  $hist_buckets_type = "SLACK";
  $summary_type = "slack";
  if ($rpt_type eq "cap_rpt") {
    $pin_index = 0;
    $value_index = 3;
    $hist_buckets_type = "CAP_SLACK";
  } elsif ($rpt_type eq "period_rpt") {
    $pin_index = 0;
    $value_index = 5;
    $hist_buckets_type = "SLACK";
  } elsif ($rpt_type eq "pulse_rpt") {
    $pin_index = 0;
    $value_index = 4;
    $hist_buckets_type = "SLACK";
  } elsif ($rpt_type eq "pins_rpt") {
    $pin_index = 0;
    $value_index = 1;
    $hist_buckets_type = "CAP";
    $summary_type = "trans";
  } elsif ($rpt_type eq "trans_rpt") {
    if ($header =~ m/\*\*\*/) {
      $value_index = 3;
      $pin_index = 0;
    } else {
      $cvm_trans_format = 1;
      $pin_index = 6;
    }
  }
  foreach $part (keys %parts) {
    $parts{$part}=$header;
  }
  while (defined ($line = <$fh>)) {
    if ($line =~ m/^\s*$/) {
      next if ($rpt_type ne "pulse_rpt");
      $rpt_type = "NADA";
      $header = $line;
      while (defined ($line = <$fh>)) {
	$header .= $line;
	if ($line =~ m/\-\-\-\-/) {
	  last;
	}
      }
      foreach $part (keys %parts) {
	$parts{$part}.=$header;
      }
    }
    next if ($line =~ m/\(MET\)/);
    $new_line = &trim($line);
    @lineArray=split(/\s+/, $new_line);
    next if ($#lineArray < 1);
    $block = &get_block_name($lineArray[$pin_index]);
    if ($block eq "TOP_MODULE") {$block = "top";}
    $parts{$block} .= $line;
    if ($rpt_type eq "pins_rpt") {
      push(@{$slacks{$block}}, 1);
    } elsif ($cvm_trans_format != 1) {
      push(@{$slacks{$block}}, $lineArray[$value_index]);
    } else {
      my $trans_limit = $lineArray[10];
      $trans_limit =~ s/failure_limit://;
      push(@{$slacks{$block}}, ($trans_limit - $lineArray[0]));
    }
  }
  close $fh or die "Could not close $rpt: $!";
  &dbg(1, "Finished parsing $rpt");
  &dbg(1, "Writing split reports");
  foreach $part (keys %parts) {
    if ($opt{always_make} || ((scalar @{$slacks{$part}}) > 0)) {
      $file_name = "$opt{out_dir}/${part}.$opt{rpt_ext}.rpt.gz";
      $fh = new IO::Compress::Gzip($file_name) or die "Could not open $file_name: $!";
      print $fh $parts{$part};
      close $fh or die "Could not close $file_name: $!";
      open $hist_fh , "|/usr/local/bin/gzip -c9 > $opt{out_dir}/${part}.$opt{rpt_ext}.hist.gz";
      if ($opt{old_hist}) {
	print "\n\n****WARNING: -old_hist flag is soon to be deprecated\n\n";
	&old_text_histogram($hist_fh, $slacks{$part});
      } else {
	print $hist_fh text_histogram(\@{$slacks{$part}}, {fixed=>$hist_buckets_type});
      }
      close $hist_fh;
    }
  }
  &dbg(1, "Finished writing split reports");
  $file_name = "$opt{out_dir}/SUMMARY.$opt{rpt_ext}.gz";
  $fh = new IO::Compress::Gzip($file_name) or die "Could not open $file_name : $!";
  print $fh text_summary(\%slacks, $summary_type);
  close $fh or die "Could not close $file_name : $!";
  &dbg(1, "Finished writing summary");
}


#main work horse
sub main {
  &parse_args();
  if (defined $opt{hier_csv} && defined $opt{report_attribute_ref_name}) {
    die "Incompatible arguments hier_csv and report_attribute_ref_name, should only get hierarchy from one place";
  }
  if (defined $opt{hier_csv}) {
    &parse_pt_hier_csv();
  }
  if (defined $opt{report_attribute_ref_name}) {
    &parse_pt_report_attribute_ref_name();
  }
  clean_hierarchy();
  if (defined $opt{pin_rpt_type}) {
    &parse_pin_rpt();
  } else {
    if (defined $opt{ctd}) {
      &parse_timing_ctd();
    } elsif (defined $opt{tim_db}) {
      &parse_timing_db();
    }
    &write_parts();
    &summary_print();
  }
  &resplit() if ($opt{resplit});
  &cleanup();
  return 0;
}

exit main( @ARGV );

__END__

=head1 NAME

  pt_split_blocks_from_report.pl -- split pt report into block internal reports.

=head1 SYNOPSIS

  pt_split_blocks_from_report.pl
     (-hier_csv <hier_csv_file> or -report_attribute_ref_name <report_attribute_ref_name_file>)
     -ctd <timing_ctd> | -tim_rpt <timing_rpt_file> | -tim_db <timing_db_file> |
     -trans_rpt <max_trans_rpt_file> | -period_rpt <min_period_rpt_file> | -pulse_rpt <min_pulse_width_rpt_file> | -cap_rpt <max_cap_rpt_file> | -pins_rpt <pins_rpt_file>
     [-out_dir <output_directory>] [-feedthrus] [-always_make] [-recap_only]
     [-resplit [-parallel [-mem_tokens <num_tokens>]]] [-old_hist] [-old_sum] [-debug <debug_level>]

  pt_multi_filter.pl -help

  pt_multi_filter.pl -man

=head1 REQUIRED ARGUMENTS

  Required Arguments:
   -hier_csv <hier_csv_file>            Hierarchy csv generated from primetime run
   -report_attribute_ref_name <file>    ref_name report from primetime run
                                        (alternative to -hier_csv)

  Additonally, one and only one of the following arguments must be specified:
   -ctd        <timing_directory>             CnTimDB directory
   -tim_rpt    <timing_rpt_file>              Primetime timing report
   -tim_db     <timing_database_file>         SOON TO BE DEPRECATED: Storable perl object of parsed primetime timing report
   -trans_rpt  <max_trans_rpt_file>           Primetime max trans report
   -period_rpt <min_period_rpt_file>          Primetime min period report
   -pulse_rpt  <min_pulse_width_rpt_file>     Primetime min pulse width report
   -cap_rpt    <max_cap_rpt_file>             Primetime max cap report
   -pins_rpt   <pins_rpt_file>                Newline delimited list of pins, header is required

=head1 OPTIONAL ARGUMENTS

  Optional arguments:

   -out_dir <directory>   Directory to write output to (defaults to "split_blocks")

   -resplit               Invokes script multiple times to generate directory hierarchy of split reports

   -always_make           generate empty files for blocks with no errors (normally only generates files for blocks with errors)

   -feedthrus             generate additional reports for paths which pass thru multiple blocks

   -recap_only            only write SUMMARY, *.sum.gz, & *.hist.gz files and nothing else

   -old_hist              SOON TO BE DEPRECATED: produce old format histograms

   -old_sum               SOON TO BE DEPRECATED: produce old format .sum files

   -parallel              kick off resplitting jobs in parallel using cluster
                          requires -resplit flag to be set

   -mem_tokens            number of mem_tokens to use for parallel resplitting jobs
                          Defaults to 10
                          requires -parallel -resplit flags to be set

   -help                  brief help message

   -man                   full documentation

   -debug <debug_level>   print debug information

=head1 HIDDEN OPTIONS

  Options which are unsupported for direct user invocation
    -parent <parent_inst_name>    Instance name of parent block whose sub-blocks to split (must be listed in hier_csv. defaults to all parents)
    -depth  <integer>             depth of sub-blocks to split (defaults to 0)

=head1 DESCRIPTION

  B<pt_split_blocks_from_report.pl> will read in a hierarchy specifying csv and either a primetime generated
  timing report or a primetime generated trans report, and split the input report into sub-reports for each
  top-level sub-block. Optionally recursively calls its self to split each of the sub-block reports

  If hier_csv is not available, instead you can use report_attribute_ref_name , generated by the following pt command:

    report_attribute [get_cells -hierarchical -filter is_hierarchical] -attributes ref_name -nosplit > your_report_attribute_ref_name_file
