#!/usr/bin/perl -w

#
# The script reads lines in format
# and 
# ID INFO
#

use strict;

main:{
    while(<>){
	chop;
	if(/^(\S+)\s+(.*)$/){
	    my $id = $1;
	    my $info = $2;
	    my @info = split(/\s*,\s*/, $info);
#	    printf "%s -> %s\n", $id, $info[2];
	    if($info[2] =~ /^\d?[.]\d/){
		my ($low, $up);
#		printf "%s -> %s\n", $id, $info[2]
		if($info[2] =~ /^(\d?[.]\d+)-(\d?[.]\d+)/){
		    $low = $1;
		    $up = $2;
		}elsif($info[2] =~ /^(\d?[.]\d+)/){
		    $low = $1;
		    $up = $1;
		}else{
		    printf "%s %s\n", $id, $info;
		    exit 1;
		}
		printf "-- %s -> %s - %s\n", $id, $low, $up;
		printf "INSERT IGNORE INTO rcm_ext_plans (ID) VALUES('%s');\n", $id;
		printf "UPDATE rcm_ext_plans SET E_LOW = '%s', E_UP='%s' WHERE ID = '%s';\n", $low, $up, $id;
	    }
	}
    }
}
