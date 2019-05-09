#!/usr/bin/perl -w
use strict;
use warnings;
use S3X_KV;

my $DIRNAME = $ARGV[0] || "";
my $OBJPATH = $ARGV[1] || "";
opendir(DIR, $DIRNAME) or die "cannot open input directory";

my $s3x = new S3X_KV($OBJPATH);
$s3x->open();

my $cnt = 0;
my @images = grep(/\.jpg$/, readdir(DIR));
foreach my $img (@images) {
	open F, $DIRNAME . "/" . $img || die "cannot open file $img";
	binmode F;
	my $data = do { local $/; <F> };
	close F;

	$s3x->insertBlob($img, $data);

	$cnt++;
}
$s3x->close();
print "inserted $cnt blob records into S3X object $OBJPATH\n";
