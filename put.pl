#!/usr/bin/perl -w
use strict;
use warnings;
use S3X_KV;

my $DIRNAME = $ARGV[0] || "";
my $OBJPATH = $ARGV[1] || "";
my $CONTENT = $ARGV[2] || "image/jpeg";
my $REPLACE = $ARGV[3] || 0;
opendir(DIR, $DIRNAME) or die "cannot open input directory";

my $s3x = new S3X_KV($OBJPATH);
$s3x->open($CONTENT, $REPLACE);

my $cnt = 0;
my @images = grep(/\.jpg$/, readdir(DIR));
foreach my $img (@images) {
	my $path = $DIRNAME . "/" . $img;
        my $mtime = (stat($path))[9];

	open F, $path || die "cannot open file $img";
	binmode F;
	my $data = do { local $/; <F> };
	close F;

	print "Loading " . $path . "\n";
	$s3x->insertBlob($img, $data, $mtime, $CONTENT);

	$cnt++;
}
$s3x->close();
print "inserted $cnt blob records into S3X object $OBJPATH\n";
