package Check;

use strict;
use warnings;
use base qw(Exporter);
use Common;


our @EXPORT_OK = qw(check_required check_tel check_pnumber check_choice check_selected);
our @EXPORT = @EXPORT_OK;

sub check_required {
    fail($_[1]||"required") unless $_[0];
}

sub check_tel {
    fail $_[1]||"not tel" unless $_[0] =~ /^(\+\d{2})?\d{11}$/;
}

sub check_pnumber {
    fail $_[1]||"not pnumber" unless $_[0] =~ /^\d+(\.\d+)?$/;
}

sub check_choice {
    for my $item (@{$_[1]}) {
        return if $item eq $_[0];
    }
    fail $_[2]||"not choice";
}

sub check_selected {
    fail $_[1]||"not selected" if (!$_[0] || $_[0] eq '0');
}

1;
