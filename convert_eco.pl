#!/bin/perl
    print "set_db eco_batch_mode true\n";
    while (<STDIN>) {
        print "# ", $_;
        chomp;
        @_ = split;
        if (/size_cell/) {
            print "eco_update_cell -insts ", $_[1], " -cells ", $_[2], "\n";
        }
        if (/insert_buffer/) {
            print "eco_add_repeater -pins ", $_[1], " -cell ", $_[2], " -name ", $_[6], " -new_net_name ", $_[4],  "\n";
        }
    }
    print "set_db eco_batch_mode false\n";
