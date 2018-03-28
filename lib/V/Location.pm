package V::Location;
use strict; use warnings; use feature 'say'; use Moo;

has key => (
   is      => 'rw',
   default => undef,
);

around BUILDARGS => sub {
   my ( $orig, $class, @args ) = @_;

   return { key => 'Location' }
#   return { attr1 => $args[0] }
#      if @args == 1 && !ref $args[0];
#
#   return $class->$orig(@args);
};


1;
