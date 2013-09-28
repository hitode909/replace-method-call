package t::ReplaceMethodCall;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'ReplaceMethodCall';
}

sub instantiate: Tests {
    isa_ok ReplaceMethodCall->new, 'ReplaceMethodCall';
}

sub register : Tests {

    my $r = ReplaceMethodCall->new;
    cmp_deeply $r->rules, [];

    $r->register(
        method_name => 'foo',
        apply => sub { },
    );

    cmp_deeply $r->rules, [
        isa('ReplaceMethodCall::Rule')  & methods(
            method_name => 'foo',
            apply => isa('CODE'),
        )
    ];
}

1;
