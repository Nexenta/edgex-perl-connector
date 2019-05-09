#!/usr/bin/perl -w
use strict;
use warnings;
use S3X_KV;

my $s3x = new S3X_KV($ARGV[0]);
print $s3x->list();
