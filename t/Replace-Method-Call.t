package t::ReplaceMethodCall;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'ReplaceMethodCall';
}

sub instantiate: Tests {
    isa_ok ReplaceMethodCall->new, 'ReplaceMethodCall';
}

1;
