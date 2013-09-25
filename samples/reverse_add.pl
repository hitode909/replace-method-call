use strict;
use warnings;
use FindBin;
use lib 'lib';
use lib "$FindBin::Bin/../lib";
use ReplaceMethodCall;

my $replacer = ReplaceMethodCall->new;

$replacer->register(
    method_name => 'add',
    arguments => [qw(scalar scalar)],
    apply => sub {
        my ($arg1, $arg2) = @_;
        "reverse_add($arg2, $arg1)"
    },
);

$replacer->file(@ARGV);

# carton exec -- perl samples/reverse_add.pl samples/in.pl samples/out.pl
