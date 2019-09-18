#!/usr/bin/perl -w
use strict;
use warnings;
use S3X_KV;

sub usage {
	die "Usage: ./put.pl <input dir | input image> <target s3x path> [<content type> [replace]]\n"
}

sub load_one {
	my ($s3x, $path, $img, $CONTENT) = @_;
	my $mtime = (stat($path))[9];

	open F, $path || die "cannot open file $path";
	binmode F;
	my $data = do { local $/; <F> };
	close F;

	print "Loading image $img from " . $path . "\n";
	$s3x->insertBlob($img, $data, $mtime, $CONTENT);
}

my $DIRNAME = $ARGV[0] || "";
my $OBJPATH = $ARGV[1] || "";
my $CONTENT = $ARGV[2] || "image/jpeg";
my $REPLACE = $ARGV[3] || 0;

if (!$OBJPATH) {
	usage();
}

my $s3x = new S3X_KV($OBJPATH);
my $cnt = 0;

$s3x->open($CONTENT, $REPLACE);

die "$DIRNAME does not exists" unless (-e $DIRNAME);


if (-d $DIRNAME) { # Directory upload
	opendir(DIR, $DIRNAME) or die "cannot open input directory";

	my @images = grep(/\.jpg$/, readdir(DIR));
	foreach my $img (@images) {
		my $path = $DIRNAME . "/" . $img;
		load_one($s3x, $path, $img, $CONTENT);
		$cnt++;
	}
} else { # Single image upload
		my $path = $DIRNAME;
		my $p = rindex($path,"/");
		my $img = ($p < 0 ? $path : substr($path, $p+1, length($path)-$p-1));
		load_one($s3x, $path, $img, $CONTENT);
		$cnt++;
}

$s3x->close();
print "inserted $cnt blob records into S3X object $OBJPATH\n";
