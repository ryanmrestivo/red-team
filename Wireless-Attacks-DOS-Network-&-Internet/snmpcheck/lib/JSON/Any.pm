package JSON::Any;
{
  $JSON::Any::VERSION = '1.32';
}
{
  $JSON::Any::VERSION = '1.32';
}

use warnings;
use strict;
use Carp qw(croak carp);

# ABSTRACT: Wrapper Class for the various JSON classes.

our $UTF8;

my ( %conf, $handler, $encoder, $decoder );
use constant HANDLER => 0;
use constant ENCODER => 1;
use constant DECODER => 2;
use constant UTF8    => 3;

BEGIN {
    %conf = (
        json_1 => {
            encoder       => 'objToJson',
            decoder       => 'jsonToObj',
            get_true      => sub { return JSON::True(); },
            get_false     => sub { return JSON::False(); },
            create_object => sub {
                require JSON;
                my ( $self, $conf ) = @_;
                my @params = qw(
                  autoconv
                  skipinvalid
                  execcoderef
                  pretty
                  indent
                  delimiter
                  keysort
                  convblessed
                  selfconvert
                  singlequote
                  quoteapos
                  unmapping
                  barekey
                );
                my $obj =
                  $handler->new( utf8 => $conf->{utf8} );    ## constructor only

                for my $mutator (@params) {
                    next unless exists $conf->{$mutator};
                    $obj = $obj->$mutator( $conf->{$mutator} );
                }

                $self->[ENCODER] = 'objToJson';
                $self->[DECODER] = 'jsonToObj';
                $self->[HANDLER] = $obj;
            },
        },
        json_2 => {
            encoder       => 'encode_json',
            decoder       => 'decode_json',
            get_true      => sub { return JSON::true(); },
            get_false     => sub { return JSON::false(); },
            create_object => sub {
                JSON->import( '-support_by_pp', '-no_export' );
                my ( $self, $conf ) = @_;
                my @params = qw(
                  ascii
                  latin1
                  utf8
                  pretty
                  indent
                  space_before
                  space_after
                  relaxed
                  canonical
                  allow_nonref
                  allow_blessed
                  convert_blessed
                  filter_json_object
                  shrink
                  max_depth
                  max_size
                  loose
                  allow_bignum
                  allow_barekey
                  allow_singlequote
                  escape_slash
                  indent_length
                  sort_by
                );
                local $conf->{utf8} = !$conf->{utf8};    # it means the opposite
                my $obj = $handler->new;

                for my $mutator (@params) {
                    next unless exists $conf->{$mutator};
                    $obj = $obj->$mutator( $conf->{$mutator} );
                }

                $self->[ENCODER] = 'encode';
                $self->[DECODER] = 'decode';
                $self->[HANDLER] = $obj;
            },
        },
        json_dwiw => {
            encoder       => 'to_json',
            decoder       => 'from_json',
            get_true      => sub { return JSON::DWIW->true; },
            get_false     => sub { return JSON::DWIW->false; },
            create_object => sub {
                my ( $self, $conf ) = @_;
                my @params = qw(bare_keys);
                croak "JSON::DWIW does not support utf8" if $conf->{utf8};
                $self->[ENCODER] = 'to_json';
                $self->[DECODER] = 'from_json';
                $self->[HANDLER] =
                  $handler->new( { map { $_ => $conf->{$_} } @params } );
            },
        },
        json_xs_1 => {
            encoder       => 'to_json',
            decoder       => 'from_json',
            get_true      => sub { return \1; },
            get_false     => sub { return \0; },
            create_object => sub {
                my ( $self, $conf ) = @_;

                my @params = qw(
                  ascii
                  utf8
                  pretty
                  indent
                  space_before
                  space_after
                  canonical
                  allow_nonref
                  shrink
                  max_depth
                );

                my $obj = $handler->new;
                for my $mutator (@params) {
                    next unless exists $conf->{$mutator};
                    $obj = $obj->$mutator( $conf->{$mutator} );
                }
                $self->[ENCODER] = 'encode';
                $self->[DECODER] = 'decode';
                $self->[HANDLER] = $obj;
            },
        },
        json_xs_2 => {
            encoder       => 'encode_json',
            decoder       => 'decode_json',
            get_true      => sub { return JSON::XS::true(); },
            get_false     => sub { return JSON::XS::false(); },
            create_object => sub {
                my ( $self, $conf ) = @_;

                my @params = qw(
                  ascii
                  latin1
                  utf8
                  pretty
                  indent
                  space_before
                  space_after
                  relaxed
                  canonical
                  allow_nonref
                  allow_blessed
                  convert_blessed
                  filter_json_object
                  shrink
                  max_depth
                  max_size
                );

                local $conf->{utf8} = !$conf->{utf8};    # it means the opposite

                my $obj = $handler->new;
                for my $mutator (@params) {
                    next unless exists $conf->{$mutator};
                    $obj = $obj->$mutator( $conf->{$mutator} );
                }
                $self->[ENCODER] = 'encode';
                $self->[DECODER] = 'decode';
                $self->[HANDLER] = $obj;
            },
        },
        json_syck => {
            encoder  => 'Dump',
            decoder  => 'Load',
            get_true => sub {
                croak "JSON::Syck does not support special boolean values";
            },
            get_false => sub {
                croak "JSON::Syck does not support special boolean values";
            },
            create_object => sub {
                my ( $self, $conf ) = @_;
                croak "JSON::Syck does not support utf8" if $conf->{utf8};
                $self->[ENCODER] = sub { Dump(@_) };
                $self->[DECODER] = sub { Load(@_) };
                $self->[HANDLER] = 'JSON::Syck';
              }
        },
    );

    # JSON::PP has the same API as JSON.pm v2
    $conf{json_pp} = { %{ $conf{json_2} } };
    $conf{json_pp}{get_true}  = sub { return JSON::PP::true(); };
    $conf{json_pp}{get_false} = sub { return JSON::PP::false(); };

    # Cpanel::JSON::XS is a fork of JSON::XS (currently)
    $conf{cpanel_json_xs} = { %{ $conf{json_xs_2} } };
    $conf{cpanel_json_xs}{get_true}  = sub { return Cpanel::JSON::XS::true(); };
    $conf{cpanel_json_xs}{get_false} = sub { return Cpanel::JSON::XS::false(); };

    # JSON::XS 3 is almost the same as JSON::XS 2
    $conf{json_xs_3} = { %{ $conf{json_xs_2} } };
    $conf{json_xs_3}{get_true}  = sub { return Types::Serialiser::true(); };
    $conf{json_xs_3}{get_false} = sub { return Types::Serialiser::false(); };
}

