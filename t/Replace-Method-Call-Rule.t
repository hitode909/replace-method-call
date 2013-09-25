package t::ReplaceMethodCall::Rule;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'ReplaceMethodCall::Rule';
}

sub instantiate : Tests {
    isa_ok ReplaceMethodCall::Rule->new, 'ReplaceMethodCall::Rule';
}

sub match_no_args : Tests {
    my $rule = ReplaceMethodCall::Rule->new(
        method_name => 'exit',
        arguments => [],
        apply => sub { 'success' },
    );

    my $doc = doc_from_content('exit()');
    my $statement = $doc->find('PPI::Statement')->[0];

    my $matched = $rule->match($statement);
    cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
         & methods(
             method_name => 'exit',
             part1 => [],
             part2 => [],
             structured_args => [],
         );
}


sub match_scalar : Tests {
    my $rule = ReplaceMethodCall::Rule->new(
        method_name => 'puts',
        arguments => [qw(scalar)],
        apply => sub { 'success' },
    );

    my $doc = doc_from_content('puts("hello")');
    my $statement = $doc->find('PPI::Statement')->[0];

    my $matched = $rule->match($statement);
    cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
         & methods(
             method_name => 'puts',
             part1 => [],
             part2 => [],
             structured_args => [ q("hello") ],
         );
}

sub match_scalar2 : Tests {
    my $rule = ReplaceMethodCall::Rule->new(
        method_name => 'add',
        arguments => [qw(scalar scalar)],
        apply => sub { 'success' },
    );

    my $doc = doc_from_content('add(1, 2)');
    my $statement = $doc->find('PPI::Statement')->[0];

    my $matched = $rule->match($statement);
    cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
         & methods(
             method_name => 'add',
             part1 => [],
             part2 => [],
             structured_args => [ 1, 2 ],
         );
}

sub match_list : Tests {
    my $rule = ReplaceMethodCall::Rule->new(
        method_name => 'l',
        arguments => [qw(list)],
        apply => sub { 'success' },
    );

    subtest 'empty' => sub {
        my $doc = doc_from_content('l()');
        my $statement = $doc->find('PPI::Statement')->[0];

        my $matched = $rule->match($statement);
        cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
            & methods(
                method_name => 'l',
                part1 => [],
                part2 => [],
                structured_args => [ [] ],
            );
    };

    subtest '1 argument' => sub {
        my $doc = doc_from_content('l(1)');
        my $statement = $doc->find('PPI::Statement')->[0];

        my $matched = $rule->match($statement);
        cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
            & methods(
                method_name => 'l',
                part1 => [],
                part2 => [],
                structured_args => [ [1] ],
            );
    };

    subtest '2 argument' => sub {
        my $doc = doc_from_content('l(1 , 2)');
        my $statement = $doc->find('PPI::Statement')->[0];

        my $matched = $rule->match($statement);
        cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
            & methods(
                method_name => 'l',
                part1 => [],
                part2 => [],
                structured_args => [ [1, 2] ],
            );
    };
}

1;
