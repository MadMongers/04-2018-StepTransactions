package V::Clone;
use strict; use warnings; use feature 'say'; use Moo;
use Ouch;

has key => (
   is      => 'rw',
   default => undef,
);

around BUILDARGS => sub {
   my ( $orig, $class, @args ) = @_;

   if (-e '/tmp/kiss') { ouch 600, 'i am in clone'; }
   if (-e '/tmp/ouch') { ouch 601, 'i am in clone'; }

   return { key => 'Clone' }
#   return { attr1 => $args[0] }
#      if @args == 1 && !ref $args[0];
#
#   return $class->$orig(@args);
};

1;
