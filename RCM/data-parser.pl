#!/usr/bin/perl -w

use strict;

use Config::IniFiles;
use HTML::Parser ();
use LWP::UserAgent;
use File::Basename;
use DBI;

my $hostname = 'rcmmagazine.com';
my $agent_id = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0) ';
my $raw_data_table = 'rcm_raw_plans';
my $ua;
my $position;
my $id;
my %info;

my $debug = 0;

sub usage {
    printf STDERR "Usage: $0 [-d] database-name file1 ...\n";
}

sub start {
    my ($t, $a) = @_;

    printf "Start: %s\n", $t if $debug;
    if($position == 0){
	if(lc($t) eq 'center'){
	    $position = 1;
	}
    }else{
	if(lc($t) eq 'img'){
	    if($a->{src} =~ m{/store/media/(pl-.*)}){
		$info{IMAGE} = $1;
	    }
	}
    }
}

sub end {
#    printf "End: %s\n", lc(shift);
}

sub text {
    my($text) = @_;
    $text =~ s{&nbsp;}{ }g;
    if($text !~ /^\s*$/){
	if($debug){
	    printf "Text: %s\n", $text unless $text =~ /^\s*$/;
	}
	if($position == 1){
	    if($text =~ /PLAN/){
		if($text =~ m{PLAN (\S+) cat.\s?(.*)}){
		    $info{ID} = $1;
		    $info{CATEGORY} = trim($2);
		}else{
		    $info{CATEGORY} = $text;
		}
		$position++;
	    }
	}elsif($position == 2){
	    $info{NAME} = $text;
	    $position++;
	}elsif($position == 3){
	    if($text =~ /Our price (.*)/i){
		$info{PRICE} = $1;
		$position++;
	    }else{
		$info{NAME} .= $text;
	    }
	}elsif($position == 4){
	    $info{AUTHOR} = trim($text);
	    $position++;
	}elsif($position == 5){
	    $text =~ s{\s+(.*),\n}{$1};
	    $info{INFO} = $text;
	    $position++;
	}elsif($position == 6){
	    if($text =~ /Issue:/){
		$position++;
	    }else{
		$info{NOTE} .= trim($text); 
	    }
	}elsif($position == 7){
	    $info{ISSUE} = trim($text);
	    $position++;
	}
    }
}

sub trim {
    my $txt = shift;

    $txt =~ s/^\s*(.*)\s*$/$1/;
    $txt =~ s/(.*),$/$1/;

    return $txt;
}

main: {
    my $cfg = new Config::IniFiles( -file => "$ENV{HOME}/.my.cnf" );
    my $mysql_user = $cfg->val('client', 'user');
    my $mysql_password = $cfg->val('client', 'password');
    my $mysql_db = shift || usage;
    if($mysql_db eq '-d'){
	$debug = 1;
	$mysql_db = shift || usage;
    }

    my $db = DBI->connect("DBI:mysql:database=$mysql_db;host=localhost",
			  $mysql_user, $mysql_password,
			  {'RaiseError' => 1});

    $db->do("CREATE TABLE IF NOT EXISTS $raw_data_table (".
	    " ID varchar(32) NOT NULL,".
	    " NAME varchar(64) NOT NULL,".
	    " INFO varchar(255) NOT NULL,".
	    " AUTHOR varchar(64) NOT NULL,".
	    " PRICE varchar(8) NOT NULL,".
	    " ISSUE varchar(32) NOT NULL,".
	    " CATEGORY varchar(10) NOT NULL,".
	    " FILE varchar(32) NOT NULL,".
	    " NOTE varchar(255) NOT NULL,".
	    " IMAGE varchar(32) NOT NULL,".
	    " PRIMARY KEY (ID))");

    while(my $file = shift){
	# Create parser object
	my $p = HTML::Parser->new(api_version => 3,
				  start_h => [\&start, "tagname, attr"],
				  end_h   => [\&end, "tagname"],
				  text_h   => [\&text, "text"],
				  marked_sections => 1
				  );
	printf "File: %s\n", $file if $debug;
	$position = 0;
	%info = (FILE => $file, NOTE => '');
	$p->parse_file($file);
	if($debug){
	    print "************************\n";
	    print join("\n", map { $_." => ".$info{$_} } sort (keys %info)), "\n";
	}
	if($info{ID}){
	    $db->do("REPLACE INTO $raw_data_table (".join(',', keys %info).") ".
		    " VALUES(".join(',', map {'?'} keys %info).")", 
		    undef, values(%info));
	}else{
	    printf "File %s does not have ID\n", $file;
	}
    }
}
