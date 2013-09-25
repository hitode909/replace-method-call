package t::ReplaceMethodCall::Rule;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'ReplaceMethodCall::Rule';
}

sub instantiate: Tests {
    isa_ok ReplaceMethodCall::Rule->new, 'ReplaceMethodCall::Rule';
}

1;
