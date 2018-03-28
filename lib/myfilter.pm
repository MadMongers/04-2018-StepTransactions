package myfilter;
use strict; use warnings;

use Filter::Util::Call;

sub _make_args {
   my $str = shift;
   my $args;
   foreach my $x (split/ => /,$str) {
   $x =~ s/ //g;
      if ($x =~ /\A('|\$)/) {
         $args .= qq/$x, /;
      } else {
         $args .= qq/'$x', /;
      }
   }
   return $args;
}

sub import {
  my ($self,)=@_;
  my ($found)=0;

  filter_add( 
    sub {
      my ($status) ;

      if (($status = filter_read()) > 0) {
        if ($found == 0 and /Steps\(/) { 
#          $_ = "Steps(\n";
          $found = 1; 
        }
        if ($found) {
          if (/;\s*\z/) {
	     $found = 0;
          } elsif (/\b(?<post_trans>FAILURE|ALWAYS)\(\s*(?<func>\w.*?)\(\s*(?<args>.*)\)\s*\)\s*\,\s*\z/) {
            my $argz = _make_args($+{args});
            $_ = "[ '$+{post_trans}', '$+{func}', [$argz],  ],\n";
          } else {
            if (   /\b(?<func>\w.*?)\(\s*(?<args>.*)\)/   ) {
              my $argz = _make_args($+{args});
              $_ = "[ undef, '$+{func}', [ $argz ],  ],\n";
            }
          }
        }
      }
      $status;  # return status;
    } 
 )
}
1 ;
