#!/usr/bin/perl -w
use strict;
use warnings;
use S3X_KV;

my $OBJNAME = $ARGV[0];
my $FILENAME = $ARGV[1];

my $s3x = new S3X_KV($OBJNAME);
$s3x->deleteBlob($FILENAME);
$s3x->close();
