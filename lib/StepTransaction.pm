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
use V::Event;
use V::Inventory;
use V::Location;
use V::Stats;
use V::Wallet;


sub rtn_a_string {
    return shift;
}
sub dispatch {
   my ($type, $asset, $args) = @_;
#   my ($asset, $args) = @_;

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
      case 'Event': {
          say "dispatching a Event";
          $obj = V::Event->new($args);
      }
      case 'Inventory': {
          say "dispatching a Inventory";
          $obj = V::Inventory->new($args);
      }
      case 'Location': {
          say "dispatching a Location";
#          $obj = V::Location->new($args);
	  my $assetpack = $packagebase . $asset;
          $obj = $assetpack->new($args);
      }
      case 'Stats': {
          say "dispatching a Stats";
          $obj = V::Stats->new($args);
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
   my ($Ablock, $TRblock, $TLblock)=(0,0,0);
   my $rc = 0;
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

   say "end of Steps";
   return $rc;
}

sub BEGIN_TRANSACTION { say 'begin transaction'; }
sub END_TRANSACTION   { say 'end transaction';   }
1;
