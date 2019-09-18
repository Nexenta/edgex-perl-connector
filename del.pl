#!/usr/bin/perl -w
use strict;
use warnings;
use S3X_KV;

sub usage {
	die "Usage: ./del.pl  <s3x path> <image name>\n"
}

my $OBJNAME = $ARGV[0];
my $FILENAME = $ARGV[1];

if (!$FILENAME) {
    usage();
}


my $s3x = new S3X_KV($OBJNAME);
$s3x->deleteBlob($FILENAME);
$s3x->close();
