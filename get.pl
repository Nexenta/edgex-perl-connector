#!/usr/bin/perl -w
use strict;
use warnings;
use S3X_KV;

sub usage {
	die "Usage: ./get.pl  <s3x path> <image name>\n"
}

my $OBJNAME = $ARGV[0];
my $FILENAME = $ARGV[1];

if (!$FILENAME) {
    usage();
}

my $s3x = new S3X_KV($OBJNAME);

open (my $fh, '>', $FILENAME) or die "could not open file '$FILENAME' $!";
binmode($fh);
print $fh $s3x->readBlob($FILENAME);
close $fh;

print "saved as ./$FILENAME\n";
