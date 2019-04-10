#!/usr/bin/perl -w

use strict;
use HTML::Parser ();
use LWP::UserAgent;
use File::Basename;

my $hostname = 'rcmmagazine.com';
my $agent_id = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0) ';
my $ua;

sub start {
    my ($t, $a) = @_;

#    printf "Tag: %s\n", $t;
    if(lc($t) eq 'img'){
	if($a->{src} =~ m{/store/media/pl}){
	    printf "IMG: %s\n", join(',', map {$_.' => '.$a->{$_}} keys %$a);
	    my $r = HTTP::Request->new(GET => 'http://'.$hostname.$a->{src});
	    my $res = $ua->request($r);
	    if($res->is_success){
		my $f = basename($a->{src});
		open PL, ">$f" or die "Can't open file $f:$!";
		syswrite(PL, $res->content);
		close PL;
	    }
	}
    }
}

sub end {
#    printf "Tag Stop: %s\n", lc(shift);
}

main: {
    $ua = LWP::UserAgent->new(agent => $agent_id, keep_alive => 1);

    while(my $file = shift){
	# Create parser object
	my $p = HTML::Parser->new(api_version => 3,
				  start_h => [\&start, "tagname, attr"],
				  end_h   => [\&end,   "tagname"],
				  marked_sections => 1
				  );
	printf "File: %s\n", $file;
	$p->parse_file($file);
    }
}
