package StepTransaction;
use strict; use warnings; use feature 'say';
use feature ':all';
use Carp 'croak';
use Switch::Plain;
use Data::Dumper;
use Data::TreeDumper;
use Try::Tiny;
use Ouch;
BEGIN {
   our $VERSION  = 0.0001;
   require Exporter;
   our @ISA      = qw(Exporter);
   our @EXPORT   = qw(Steps); # subs & vars exported by default
}

use V::Clone;
use V::Location;
use V::Wallet;

sub rtn_a_string {
    return shift;
}
sub dispatch {
   my ($asset, $args) = @_;

#   say Dumper(\$args);
#   print DumpTree($args, 'dispatched') ;

   my $obj;
   my $packagebase = 'V::';
   # string version
   #  sswitch (get_me_a_string()) {
   # return value of get_me_a_string() is bound to $_ in this block
   sswitch (rtn_a_string($asset)) {
      case 'Clone': {
	  if ( -e '/tmp/step') { return 1; }
          say "dispatching a Clone";
          $obj = V::Clone->new($args);
      }
      case 'Location': {
          say "dispatching a Location";
#          $obj = V::Location->new($args);
	  my $assetpack = $packagebase . $asset;
          $obj = $assetpack->new($args);
      }
      case 'Wallet': {
          say "dispatching a Wallet";
          $obj = V::Wallet->new($args);
      }
      default: { croak "Bad switching: $asset"; }
   }
#   say Dumper(\$obj);

   return 0;
}

sub Steps {
   print "Steps\n";
   my (@args) = @_;
   my $rc;
   try {
      # BEGIN_TRANSACTION();
      foreach my $i (@args) {
         if (not defined($$i[0])) {
            $rc = dispatch( $$i[1], $$i[2]);
            if ($rc) {
               ouch 'Blame JT Smith', 'Dude, Fix your code';
               last;
            }
         }
      }
      # END_TRANSACTION();
   }
   catch {
      # ROLL_BACK();
      say "FAILURE";
      dispatch_by_label('FAILURE', @args); 
      if (kiss(600, $_)) {
        say "kissed an exception";
      } else {
        die $_; # rethrow
      }
   }
   finally {
      say "ALWAYS";
      dispatch_by_label('ALWAYS', @args); 
   };

   say "end of Steps";
   return $rc;
}

sub dispatch_by_label {
   print "dispatch_by_label\n";
   my ($type, @args) = @_;
   my $rc=0;
   foreach my $i (@args) {
      if ( (defined($$i[0])) and ($$i[0] eq $type) ) {
         $rc = dispatch( $$i[1], $$i[2]);
      }
   }
   return $rc;
}

1;
