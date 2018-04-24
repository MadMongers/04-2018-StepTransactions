package V::Inventory;
use strict; use warnings; use feature 'say'; use Moo;
use Ouch;

has key => (
   is      => 'rw',
   default => undef,
);

around BUILDARGS => sub {
   my ( $orig, $class, @args ) = @_;

   return { key => 'Inventory' }
#   return { attr1 => $args[0] }
#      if @args == 1 && !ref $args[0];
#
#   return $class->$orig(@args);
};

1;
