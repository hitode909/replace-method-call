use strict;
use warnings;
use FindBin;
use lib 'lib';
use lib "$FindBin::Bin/../lib";
use ReplaceMethodCall;

my $r = ReplaceMethodCall->new;

$r->register(
    method_name => 'add',
    apply => sub {
        my ($args) = @_;
        my $arg1 = $args->[0];
        my $arg2 = $args->[1];
        "reverse_add(@{[ $r->quote($arg2) ]}, @{[ $r->quote($arg1) ]})";
    },
);

$r->file(@ARGV);

# carton exec -- perl samples/01_reverse_add.pl samples/01_in.pl samples/01_out.pl
