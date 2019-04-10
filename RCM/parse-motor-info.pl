#!/usr/bin/perl -w

#
# The script reads lines in format
# and 
# ID INFO
#

use strict;

sub mysql_escape {
    my $str = shift;

    $str = s/[\'\"\\]/\\&/g;
}

main:{
    while(<>){
	chop;
	if(/^(\S+)\s+(.*)$/){
	    my $id = $1;
	    my $info = $2;
	    my @info = split(/\s*,\s*/, $info);
#	    printf "%s -> %s\n", $id, $info[2];
	    next unless $info[2];
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
	    }else{
		my $motor_info = $info[2];
		next if $motor_info =~ /sq\. in\./;
		next if $motor_info =~ /\d ch\./;
#		printf "-- %s -> %s (%s)\n", $id, $motor_info, join(',', @info);
		printf "INSERT IGNORE INTO rcm_ext_plans (ID) VALUES('%s');\n", $id;
		printf "UPDATE rcm_ext_plans SET MOTOR='%s' WHERE ID = '%s';\n", $motor_info, $id;
	    }
	}
    }
}