sub _make_key {
    my $handler = shift;
    ( my $key = lc($handler) ) =~ s/::/_/g;
    if ( 'json_xs' eq $key || 'json' eq $key ) {
        no strict 'refs';
        $key .= "_" . ( split /\./, ${"$handler\::VERSION"} )[0];
    }
    return $key;
}

my @default    = qw(CPANEL XS PP JSON DWIW);
my @deprecated = qw(Syck);

sub _module_name {
    my ($testmod) = @_;
    return 'Cpanel::JSON::XS' if $testmod eq 'CPANEL';
    return 'JSON'             if $testmod eq 'JSON';
    return "JSON::$testmod";
}

sub _try_loading {
    my @order = @_;
    ( $handler, $encoder, $decoder ) = ();
    foreach my $mod (@order) {
        my $testmod = _module_name($mod);
        eval "require $testmod";
        unless ($@) {
            $handler = $testmod;
            my $key = _make_key($handler);
            next unless exists $conf{$key};
            $encoder = $conf{$key}->{encoder};
            $decoder = $conf{$key}->{decoder};
            last;
        }
    }
    return ( $handler, $encoder, $decoder );
}

sub import {
    my $class = shift;
    my @order = @_;

    ( $handler, $encoder, $decoder ) = ();

    @order = split /\s/, $ENV{JSON_ANY_ORDER}
      if !@order and $ENV{JSON_ANY_ORDER};

    if (@order) {
        ( $handler, $encoder, $decoder ) = _try_loading(@order);
        if ( $handler && grep { "JSON::$_" eq $handler } @deprecated ) {
            my $last = pop @default;
            carp "Found deprecated package $handler. Please upgrade to ",
              join ', ' => @default,
              "or $last";
        }
    }
    else {
        ( $handler, $encoder, $decoder ) = _try_loading(@default);
        unless ($handler) {
            ( $handler, $encoder, $decoder ) = _try_loading(@deprecated);
            if ($handler) {
                my $last = pop @default;
                carp "Found deprecated package $handler. Please upgrade to ",
                  join ', ' => @default,
                  "or $last";
            }
        }
    }
    unless ($handler) {
        my $last = pop @default;
        croak "Couldn't find a JSON package. Need ", join ', ' => @default,
          "or $last";
    }
    croak "Couldn't find a decoder method." unless $decoder;
    croak "Couldn't find a encoder method." unless $encoder;
}


sub new {
    my $class = shift;
    my $self  = bless [], $class;
    my $key   = _make_key($handler);
    if ( my $creator = $conf{$key}->{create_object} ) {
        my @config = @_;
        if ( $ENV{JSON_ANY_CONFIG} ) {
            push @config, map { split /=/, $_ } split /,\s*/,
              $ENV{JSON_ANY_CONFIG};
        }
        $creator->( $self, my $conf = {@config} );
        $self->[UTF8] = $conf->{utf8};
    }
    return $self;
}


