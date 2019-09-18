#!/usr/bin/perl -w
use strict;
use warnings;
use S3X_KV;

sub usage {
	die "Usage: ./list.pl  <s3x path>\n"
}

if (!$ARGV[0]) {
    usage();
}

my $s3x = new S3X_KV($ARGV[0]);
print $s3x->list();
