#!/usr/bin/perl -w
use strict;
use warnings;
use S3X_KV;

my $OBJNAME = $ARGV[0];
my $FILENAME = $ARGV[1];

my $s3x = new S3X_KV($OBJNAME);

open (my $fh, '>', $FILENAME) or die "could not open file '$FILENAME' $!";
binmode($fh);
print $fh $s3x->readBlob($FILENAME);
close $fh;

print "saved as ./$FILENAME\n";
