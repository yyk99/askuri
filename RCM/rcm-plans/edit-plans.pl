#!/usr/bin/perl -w

use strict;

use Config::IniFiles;
use DBI;
use CGI;
use HTML::Template;

my ($mysql_user, $mysql_db, $mysql_password);

my @categories;
my %rcm_cats = ( 1 => 'SPORT', 2 => 'SCALE/SPORT SCALE', 3 => 'DUCTED FAN', 4 => 'ELECTRIC POWERED',
		 5 => 'SAILPLANE', 6 => 'GIANT SCALE', 7 => 'SEAPLANE',
		 8 => 'PATTERN', 9 => 'POWER BOAT', 10 => 'SAILBOAT', 11 => 'MISCELLANEOUS');

sub read_config {
    my $cfg = new Config::IniFiles( -file => "rcm-plans.ini" );
    die "Can't open config file\n" unless $cfg;
    $mysql_user = $cfg->val('rcm-plans', 'user');
    $mysql_db = $cfg->val('rcm-plans', 'database');
    $mysql_password = $cfg->val('rcm-plans', 'password');
}

#
# select ID,substring(ID, 4, 4) + 0 ORD from rcm_raw_plans order by ORD;
#

sub query {
    my ($args, $cgi, $excl) = @_;

    $excl = () unless defined $excl; 
    my %q = ();
    my %excl = map { $_ => 1 } @$excl;
    foreach ($cgi->param) {
	$q{$_} = $cgi->param($_) unless $excl{$_};
    }
    foreach (keys %$args) {
	$q{$_} = $args->{$_};
    }
    return '?'.join('&', map {$_.'='.$cgi->escape($q{$_})} keys %q);
}

sub load_categories {
    my $db = shift;

    @categories = ();
    my $sth = $db->prepare("SELECT cat_id, d_short, d_long ".
			   "FROM rcm_cats ORDER BY cat_id");
    $sth->execute;
    while(my $r = $sth->fetchrow_hashref){
	push @categories, $r;
    }
    $sth->finish;
}

=head3 expand_categories

=cut

sub expand_categories {
    my $rh = shift; # pointer to record hash

    if(!defined ($rh->{CATEGORY_SET})){
	$rh->{CATEGORY_SET} = 0;
    }
    $rh->{CATS} = [];
    my $i = 1;
    foreach my $cp (@categories) {
#	print "<BR>CATEGORY_SET = ", $rh->{CATEGORY_SET}, " cat_id = ", $cp->{cat_id}, "\n";
	push @{$rh->{CATS}}, {CAT_DESC => $cp->{d_short}, 
			      CHECK => (($rh->{CATEGORY_SET}+0) & $cp->{cat_id}) ? 'checked' : '',
			      DELIM => $i % 4 ? '' : '<BR>',
			      VALUE => $rh->{ID}.':'.$cp->{cat_id},
			      NAME => 'cats'};
	$i++;
    }
    my $cat = $rh->{CATEGORY};
    $cat =~ s/[,&]/ /;

    $rh->{CATEGORY_TEXT} = join(',', map { $rcm_cats{$_} } split(/\s+/, $cat));
}

=head3 fine_inch

=cut

sub fine_inch {
    my $d = shift;
    my $s = sprintf("%5.3f", $d);
    $s =~ s/^0//;
    $s =~ s/0$//;
    return $s;
}

