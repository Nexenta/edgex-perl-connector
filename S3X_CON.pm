#!/usr/bin/perl -w
use strict;
use warnings;

use Carp;
use HTTP::Request;
use Digest::HMAC_SHA1;
use HTTP::Date;
use MIME::Base64 qw(encode_base64);
use URI::Escape qw(uri_escape_utf8);

package S3X_CON;

my $AMAZON_HEADER_PREFIX = 'x-amz-';
my $METADATA_PREFIX      = 'x-amz-meta-';

sub new {
	my $class = shift;
	my $self = {
		_host => shift,
		_key => shift,
		_secret => shift,
		_secure => shift,
	};
	die "required retry argument is missing" if !defined($self->{_secret});
	bless $self, $class;
	return $self;
}


# make the HTTP::Request object
sub make_request {
    my ($self, $method, $path, $headers, $data, $metadata) = @_;
    die 'must specify method' unless $method;
    die 'must specify path'   unless defined $path;
    $headers ||= {};
    $data = '' if not defined $data;
    $metadata ||= {};
    my $http_headers = $self->_merge_meta($headers, $metadata);

    $self->_add_auth_header($http_headers, $method, $path)
      unless exists $headers->{Authorization};
    my $protocol = $self->{_secure} ? 'https' : 'http';
    my $host     = $self->{_host};
    my $url      = "$protocol://$host/$path";

    my $request = HTTP::Request->new($method, $url, $http_headers);
    $request->content($data) if $data;

    return $request;
}


sub _add_auth_header {
    my ($self, $headers, $method, $path) = @_;
    my $aws_access_key_id     = $self->{_key};
    my $aws_secret_access_key = $self->{_secret};

    if (not $headers->header('Date')) {
        $headers->header(Date => HTTP::Date::time2str(time));
    }
    my $canonical_string = $self->_canonical_string($method, $path, $headers);
    my $encoded_canonical =
      $self->_encode($aws_secret_access_key, $canonical_string);
    $headers->header(
        Authorization => "AWS $aws_access_key_id:$encoded_canonical");
}

# generates an HTTP::Headers objects given one hash that represents http
# headers to set and another hash that represents an object's metadata.
sub _merge_meta {
    my ($self, $headers, $metadata) = @_;
    $headers  ||= {};
    $metadata ||= {};

    my $http_header = HTTP::Headers->new;
    while (my ($k, $v) = each %$headers) {
        $http_header->header($k => $v);
    }
    while (my ($k, $v) = each %$metadata) {
        $http_header->header("$METADATA_PREFIX$k" => $v);
    }

    return $http_header;
}

# generate a canonical string for the given parameters.  expires is optional and is
# only used by query string authentication.
sub _canonical_string {
    my ($self, $method, $path, $headers, $expires) = @_;
    my %interesting_headers = ();
    while (my ($key, $value) = each %$headers) {
        my $lk = lc $key;
        if (   $lk eq 'content-md5'
            or $lk eq 'content-type'
            or $lk eq 'date'
            or $lk =~ /^$AMAZON_HEADER_PREFIX/)
        {
            $interesting_headers{$lk} = $self->_trim($value);
        }
    }

    # these keys get empty strings if they don't exist
    $interesting_headers{'content-type'} ||= '';
    $interesting_headers{'content-md5'}  ||= '';

    # just in case someone used this.  it's not necessary in this lib.
    $interesting_headers{'date'} = ''
      if $interesting_headers{'x-amz-date'};

    # if you're using expires for query string auth, then it trumps date
    # (and x-amz-date)
    $interesting_headers{'date'} = $expires if $expires;

    my $buf = "$method\n";
    foreach my $key (sort keys %interesting_headers) {
        if ($key =~ /^$AMAZON_HEADER_PREFIX/) {
            $buf .= "$key:$interesting_headers{$key}\n";
        }
        else {
            $buf .= "$interesting_headers{$key}\n";
        }
    }

    # don't include anything after the first ? in the resource...
    $path =~ /^([^?]*)/;
    $buf .= "/$1";

    # ...unless there is an acl or torrent parameter
    if ($path =~ /[&?]acl($|=|&)/) {
        $buf .= '?acl';
    }
    elsif ($path =~ /[&?]torrent($|=|&)/) {
        $buf .= '?torrent';
    }
    elsif ($path =~ /[&?]location($|=|&)/) {
        $buf .= '?location';
    }

    return $buf;
}

sub _trim {
    my ($self, $value) = @_;
    $value =~ s/^\s+//;
    $value =~ s/\s+$//;
    return $value;
}

# finds the hmac-sha1 hash of the canonical string and the aws secret access key and then
# base64 encodes the result (optionally urlencoding after that).
sub _encode {
    my ($self, $aws_secret_access_key, $str, $urlencode) = @_;
    my $hmac = Digest::HMAC_SHA1->new($aws_secret_access_key);
    $hmac->add($str);
    my $b64 = MIME::Base64::encode_base64($hmac->digest, '');
    if ($urlencode) {
        return $self->_urlencode($b64);
    }
    else {
        return $b64;
    }
}

sub _urlencode {
    my ($self, $unencoded) = @_;
    return uri_escape_utf8($unencoded, '^A-Za-z0-9_-');
}

1;