sub handlerType {
    my $class = shift;
    $handler;
}


sub handler {
    my $self = shift;
    if ( ref $self ) {
        return $self->[HANDLER];
    }
    return $handler;
}


sub true {
    my $key = _make_key($handler);
    return $conf{$key}->{get_true}->();
}


sub false {
    my $key = _make_key($handler);
    return $conf{$key}->{get_false}->();
}


sub objToJson {
    my $self = shift;
    my $obj  = shift;
    croak 'must provide object to convert' unless defined $obj;

    my $json;

    if ( ref $self ) {
        my $method;
        unless ( ref $self->[ENCODER] ) {
            croak "No $handler Object created!"
              unless exists $self->[HANDLER];
            $method = $self->[HANDLER]->can( $self->[ENCODER] );
            croak "$handler can't execute $self->[ENCODER]" unless $method;
        }
        else {
            $method = $self->[ENCODER];
        }
        $json = $self->[HANDLER]->$method($obj);
    }
    else {
        $json = $handler->can($encoder)->($obj);
    }

    utf8::decode($json)
      if ( ref $self ? $self->[UTF8] : $UTF8 )
      and !utf8::is_utf8($json)
      and utf8::valid($json);
    return $json;
}


*to_json = \&objToJson;
*Dump    = \&objToJson;
*encode  = \&objToJson;


sub jsonToObj {
    my $self = shift;
    my $obj  = shift;
    croak 'must provide json to convert' unless defined $obj;

    # some handlers can't parse single booleans (I'm looking at you DWIW)
    if ( $obj =~ /^(true|false)$/ ) {
        return $self->$1;
    }

    if ( ref $self ) {
        my $method;
        unless ( ref $self->[DECODER] ) {
            croak "No $handler Object created!"
              unless exists $self->[HANDLER];
            $method = $self->[HANDLER]->can( $self->[DECODER] );
            croak "$handler can't execute $self->[DECODER]" unless $method;
        }
        else {
            $method = $self->[DECODER];
        }
        return $self->[HANDLER]->$method($obj);
    }
    $handler->can($decoder)->($obj);
}


*from_json = \&jsonToObj;
*Load      = \&jsonToObj;
*decode    = \&jsonToObj;

1;

__END__

=pod

=head1 NAME

JSON::Any - Wrapper Class for the various JSON classes.

=head1 VERSION

version 1.32

=head1 SYNOPSIS

This module tries to provide a coherent API to bring together the various JSON
modules currently on CPAN. This module will allow you to code to any JSON API
and have it work regardless of which JSON module is actually installed.

	use JSON::Any;

	my $j = JSON::Any->new;

	$json = $j->objToJson({foo=>'bar', baz=>'quux'});
	$obj = $j->jsonToObj($json);

or

	$json = $j->encode({foo=>'bar', baz=>'quux'});
	$obj = $j->decode($json);

or

	$json = $j->Dump({foo=>'bar', baz=>'quux'});
	$obj = $j->Load($json);

or

	$json = $j->to_json({foo=>'bar', baz=>'quux'});
	$obj = $j->from_json($json);

or without creating an object:

	$json = JSON::Any->objToJson({foo=>'bar', baz=>'quux'});
	$obj = JSON::Any->jsonToObj($json);

On load, JSON::Any will find a valid JSON module in your @INC by looking 
for them in this order:

    Cpanel::JSON::XS
	JSON::XS 
    JSON::PP
	JSON 
	JSON::DWIW 

And loading the first one it finds.

You may change the order by specifying it on the C<use JSON::Any> line:

	use JSON::Any qw(DWIW XS CPANEL JSON PP);

Specifying an order that is missing modules will prevent those module from 
being used:

	use JSON::Any qw(CPANEL PP); # same as JSON::MaybeXS

This will check in that order, and will never attempt to load JSON::XS, 
JSON.pm, or JSON::DWIW. This can also be set via the $ENV{JSON_ANY_ORDER} 
environment variable.

JSON::Syck has been deprecated by it's author, but in the attempt to still
stay relevant as a "Compat Layer" JSON::Any still supports it. This support
however has been made optional starting with JSON::Any 1.19. In deference to a
bug request starting with JSON 1.20 JSON::Syck and other deprecated modules
will still be installed, but only as a last resort and will now include a
warning. 

    use JSON::Any qw(Syck XS JSON); 

or 

    $ENV{JSON_ANY_ORDER} = 'Syck XS JSON';

WARNING: If you call JSON::Any with an empty list

    use JSON::Any ();

It will skip the JSON package detection routines and will die loudly that it
couldn't find a package.

