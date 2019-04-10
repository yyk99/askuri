#!/usr/bin/perl -w
use strict;
use Image::Magick;
use File::Basename;

my ($maxw, $maxh) = (150, 100);

sub create_thumbnail {
  my $file = shift;
  my $lurl = "tn-" . basename($file);
  
  my $image = Image::Magick->new;
  my $rc;

  $rc = $image->Read($file);
  die $rc if $rc;

  my ($wid, $hei) = $image->Get('width', 'height');
  print STDERR "Image: ($wid,$hei)\n";
  my ($wid_new, $hei_new);
  if($wid < $hei){
    $hei_new = int($hei * $maxw / $wid);
    $wid_new = $maxw;
  }else{
    $wid_new = int($wid * $maxh / $hei);
    $hei_new = $maxh;
  }

  $rc = $image->Scale(width=>$wid_new, height=>$hei_new);
  die $rc if $rc;
  
  $rc = $image->Write($lurl);
  die $rc if $rc;

  return $lurl;
}


sub header {
    print <<EOF
<HTML>
<HEAD>
<TITLE>Image gallery</TITLE>
</HEAD>
<BODY>
EOF
}

sub footer {
    print <<EOF
</BODY>
</HTML>
EOF
}

#
# main
#

&header;
my $pics_per_row = 3;
my $cnt = 0;

print "<TABLE border=\"0\" align=\"center\">\n";

my $file;
do{
    my $cnt;
    for($cnt = 0 ; $cnt < $pics_per_row && ($file = shift()) ; $cnt++){
	if($cnt == 0){
	    print "<TR>\n";
	}
	my $img = create_thumbnail($file);
	printf "<TD align=\"center\"><A HREF=\"%s\"><IMG src=\"%s\"><BR>%s</A></TD>\n", $file, $img, $file;
    }
    if($cnt){
	print "</TR>\n";
    }
}while($file);

print "</TABLE>\n";
&footer;
exit;
