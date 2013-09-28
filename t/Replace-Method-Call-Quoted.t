package t::ReplaceMethodCall::Quoted;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'ReplaceMethodCall::Quoted';
}

sub instantiate : Tests {
    isa_ok ReplaceMethodCall::Quoted->new, 'ReplaceMethodCall::Quoted';
}

sub content : Tests {
    my $q = ReplaceMethodCall::Quoted->new('hi');
    is $q->content, 'hi';
}

