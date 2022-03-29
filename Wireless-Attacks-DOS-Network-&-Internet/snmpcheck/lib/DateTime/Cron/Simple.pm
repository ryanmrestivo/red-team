
package DateTime::Cron::Simple;

use strict;
use warnings;

our $VERSION = '0.3';

use DateTime;
use Set::Crontab;

=head1 NAME

DateTime::Cron::Simple - Parse a cron entry and check against current time

=head1 SYNOPSIS

  use DateTime::Cron::Simple;

  $c = DateTime::Cron::Simple->new($cron);

  $boolean = $c->validate_time;

  $c->new_cron($cron);

=head1 DESCRIPTION

This module is a quick and dirty way to determine if a cron time format is valid for the current date and time.

A cron entry follows the cron format from crontab(5).

The validate_time function uses the current date and time for comparison, but will also accept a valid DateTime object as a parameter.

=head2 FUNCTIONS

=over 4

=item B<new>

    $c = DateTime::Cron::Simple->new('0-59/2 10,12 * * 5');

Creates a cron entry.

=cut

sub new {
    my $self = shift;
    my $proto = ref $self || $self;
    my $obj = bless {}, $proto;
    return $obj->_init(@_);
}

=item B<new_cron>

    $c->new_cron($cron);

Updates the cron entry to the given argument.

=cut

sub new_cron {
    return shift->_init(@_);
}

sub _init {
    my $self = shift;
    $self->{cron} = shift;
    $self->_parse_cron_entry($self->{cron});
    return $self;
}

# NOTE. The name of the fields are the same
# as the corresponding methods in DateTime objects
# to make code shorter.

my %FIELDS_META = (
    names => [ qw(minute hour day month dow_0) ],
    edges => {
        minute => [ 0, 59 ],
        hour   => [ 0, 23 ],
        day    => [ 1, 31 ],
        month  => [ 1, 12 ],
        dow_0  => [ 0, 6 ],
    },
);


=item B<validate_time>

    $boolean = $c->validate_time;
    $boolean = $c->validate_time($dt);

Validates a datetime against the cron entry.
If the argument is ommitted, it validates
against the current time (C<DateTime->now>).

=cut

#use YAML;

sub validate_time {
    my $self = shift;
    my $dt = shift || DateTime->now();
    my @fields = @{$FIELDS_META{names}};
    for (@fields) {
#        print "is ", $dt->$_, " within ", $self->{$_}, "? ";
#        print("no\n"), return 0 unless $self->{"${_}_set"}->contains($dt->$_);
#        print("yes\n");
        return 0 unless $self->{"${_}_set"}->contains($dt->$_);
    }
    return 1;
}

sub _parse_cron_entry {
    my $self = shift;
    my $entry = shift;

    my @fields = split /\s+/, $entry, 5;
    for (@{$FIELDS_META{names}}) {
        my $f = shift @fields;
        $self->{$_} = $f;
        unless (defined $f) { # 0 shall pass
            $self->{"${_}_set"} = Set::Crontab->new('', []); # the empty set
            next;
        }
        my @edges = @{$FIELDS_META{edges}{$_}};
        $self->{"${_}_set"} = $self->_parse_cron_field($f, @edges);
    }

}

=item B<_parse_cron_field>

    $data = $c->_parse_cron_field($field, $min, $max)

=cut

sub _parse_cron_field {
    my $self = shift;
    my $field = shift;
    my ($min, $max) = @_;

    return Set::Crontab->new($field, [$min..$max]);
}

=back

=head1 EXAMPLE

  use DateTime::Cron::Simple;

  $c = DateTime::Cron::Simple->new('0-59/2 10,12 * * 5');

  if($c->validate_time) { ... }

  $c->new_cron('* * 1 * 0');

  if($c->validate_time) { ... }


=head1 SEE ALSO

   DateTime::Event::Cron

It is very likely that this module will soon
be deprecated. It was created without coordination
with the developers of DateTime modules,
which may be reached via

   http://datetime.perl.org/
   datetime@perl.org (the mailing list)

This module would better belong to the DateTime::Event
namespace or else have its functionality incorporated
into DateTime::Event::Cron. This release 
is transitional, while the right way to do
it is being studied.

=head1 AUTHORS/MAINTAINERS

The original author of this module is

Brendan Fagan E<lt>suburbanantihero (at) yahoo (dot) comE<gt>. 

At version 0.3, a full rewrite was done to set it
free from license issues. The current maintainer is

Adriano Ferreira E<lt>ferreira (at) cpan (dot) orgE<gt>.

Comments, bug reports, patches and flames are still 
appreciated. 

=head1 COPYRIGHT AND LICENSE

Brendan Fagan holds the copyright from 2002 to 2006 over
versions 0.1 and 0.2 of the distribution.

Copyright (C) 2006 by A. R. Ferreira

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


1;


