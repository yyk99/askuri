#!/usr/bin/perl -w

#
# show-plans.pl?page=ID1&cnt=N
#

use strict;

use DBI;
use CGI;
use HTML::Template;

my $mysql_user = 'rcm';
my $mysql_db = 'rcm';
my $mysql_password = 'rcm';

#
# select ID,substring(ID, 4, 4) + 0 ORD from rcm_raw_plans order by ORD;
#

sub query {
    my ($args, $cgi) = @_;

    my %q = ();
    foreach ($cgi->param) {
	$q{$_} = $cgi->param($_);
    }
    foreach (keys %$args) {
	$q{$_} = $args->{$_};
    }
    return '?'.join('&', map {$_.'='.$cgi->escape($q{$_})} keys %q);
}

main:{
    my $q = new CGI;
    print $q->header('text/html; charset=koi8-r');

    eval {
	print $q->Dump if $q->param('debug');
	my $db = DBI->connect("DBI:mysql:database=$mysql_db;host=localhost",
			      $mysql_user, $mysql_password,
			      {'RaiseError' => 1});
	my $page = $q->param('page') || 1;
	$page = 1 if $q->param('action'); # We must reset page counter 
	                                  # if search button was pressed
	my $cnt = $q->param('cnt') || 5;
	$cnt = 5 if $cnt <= 0 or $cnt > 25;
	my $in_name = $q->param('name') || '';
	my $plan_id = $q->param('plan_id') || '';
	my $rev_order = $q->param('rev_order')?'DESC':'';

	my @where = ();
	my $sth;
	if($in_name){
	    push @where, 'NAME LIKE '.$db->quote('%'.$in_name.'%');
	}
	if($plan_id){
	    push @where, 'ID = '.$db->quote($plan_id);
	}

	$sth = $db->prepare("SELECT ID,AUTHOR,NAME,PRICE,INFO,CATEGORY,IMAGE,ISSUE,".
			    "      (substring(ID, 4, 4) + 0) as ORD ".
			    "FROM rcm_raw_plans ".
			    (@where ? 'WHERE '.join(' AND ', @where).' ' : ''). 
			    "ORDER BY ORD ".$rev_order." LIMIT ?,?");
	$sth->execute(($page - 1) * $cnt, $cnt + 1);

	my $res = [];
	while(my $r = $sth->fetchrow_hashref){
	    push @$res, $r;
	}
	$sth->finish;
	if(0){
	    foreach my $r (@$res) {
		print join(' ', values %$r), "\n";
	    }
	}
	$db->disconnect;
	my $tmpl = HTML::Template->new(filename => 'show-plans.tmpl', die_on_bad_params => 0);
	my $i = 0;
	foreach my $r (@$res) {
	    
	}
	if($page > 1){
	    $tmpl->param(PREV => query({page => $page - 1, action => ''}, $q));
	}
	if(scalar @$res == $cnt + 1){
	    $tmpl->param(NEXT => query({page => $page + 1, action => ''}, $q));
	    pop @$res;
	}
	$tmpl->param(TABLE => $res);
	$tmpl->param(F1_CNT => $cnt);
	$tmpl->param(F1_PAGE => $page);
	$tmpl->param(F1_NAME => $in_name);
	$tmpl->param(F1_PLAN_ID => $plan_id);
	$tmpl->param(F1_REV_ORDER => ($rev_order ? 'checked' : ''));

	print $q->start_html(':: R/C Plans. Page ' . $page), "\n";
	print $tmpl->output, "\n";
	print $q->end_html, "\n";
    };
    if($@){
	print "<b>Error:</b>".$@."\n";
    }
}
