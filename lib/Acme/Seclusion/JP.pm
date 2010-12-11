package Acme::Seclusion::JP;
use strict;
use warnings;
use Acme::CPANAuthors;
use LWP::UserAgent;
use Module::CoreList;

#preload
use HTTP::Request;
use HTTP::Response;
use HTTP::Message;
use URI::http;
use URI::_idna;
use LWP::Protocol::http;
use IO::Select;
use IO::Uncompress::Gunzip;
use HTTP::Headers::Util;

our $VERSION = '0.01';

my $COMPLETE = 0;
my $UA;

BEGIN {
	my @ids_jp = Acme::CPANAuthors->new('Japanese')->id;
	my @ids_cn = Acme::CPANAuthors->new('Chinese')->id;
	my @ids_kr = Acme::CPANAuthors->new('Korean')->id;
	my @ids_nl = Acme::CPANAuthors->new('Dutch')->id;
	my @ids_pt = Acme::CPANAuthors->new('Portuguese')->id;
	
	my @ids = (@ids_jp,@ids_cn, @ids_kr, @ids_nl, @ids_pt);
	
	$UA = LWP::UserAgent->new(
		parse_head => 0,
		env_proxy  => 1,
		agent      => 'LWP',
		timeout    => 30,
	);

	unshift @INC, sub {
		my $mod = $_[1];
		$mod =~ s!/!::!g;
		$mod =~ s/\.pm$//;
		unless ($Module::CoreList::version{$]}{$mod}) {
			my $id = get_author_id($mod);
			my $ids = $COMPLETE ? \@ids_jp : \@ids;
			unless ( defined($id) && grep { /^$id$/ } @$ids ) {
				print STDERR qq{As for the $mod module, the import is prohibited by seclusion policy\n};
				CORE::exit(1);
			}
		}
	};
}

sub import {
	my $class = shift;
	if( @_ == 1 && $_[0] eq '-complete'){
		$COMPLETE = 1;
	}
}

sub get {
	my $mod = shift;
	my $uri = "http://search.cpan.org/perldoc?$mod";
	my $res = $UA->request( HTTP::Request->new( GET => $uri ) );
	return unless $res->is_success;
	return $res->decoded_content;
}

sub get_author_id {
	my $mod  = shift;
	my $html = get($mod);
	return unless $html;
	$html =~ m!<a href="/CPAN/authors/id/(.*?\.(?:tar\.gz|tgz|tar\.bz2|zip))">!;
	return $1;
}

1;
__END__

=head1 NAME

Acme::Seclusion::JP - Sakoku

=head1 SYNOPSIS

  use Acme::Seclusion::JP;

=head1 DESCRIPTION

Acme::Seclusion::JP enforce the policy that similar to the seclusion policy of Japan of Edo period.
You can use only modules that made in Japan, China, Korea, Netherlands and Portuguese.

=head1 AUTHOR

Hideaki Ohno E<lt>hide.o.j55 {at} gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