=head1 NAME 

JSON::Any

=head1 VERSION

version 1.32

=head1 WARNING

JSON::XS 3.0 or higher has a conflict with any version of JSON.pm less than 2.90 
when  you use JSON.pm's C<-support_by_pp> option, which JSON::Any enables by 
default.

This situation should only come up with JSON::Any if you have JSON.pm 2.61 or 
lower and JSON::XS 3.0 or higher installed and you for JSON::Any to use JSON.pm 
via C<use JSON::Any qw(JSON);> or the C<JSON_ANY_ORDER> environment variable.

If you run into an issue where you're getting recursive inheritance errors in a 
Types::Serialiser package, please try upgrading JSON.pm to 2.90 or higher.

=head1 DEPRECATION

The original need for JSON::Any has been solved (quite some time ago
actually). If you're producing new code it is recommended to use JSON.pm which
will optionally use JSON::XS for speed purposes.

JSON::Any will continue to be maintained for compatibility with existing code,
and frankly because the maintainer prefers the JSON::Any API.

=head1 METHODS

=over

=item C<new>

Will take any of the parameters for the underlying system and pass them
through. However these values don't map between JSON modules, so, from a
portability standpoint this is really only helpful for those parameters that
happen to have the same name. This will be addressed in a future release.

The one parameter that is universally supported (to the extent that is
supported by the underlying JSON modules) is C<utf8>. When this parameter is
enabled all resulting JSON will be marked as unicode, and all unicode strings
in the input data structure will be preserved as such.

Also note that the C<allow_blessed> parameter is recognised by all the modules
that throw exceptions when a blessed reference is given them meaning that
setting it to true works for all modules. Of course, that means that you
cannot set it to false intentionally in order to always get such exceptions.

The actual output will vary, for example L<JSON> will encode and decode
unicode chars (the resulting JSON is not unicode) whereas L<JSON::XS> will emit
unicode JSON.

=back

=over

=item C<handlerType>

Takes no arguments, returns a string indicating which JSON Module is in use.

=back

=over

=item C<handler>

Takes no arguments, if called on an object returns the internal JSON::* 
object in use.  Otherwise returns the JSON::* package we are using for 
class methods.

=back

=over

=item C<true>

Takes no arguments, returns the special value that the internal JSON
object uses to map to a JSON C<true> boolean.

=back

=over

=item C<false>

Takes no arguments, returns the special value that the internal JSON
object uses to map to a JSON C<false> boolean.

=back

=over

=item C<objToJson>

Takes a single argument, a hashref to be converted into JSON.
It returns the JSON text in a scalar.

=back

=over

=item C<to_json>

=item C<Dump>

=item C<encode>

Aliases for objToJson, can be used interchangeably, regardless of the 
underlying JSON module.

=back

=over

=item C<jsonToObj>

Takes a single argument, a string of JSON text to be converted
back into a hashref.

=back

=over

=item C<from_json>

=item C<Load>

=item C<decode>

Aliases for jsonToObj, can be used interchangeably, regardless of the 
underlying JSON module.

=back

=head1 ACKNOWLEDGEMENTS

This module came about after discussions on irc.perl.org about the fact 
that there were now six separate JSON perl modules with different interfaces.

In the spirit of Class::Any, JSON::Any was created with the considerable 
help of Matt 'mst' Trout.

Simon Wistow graciously supplied a patch for backwards compat with JSON::XS 
versions previous to 2.01

San Dimas High School Football Rules!

=head1 AUTHORS

=over 4

=item *

Chris Thompson <cthom@cpan.org>

=item *

Chris Prather <chris@prather.org>

=item *

Robin Berjon <robin@berjon.com>

=item *

Marc Mims <marc@questright.com>

=item *

Tomas Doran <bobtfish@bobtfish.net>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Chris Thompson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 CONTRIBUTORS

=over 4

=item *

Chris Prather <cprather@hdpublishing.com>

=item *

Dagfinn Ilmari Mannsåker <ilmari@ilmari.org>

=item *

Justin Hunter <justin.d.hunter@gmail.com>

=item *

Matthew Horsfall <wolfsage@gmail.com>

=item *

Todd Rinaldo <toddr@cpan.org>

=item *

marc.mims <marc.mims@daca5766-e62f-0410-9ddd-e5e43faa6270>

=item *

nothingmuch@woobling.org <nothingmuch@woobling.org@daca5766-e62f-0410-9ddd-e5e43faa6270>

=item *

perigrin <perigrin@daca5766-e62f-0410-9ddd-e5e43faa6270>

=item *

robin.berjon@gmail.com <robin.berjon@gmail.com@daca5766-e62f-0410-9ddd-e5e43faa6270>

=back

=cut
