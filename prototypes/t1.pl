#!/usr/bin/env perl
use strict; use warnings;
use Perl6::Say;
use Data::Dumper;
use Ouch;
use Try::Tiny;

my $argz1 = [
        [ 'ASSERT', 'Location', [], ],
        [ 'ASSERT', 'Location', [], ],
        [ undef,    'Location', [], ],
        [ undef,    'Wallet',   [], ],
        [ undef,    'Clone',    [], ],
        [ 'FAILURE','Wallet',   [], ],
        [ 'ALWAYS', 'Wallet',   [], ],
];
my $argz2 = [
        [ 'ASSERT', 'Location', [], ],
        [ undef,    'Location', [], ],
        [ 'ASSERT', 'Location', [], ],
        [ undef,    'Wallet',   [], ],
        [ undef,    'Beavis',   [], ],
        [ undef,    'Clone',    [], ],
        [ 'FAILURE','Fail-Wallet',   [], ],
        [ 'ALWAYS', 'Always-Wallet',   [], ],
        [ undef,    'Wallet',   [], ],
        [ undef,    'Clone',    [], ],
];

sub st {
   my (@args) = @_;
   my ($Ablock, $TRblock, $TLblock)=(0,0,0);
   my $rc=0;
   my ($pos, $i) = (0, 0);
   try {
      while (($pos, $i) = each @args) {
         if ($Ablock) {
            if (not (defined($$i[0])) ) {
               $Ablock=0;
               $TRblock=1;
               BEGIN_TRANSACTION();
               $rc = dispatch( 'Transaction', $$i[1], $$i[2]);
            } elsif ($$i[0] eq 'ASSERT') {
               $rc = dispatch( 'Assertion', $$i[1], $$i[2]);
            } else {
               ouch 'Bad stanza', 'In ASSERT block followed by another label';
            }
         } elsif ($TRblock) {
            if (not (defined($$i[0]))) {
               $rc = dispatch( 'Transaction', $$i[1], $$i[2]);
            } else {
               END_TRANSACTION();
               $TRblock=0;
               if ($$i[0] eq 'ASSERT') {
                  $Ablock=1;
                  $rc = dispatch( 'Assertion', $$i[1], $$i[2]);
               }
               else {
                  $TLblock=1;
                  $rc = dispatch( 'Tail', $$i[1], $$i[2]);
               }
            }
         } elsif ($TLblock) {
            if (not (defined($$i[0]))) {
               $TLblock=0;
               $TRblock=1;
               BEGIN_TRANSACTION();
               $rc = dispatch( 'Transaction', $$i[1], $$i[2]);
            } else {
               if ($$i[0] eq 'ASSERT') {
                  $TLblock=0;
                  $Ablock=1;
                  $rc = dispatch( 'Assertion', $$i[1], $$i[2]);
               }
               else {
                  $rc = dispatch( 'Tail', $$i[1], $$i[2]);
               }
            }
         } else {
            if (not (defined($$i[0])) ) {
               $TRblock=1;
               BEGIN_TRANSACTION();
               $rc = dispatch( 'Transaction', $$i[1], $$i[2]);
            } elsif ($$i[0] eq 'ASSERT')  {
               $Ablock=1;
               $rc = dispatch( 'Assertion', $$i[1], $$i[2]);
            } else {
               $TLblock=1;
               $rc = dispatch( 'Tail', $$i[1], $$i[2]);
            }
         }
      }
      END_TRANSACTION() if ($TRblock);
   } 
   catch {
      if ($TRblock) {
         say "Transaction ROLLBACK";
         my $rc = 0;
         my $TLblock=0;
         for ( my $j = $pos + 1; $j <= $#args; $j++) {
            if ($TLblock) {
               if (not (defined($args[$j]->[0])) ) {
                  last;
               } else {
                  if ($args[$j]->[0] eq 'FAILURE')  {
                     $rc = dispatch( 'Tail', $args[$j]->[1], $args[$j]->[2]);
                  } elsif ($args[$j]->[0] eq 'ALWAYS')  {
                     $rc = dispatch( 'Tail', $args[$j]->[1], $args[$j]->[2]);
                  } else {
                     $TLblock=0;
                     last;
                  }
               }
            } else {
               if (not (defined($args[$j]->[0])) ) {
                  next;
               } else {
                  if ($args[$j]->[0] eq 'FAILURE')  {
                     $TLblock=1;
                     $rc = dispatch( 'Tail', $args[$j]->[1], $args[$j]->[2]);
                  } elsif ($args[$j]->[0] eq 'ALWAYS')  {
                     $rc = dispatch( 'Tail', $args[$j]->[1], $args[$j]->[2]);
                  } else {
                     $TLblock=0;
                     last;
                  }
               }
            }
         
         }
         say "Tailing Steps done";
      }
      die $_; # rethrow
   };

}

sub BEGIN_TRANSACTION { say 'begin transaction'; }
sub END_TRANSACTION   { say 'end transaction';   }

sub dispatch {
   my ($type, $asset, $args) = @_;
   say "Type: $type Asset: $asset";
   if ($asset eq 'Beavis') {
      ouch 'Bad Asset', "dam error [$@] [$!]";
#     return;  Just a reminder!!!
   }
   
   return 0;
}

st (@{$argz1});
#st (@{$argz2});
exit 0;

