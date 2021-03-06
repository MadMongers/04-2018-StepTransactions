use strict; use warnings;
package PurchaseClones;
use feature 'say';
use Moo;
use StepTransaction 'Steps';
use myfilter;

has key => (
   is      => 'rw',
   default => undef,
);

sub new_exchange {
   my ($slug,        $slugtxt, 
       $successmsg,  $successmsgtxt,
       $failuresmsg, $failuresmsgtxt,
       $steps_rc) = @_;
   return PurchaseClones->new();
}

sub price {
   say "\t\t\tPurchaseClones price";
   return 1;
}

sub station_area {
   say "\t\t\tPurchaseClones station_area";
   return 1;
}

sub attempt {
   say "\t\t\tAttempt: finsh";
   return 1;
}

sub purchase_clone {
   say 'purchase_clone';
   my ($self) = @_;
   my $character = "and Irvine";
   my $bet_amount = 1_000_006;
   my $exchange = new_exchange(
      slug            => 'purchase-clone',
      success_message => 'You have purchased a new clone',
      failure_message => 'You could not purchase a new clone',
      Steps(
                  Location( $self      => is_in_area   => 'clonevat'              ),
                  Wallet(   $self      => pay          => $self->price('cloning') ),
                  Clone(    $self      => gestate      => $self->station_area     ),
         FAILURE( Wallet(   $character => remove       => $bet_amount ) ),
         ALWAYS(  Wallet( $character => show_balance ) ),
      ),
   )->attempt;
}
sub purchase_clone2 {
   say 'purchase_clone2';
   my ($self) = @_;
   my $character = "and Irvine";
   my $bet_amount = 1_000_006;
   my $exchange = new_exchange(
      slug            => 'purchase-clone',
      success_message => 'You have purchased a new clone',
      failure_message => 'You could not purchase a new clone',
      Steps(
                  Location( $self      => is_in_area   => 'clonevat'              ),
                  Wallet(   $self      => pay          => $self->price('cloning') ),
                  Clone(    $self      => gestate      => $self->station_area     ),
         FAILURE( Wallet(   $character => remove       => $bet_amount ) ),
         ALWAYS(  Wallet( $character => show_balance ) ),
      ),
   )->attempt;
}

sub scavenge {
  my ($self) = @_;
  my $inventory    = '';
  my $station_area = '';

  my $key = 'found-item';

  my $focus_cost = 256;
  my $stamina_cost = 13;

  my $exchange = $self->new_exchange(
    slug => 'scavenge',
    Steps(
      ASSERT( Location( $self => can_scavenge => $station_area )),
      ASSERT( Stats( $self => minimum_required => { curr_stamina => $stamina_cost, focus => $focus_cost, })),
              Location( $self => scavenge => { station_area => $station_area, key => $key, }),
      ALWAYS( Stats( $self => remove => { curr_stamina => $stamina_cost })),
              Stats( $self => remove => { focus => $focus_cost }),
              Inventory( $inventory => add_item => { item => $key, new_key => 'found' }),
              Event( $self => store => { event_type => 'find', stashed    => { item => $key } }),
    ),
  );

  return $exchange->attempt;
}
1;