main:{
    my $q = new CGI;
    print $q->header('text/html; charset=koi8-r');

    read_config;

    eval {
	print $q->Dump if $q->param('debug');
	my $db = DBI->connect("DBI:mysql:database=$mysql_db;host=localhost",
			      $mysql_user, $mysql_password,
			      {'RaiseError' => 1});
	my $page = $q->param('page') || 1;
	$page = 1 if defined $q->param('action') && $q->param('action') eq 'Search'; 
                                          # We must reset page counter
	                                  # if search button was pressed
	my $cnt = $q->param('cnt') || 5;
	$cnt = 5 if $cnt <= 0 or $cnt > 25;
	my $in_name = $q->param('name') || '';
	my $plan_id = $q->param('plan_id') || '';
	$plan_id = 'pl-' . $plan_id if $plan_id =~ /^\d+/; 
	my $author = $q->param('author') || '';
	my $engine = $q->param('engine'); 
	$engine = '' unless defined $engine;
	my $motor = $q->param('motor') || '';
	my $cat_set = $q->param('cat_set');
	$cat_set = '' unless defined $cat_set;
	my $rev_order = $q->param('rev_order')?'DESC':'';
	my $category = $q->param('category') || 0;
	my $lp = $q->param('lp') || '';
	my $up = $q->param('up') || '';
	my $issue = $q->param('issue') || '';

	load_categories($db);

	if(defined $q->param('action') && $q->param('action') eq 'Update'){
	    my @cats = $q->param('cats');
#	    print "<BR>Cats:", join(',', @cats), "\n";
	    my %cats = ();
	    foreach my $c (@cats) {
		if($c =~ /(\S+):(\S+)/){
		    if(exists $cats{$1}){
			$cats{$1} += $2;
		    }else{
			$cats{$1} = $2;
		    }
		}
	    }
	    foreach my $k (keys %cats) {
#		print "<BR>", "UPDATE SET CATS = ", $cats{$k}, " WHERE ID = ", $k, "\n";
		my $r = $db->do("INSERT IGNORE INTO rcm_ext_plans (ID,CATEGORY_SET)VALUES(?,?)", undef,$k, $cats{$k});
#		print "<BR>r == ",$r,"\n";
		if($k == 0){
		    $db->do("UPDATE rcm_ext_plans SET CATEGORY_SET = ? WHERE ID = ?", undef, $cats{$k}, $k);
		}
	    }
	    my @ids = $q->param('IDS');
	    my @e_low = $q->param('E_LOW');
	    my @e_up = $q->param('E_UP');
	    my @e4_low = $q->param('E4_LOW');
	    my @e4_up = $q->param('E4_UP');
	    my @motor_info = $q->param('MOTOR_INFO');
	    my @f2_author = $q->param('F2_AUTHOR');

	    print "<BR>f2_authors = ", join(',', @f2_author), "\n" if $q->param('debug') ;
	    $db->do('INSERT IGNORE INTO rcm_ext_plans (ID) VALUES'.join(',', map { '(?)' } @ids),
		    undef, @ids);
	    foreach my $i (0..$#ids){
		$db->do('UPDATE rcm_ext_plans SET E_LOW = ?,E_UP = ?,E4_LOW = ?,E4_UP=?,MOTOR=? WHERE ID=?',
			undef,
			$e_low[$i], $e_up[$i], $e4_low[$i], 
			$e4_up[$i], $motor_info[$i], $ids[$i]);
		$db->do('UPDATE rcm_raw_plans SET AUTHOR = ? WHERE ID=?', undef, 
			$f2_author[$i], $ids[$i]);
	    }
	}else{
	}
	my @where = ();
	my $sth;
	if($in_name){
	    push @where, 'r.NAME LIKE '.$db->quote('%'.$in_name.'%');
	}
	if($plan_id){
	    push @where, 'r.ID = '.$db->quote($plan_id);
	}
	if($author){
	    push @where, 'r.AUTHOR LIKE '.$db->quote('%'.$author.'%');
	}
	if($category){
	    push @where, 'r.CATEGORY LIKE '.$db->quote('%'.$category.'%');
	}
	if($engine ne ''){
	    push @where, $db->quote($engine).' BETWEEN E_LOW AND E_UP';
	}
	if($issue ne ''){
	    push @where, 'r.ISSUE LIKE '.$db->quote($issue.'%');
	}
	if($motor){
	    if($motor eq '(null)'){
		push @where, 'MOTOR IS NULL';
	    }else{
		push @where, 'MOTOR LIKE '.$db->quote('%'.$motor.'%');
	    }
	}
	if($cat_set){
	    if($cat_set =~ /^x(\d+)/){
	       push @where, '(CATEGORY_SET = '.$db->quote($1).')';
	   }else{
	       push @where, '(CATEGORY_SET & '.$db->quote($cat_set).')';
	   }
	}
	if($lp || $up){
	    if($lp && not $up){
		$lp += 0;
		push @where, "substr(r.PRICE, 2) >= $lp"; 
	    }elsif($up && not $lp){
		$up += 0;
		push @where, "substr(r.PRICE, 2) <= $up";
	    }else{
		$up += 0; $lp += 0;
		push @where, "substr(r.PRICE, 2) BETWEEN $lp AND $up";
	    }
	}
#	print "<BR>where ".join(' AND ', @where)."\n";
	$sth = $db->prepare("SELECT r.ID,r.INFO,concat('images/', r.IMAGE) as IMAGE,".
			    " r.AUTHOR,".
			    " r.NAME,r.PRICE,r.INFO,r.CATEGORY,r.ISSUE,".
			    " r.NOTE,".
			    " e.CATEGORY_SET, e.E_LOW, e.E_UP, e.E4_LOW,".
			    " e.E4_UP, e.SPAN_BOT, e.SPAN_TOP,".
			    " e.MOTOR MOTOR_INFO,".
			    " e.IMAGE_WIDTH, e.IMAGE_HEIGHT,".
			    " (substring(r.ID, 4, 4) + 0) as ORD ".
			    "FROM rcm_raw_plans r ".
			    "LEFT JOIN rcm_ext_plans e USING(ID)".
			    (@where ? 'WHERE '.join(' AND ', @where).' ' : ''). 
			    "ORDER BY ORD ".$rev_order.
			    " LIMIT ".(($page - 1) * $cnt).",".($cnt + 1));
	$sth->execute;

	my $res = [];
	while(my $r = $sth->fetchrow_hashref){
	    #do some visual improvements
	    foreach (qw(E_LOW E_UP E4_LOW E4_UP)){
		$r->{$_} = fine_inch($r->{$_});
	    }
#	    print "<BR>",join(',', map { $_.'=>'.$r->{$_} } keys %$r);
	    foreach (qw(MOTOR_INFO)){
		$r->{$_} = $q->escapeHTML($r->{$_});
	    }
	    push @$res, $r;
	}
	$sth->finish;
	$db->disconnect;
	my $tmpl = HTML::Template->new(filename => 'edit-plans.tmpl', 
				       die_on_bad_params => 0);

	foreach my $r (@$res) {
	    expand_categories($r);
	}
	if(0){
	    print join(' ', keys %{$res->[0]}), "\n";
	    foreach my $r (@$res) {
		print join(' ', values %$r), "\n";
		foreach (@{$r->{CATS}}){
		    print join(':', keys %$_), "\n";
		}
	    }
	}
	# control which are not used in navigation bar
	my @excl = qw(cats action IDS E_UP E_LOW E4_UP E4_LOW MOTOR_INFO IMAGE_WIDTH IMAGE_HEIGHT);
	if($page > 1){
	    $tmpl->param(PREV => query({page => $page - 1}, $q, \@excl));
	}
	if(scalar @$res == $cnt + 1){
	    $tmpl->param(NEXT => query({page => $page + 1}, $q, \@excl));
	    pop @$res; # remove last item from the array. Now we have exactly $cnt elements
	}
	$tmpl->param(TABLE => $res);
	$tmpl->param(F1_CNT => $cnt);
	$tmpl->param(F1_PAGE => $page);
	$tmpl->param(F1_NAME => $in_name);
	$tmpl->param(F1_PLAN_ID => $plan_id);
	$tmpl->param(F1_REV_ORDER => ($rev_order ? 'checked' : ''));
	$tmpl->param(F1_AUTHOR => $author);
	$tmpl->param(F1_ISSUE => $issue);
	$tmpl->param(F1_ENGINE => $engine);
	$tmpl->param(F1_MOTOR => $motor);
	$tmpl->param(F1_CATEGORY => $category);
	$tmpl->param('F1_CATEGORY_'.$category => 'selected');

	$tmpl->param(F1_CAT_SET => $cat_set);
	{
	    my $loop = [ { VAL => 0, TXT => 'All' }];
	  
	    foreach my $c (@categories) {
		push @$loop, {VAL => $c->{cat_id}, TXT => $c->{d_short}, 
			      SEL => $c->{cat_id} eq $cat_set ? 'selected' : ''};
	    }
	    $tmpl->param(F1_CAT_SET_LOOP => $loop);
	}
	
	$tmpl->param(F1_LP => $lp);
	$tmpl->param(F1_UP => $up);

	print $q->start_html(':: Edit R/C Plan Info. Page ' . $page), "\n";
	print $tmpl->output, "\n";
	print $q->end_html, "\n";
    };
    if($@){
	print "<b>Error:</b>".$@."\n";
    }
}

