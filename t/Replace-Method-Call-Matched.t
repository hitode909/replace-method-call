package t::ReplaceMethodCall::Matched;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'ReplaceMethodCall::Matched';
}

sub instantiate: Tests {
    isa_ok ReplaceMethodCall::Matched->new, 'ReplaceMethodCall::Matched';
}

1;
