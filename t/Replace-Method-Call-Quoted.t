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

sub to_sorce : Tests {

    is ReplaceMethodCall::Quoted->new(1)->to_source, q{ReplaceMethodCall::Quoted->new(1)};
    is ReplaceMethodCall::Quoted->new('hi')->to_source, q{ReplaceMethodCall::Quoted->new('hi')};
    is ReplaceMethodCall::Quoted->new('$user->name')->to_source, q{ReplaceMethodCall::Quoted->new('$user->name')};
}

