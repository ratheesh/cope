#!/usr/bin/env perl
package App::Cope::Extra;
use strict;
no if $] >= 5.018, warnings => "experimental";
use 5.010_000;

=head1 NAME

App::Cope::Extra - Pre-defined highlighting syntax for common patterns

=head2 SYNOPSIS

  use App::Cope::Extra;

  line qr{User: (\S+)} => \&{ user 'yellow' };
  line qr{([0-9.]+ ms)} => \&ping_time;

=head2 DESCRIPTION

App::Cope::Extra contains several common patterns to save you from
incessantly defining them. Functions that take a colour parameter
return functions, so you can use them using the consistant C<\&>
syntax.

No functions are exported by default.

=cut

use base q[Exporter];
our @EXPORT_OK = qw[ %permissions %filetypes
                     user nonzero ping_time
                     percent percent_b ];

=head1 VARIABLES

=head2 %permissions

Describes the single-character UNIX permissions;

=cut

our %permissions = (
  'r' => 'yellow bold',
  'w' => 'red bold',
  'x' => 'green bold',
  '-' => 'black bold',
  's' => 'magenta bold',
  'S' => 'magenta',
  't' => 'green',
  'T' => 'green bold',
);

=head2 %filetypes

Describes the single-character file type descriptions.

=cut

our %filetypes = (
  'b' => 'magenta',    # block special
  'c' => 'magenta',    # character special
  'C' => 'red',        # contiguous data
  'd' => 'blue',       # directory
  'D' => 'red',        # door
  'l' => 'cyan',       # symlink
  'M' => 'red',        # offline file
  'n' => 'red',        # network special
  'p' => 'yellow',     # named pipe
  'P' => 'red',        # port
  's' => 'yellow',     # socket
);

=head1 FUNCTIONS

=head2 nonzero( $colour )

If the number given is not equal to zero, return the colour
bold. Else, return it plain.

=cut

sub nonzero {
  my $colour = shift;
  return sub {
    my $val = shift;
    ( $val !~ /^0+(\.0+)?$/ ) ? "$colour bold" : "$colour";
  };
}

=head2 user( $colour )

If the string is equal to the current user name or ID, return the
colour in bold. Else, return it plain.

=cut

my $me = (getpwuid( $< ))[0] || "nobody";

sub user {
  my $colour = shift || 'yellow';
  return sub {
    my $uid = shift;
    ( $uid eq $me || $uid eq $< ) ? "$colour bold" : "$colour";
  };
}

=head2 percent( $lower, $middle, $upper )

Returns a colour based on the percentage, going from red, to yellow,
to green, to bold. Low values are made red.

=cut

sub percent {
  my ( $lower, $middle, $upper ) = @_;
  return sub {
    my $pct = shift;
    $pct =~ s/^(\d+).+/$1/;	# extract number
    given ($pct) {
      when ( $_ >= $upper  ) { return 'bold' }
      when ( $_ >= $middle ) { return 'green bold' }
      when ( $_ >= $lower  ) { return 'yellow bold' }
      default                { return 'red bold' }
    }
  };
}

=head2 percent_b( $lower, $middle, $upper )

Returns a colour based on the percentage, going from bold, to green,
to yellow, to red. High values are made red.

=cut

sub percent_b {
  my ( $lower, $middle, $upper ) = @_;
  return sub {
    my $pct = shift;
    $pct =~ s/^(\d+).+/$1/;	# extract number
    given ($pct) {
      when ( $_ >= $upper  ) { return 'red bold' }
      when ( $_ >= $middle ) { return 'yellow bold' }
      when ( $_ >= $lower  ) { return 'green bold' }
      default                { return 'bold' }
    }
  };
}

=head2 ping_time

Takes a ping time in milliseconds, and returns green/yellow/red
depending on how long the ping took.

=cut

sub ping_time {
  my ($ms) = @_;
  if ($ms =~ m/(\d+)/) {
    given ($1) {
      when ( $_ >= 200 ) { return 'red bold' }
      when ( $_ >= 100 ) { return 'yellow bold' }
      default            { return 'green bold' }
    }
  }
  return '';
}

