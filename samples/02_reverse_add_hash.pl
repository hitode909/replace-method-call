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
        my $hash = {@$args};
        my $arg1 = $hash->{a};
        my $arg2 = $hash->{b};
        "reverse_add(a => @{[ $r->quote($arg2) ]}, b => @{[ $r->quote($arg1) ]})";
    },
);

$r->file(@ARGV);

# carton exec -- perl samples/02_reverse_add_hash.pl samples/02_in.pl samples/02_out.pl
