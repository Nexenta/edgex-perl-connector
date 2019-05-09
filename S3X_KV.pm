#!/usr/bin/perl -w
use strict;
use warnings;

package S3X_KV;

use LWP::UserAgent;

sub new {
	my $class = shift;
	my $self = {
		_path => shift,
		_order => shift || 4,
		_ua => LWP::UserAgent->new,
		_sid => undef,
	};
	die "required path argument is missing" if !defined($self->{_path});
	$self->{_ua}->agent("EdgeX-PerlClient/1.0");
	bless $self, $class;
	return $self;
}

sub exist {
	my ($self, $key) = @_;
	$key = $key || "";
	my $req = HTTP::Request->new(HEAD => $self->{_path} . "?comp=kv&key=$key&cancel=");
	my $res = $self->{_ua}->request($req);
	return $res->is_success;
}

sub open {
	my ($self, $replace) = @_;
	if ($self->exist() && !$replace) {
		return;
	}
	my $req = HTTP::Request->new(POST => $self->{_path} . "?comp=kv&key=&finalize=");
	$req->header('x-ccow-object-oflags' => $replace ? '3' : '2');
	$req->header('x-ccow-chunkmap-btree-order' => $self->{_order});
	$req->content_type('application/octet-stream');
	my $res = $self->{_ua}->request($req);
	if (!$res->is_success) {
		die "communication error: " . $res->status_line;
	}
}

sub close {
	my ($self, $replace) = @_;
	my $req = HTTP::Request->new(POST => $self->{_path} . "?comp=kv&key=&finalize=");
	if (defined($self->{_sid})) {
		$req->header('x-session-id' => $self->{_sid});
	} else {
		return;
	}
	my $res = $self->{_ua}->request($req);
	if (!$res->is_success) {
		die "communication error: " . $res->status_line;
	}
}

sub insertBlob {
	my ($self, $key, $data) = @_;
	my $req = HTTP::Request->new(POST => $self->{_path} . "?comp=kv&key=$key");
	if (defined($self->{_sid})) {
		$req->header('x-session-id' => $self->{_sid});
	}
	$req->content_type('application/octet-stream');
	$req->content($data);

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
	my $req = HTTP::Request->new(DELETE => $self->{_path} . "?comp=kv&key=$key");
	if (defined($self->{_sid})) {
		$req->header('x-session-id' => $self->{_sid});
	}
	$req->content_type('application/octet-stream');

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
	my $req = HTTP::Request->new(GET => $self->{_path} . "?comp=kvget&key=$key");
	$req->content_type('application/octet-stream');

	my $res = $self->{_ua}->request($req);
	if (!$res->is_success) {
		die "communication error: " . $res->status_line;
	}
	return $res->content;
}

sub list {
	my ($self) = @_;
	my $req = HTTP::Request->new(GET => $self->{_path} . '?comp=kv');
	my $res = $self->{_ua}->request($req);
	if (!$res->is_success) {
		die "communication error: " . $res->status_line;
	}
	return $res->content;
}
1;
