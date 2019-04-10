#!/usr/bin/perl -w -i.BAK

use strict;

while(<>){
	s/\r\n$//;
	s/\n$//;
	s/\\"/"/g;
	s/\\$//;
	next if /^<.?DIV.*>/;
	next if /^<.?TD.*>/;
	next if /^<.?TR.*>/;
	last if /^} else {/;
	print $_, "\n";
	print "<!--#include virtual=\"hotlog.html\" -->\n" if /^<BODY>/;
}
print "</BODY>\n";
print "</HTML>\n";