__END__
mysql> desc rcm_ext_plans;
+--------------+---------------+------+-----+---------+-------+
| Field        | Type          | Null | Key | Default | Extra |
+--------------+---------------+------+-----+---------+-------+
| ID           | varchar(32)   |      | PRI |         |       |
| CATEGORY_SET | int(11)       |      |     | 0       |       |
| E_LOW        | decimal(6,3)  |      |     | 0.000   |       |
| E_UP         | decimal(6,3)  |      |     | 0.000   |       |
| E4_LOW       | decimal(6,3)  |      |     | 0.000   |       |
| E4_UP        | decimal(6,3)  |      |     | 0.000   |       |
| SPAN_BOT     | decimal(10,2) |      |     | 0.00    |       |
| SPAN_TOP     | decimal(10,2) |      |     | 0.00    |       |
+--------------+---------------+------+-----+---------+-------+
8 rows in set (0.00 sec)

mysql> desc rcm_categories;
+-------------------+--------------+------+-----+---------+-------+
| Field             | Type         | Null | Key | Default | Extra |
+-------------------+--------------+------+-----+---------+-------+
| categories_id     | int(11)      |      | PRI | 0       |       |
| d_short           | varchar(32)  |      |     |         |       |
| d_long            | varchar(255) |      |     |         |       |
+-------------------+--------------+------+-----+---------+-------+
3 rows in set (0.00 sec)

