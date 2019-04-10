#!/usr/bin/perl -w

use strict;
use HTML::Parser ();
use LWP::UserAgent;

my $hostname = 'rcmmagazine.com';
my $agent_id = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)';

sub start {
    my ($t, $a) = @_;
#    printf "start(%s,{%s})...\n", $t, join(',', map{$_."=>".$a->{$_}}keys %$a);
    if($t eq 'a'){
	if($a->{href} =~ /item=plans:(.*)/){
	    my $plan_id = $1;
#	    printf "Retrieve: %s\n", $a->{href};
	    printf "ID = %s\n", $plan_id;

	    my $ua = LWP::UserAgent->new;
	    $ua->agent($agent_id);

	    # Create a request
	    my $req = HTTP::Request->new(GET => 'http://'.$hostname.$a->{href});

	    # Pass request to the user agent and get a response back
	    my $res = $ua->request($req);

	    # Check the outcome of the response
	    if($res->is_success){
		open PL, ">$plan_id.html" or die "Can't open file $plan_id.html. $!";
		print PL $res->content;
		close PL;
	    }else{
		print $res->status_line, "\n";
	    }
	}
    }
}

sub img {
    my ($t, $a) = @_;
    if($t eq 'img'){
	printf "start(%s,{%s})...\n", $t, join(',', map{$_."=>".$a->{$_}}keys %$a);
    }
}

sub end {
    my ($t) = @_;
#    printf "end(%s)...\n", $t;
}

main: {
    while(my $file = shift){
	my $p = HTML::Parser->new(api_version => 3,
			      start_h => [\&start, "tagname, attr"],
			      end_h   => [\&end,   "tagname"],
			      marked_sections => 1,
			      );
	printf "File: %s\n", $file;
	$p->parse_file($file);
    }
}

__END__
# Create a user agent object

use LWP::UserAgent;
$ua = LWP::UserAgent->new;
$ua->agent("MyApp/0.1 ");

         # Create a request
my $req = HTTP::Request->new(POST => 'http://search.cpan.org/search');
$req->content_type('application/x-www-form-urlencoded');
$req->content('query=libwww-perl&mode=dist');

         # Pass request to the user agent and get a response back
my $res = $ua->request($req);

         # Check the outcome of the response
if ($res->is_success) {
    print $res->content;
}
else {
    print $res->status_line, "\n";
}


