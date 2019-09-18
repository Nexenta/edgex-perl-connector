#!/usr/bin/perl -w
use strict;
use warnings;

package S3X_KV;

use LWP::UserAgent;
use S3X_CON;

sub new {
	my $class = shift;
	my $self = {
		_path => shift,
		_order => shift || 4,
		_sid => undef,
	};
	die "required path argument is missing" if !defined($self->{_path});
	$self->{_ua} = LWP::UserAgent->new(
		ssl_opts => {
			verify_hostname => 0,
			SSL_verify_mode => 0,
		},
	);
	$self->{_ua}->agent("EdgeX-PerlClient/1.0");

	my $host = '';
	my $key = '';
	my $secret = '';
	my $secure = 0;
	my $config = $ENV{"HOME"} . "/.s3cfg";
	if (open(FH, '<', $config)) {
		while(<FH>){
			if ($_ =~ /^host_base\s*=\s*([^\s]+)/) {
				$host = $1;
			}
			if ($_ =~ /^access_key\s*=\s*(\w+)/) {
				$key = $1;
			}
			if ($_ =~ /^secret_key\s*=\s*(\w+)/) {
				$secret = $1;
			}
			if ($_ =~ /^use_https\s*=\s*(\w+)/) {
				$secure = ($1 eq 'True' ? 1 : 0);
			}
		}
		close(FH)
	}
	$config = ".s3cfg";
	if (open(FH, '<', $config)) {
		while(<FH>){
			if ($_ =~ /^host_base\s*=\s*([^\s]+)/) {
				$host = $1;
			}
			if ($_ =~ /^access_key\s*=\s*(\w+)/) {
				$key = $1;
			}
			if ($_ =~ /^secret_key\s*=\s*(\w+)/) {
				$secret = $1;
			}
			if ($_ =~ /^use_https\s*=\s*(\w+)/) {
				$secure = ($1 eq 'True' ? 1 : 0);
			}
		}
		close(FH)
	}
	$host = $ENV{"host_base"} if ($ENV{"host_base"});
	$key = $ENV{"access_key"} if ($ENV{"access_key"});
	$secret = $ENV{"secret_key"} if ($ENV{"secret_key"});
	$secure = $ENV{"secure"} if ($ENV{"secure"});

	print "Host  base: " . $host . "\n";
	print "Access key: " . $key . "\n";
	print "Secure connection: " . $secure . "\n";

	$self->{_conn} = new S3X_CON(
        $host,
        $key,
        $secret,
        $secure,
	);
	bless $self, $class;
	return $self;
}

sub exist {
	my ($self) = @_;
	my $req = $self->{_conn}->make_request("HEAD", $self->{_path}, '', '', '');
	my $res = $self->{_ua}->request($req);
	return $res->is_success;
}

sub open {
	my ($self, $content, $replace) = @_;
	if ($self->exist()) {
		return;
	}
	my %headers = ();
	$headers{'x-ccow-object-oflags'} = $replace ? '3' : '2';
	$headers{'x-ccow-chunkmap-btree-order'} = $self->{_order} if ($self->{_order});
	$headers{'content_type'} = $content if ($content);
	my $req = $self->{_conn}->make_request("POST", $self->{_path} . "?comp=kv&key=&finalize=",  \%headers, '', '');
	my $res = $self->{_ua}->request($req);
	if (!$res->is_success) {
		die "communication error: " . $res->status_line;
	}
}

sub abort {
	my ($self, $replace) = @_;
	my %headers = ();
	if (defined($self->{_sid})) {
		$headers{'x-session-id'} = $self->{_sid};
	} else {
		return;
	}
	my $req = $self->{_conn}->make_request("POST", $self->{_path} . "?comp=kv&key=&cancel=",  \%headers, '', '');
	my $res = $self->{_ua}->request($req);
	if (!$res->is_success) {
		die "communication error: " . $res->status_line;
	}
}

sub close {
	my ($self, $replace) = @_;
	my %headers = ();
	if (defined($self->{_sid})) {
		$headers{'x-session-id'} = $self->{_sid};
	} else {
		return;
	}
	my $req = $self->{_conn}->make_request("POST", $self->{_path} . "?comp=kv&key=&finalize=",  \%headers, '', '');
	my $res = $self->{_ua}->request($req);
	if (!$res->is_success) {
		die "communication error: " . $res->status_line;
	}
}

sub insertBlob {
	my ($self, $key, $data, $mtime, $content) = @_;

	my %headers = ();
	if (defined($self->{_sid})) {
		$headers{'x-session-id'} = $self->{_sid};
	}
	$headers{'timestamp'} = $mtime if ($mtime);
	$headers{'content_type'} = $content if ($content);

	my $req = $self->{_conn}->make_request("POST", $self->{_path} . "?comp=kv&key=$key", \%headers, $data, '');

	my $res = $self->{_ua}->request($req);
	if (!$res->is_success) {
		die "communication error: " . $res->status_line;
	}

	if (!defined($self->{_sid})) {
		$self->{_sid} = $res->header('x-session-id');
	}
}

sub deleteBlob {
	my ($self, $key) = @_;

	my %headers = ();
	if (defined($self->{_sid})) {
		$headers{'x-session-id'} = $self->{_sid};
	}
	$headers{'content_type'} = 'application/octet-stream';

	my $req = $self->{_conn}->make_request("DELETE", $self->{_path} . "?comp=kv&key=$key", \%headers, '', '');

	my $res = $self->{_ua}->request($req);
	if (!$res->is_success) {
		die "communication error: " . $res->status_line;
	}

	if (!defined($self->{_sid})) {
		$self->{_sid} = $res->header('x-session-id');
	}
}

sub readBlob {
	my ($self, $key) = @_;

	my %headers = ();
	$headers{'content_type'} = 'application/octet-stream';
	my $req = $self->{_conn}->make_request("GET", $self->{_path} . "?comp=kvget&key=$key", \%headers, '', '');

	my $res = $self->{_ua}->request($req);
	if (!$res->is_success) {
		die "communication error: " . $res->status_line;
	}
	return $res->content;
}

sub list {
	my ($self) = @_;

	my $req = $self->{_conn}->make_request("GET", $self->{_path} . "?comp=kv", '', '', '');

	my $res = $self->{_ua}->request($req);
	if (!$res->is_success) {
		die "communication error: " . $res->status_line;
	}
	return $res->content;
}
1;
