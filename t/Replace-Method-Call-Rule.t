package t::ReplaceMethodCall::Rule;
use t::test;

use ReplaceMethodCall::Quoted;

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
    );

    subtest 'when match' => sub {
        my $doc = doc_from_content('exit()');
        my $statement = $doc->find('PPI::Statement')->[0];
        my $matched = $rule->match($statement);
        cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
            & methods(
                method_name => 'exit',
                part1 => [],
                part2 => [],
                args => [],
            );
    };

    subtest 'when not match' => sub {
        my $doc = doc_from_content('not_exit()');
        my $statement = $doc->find('PPI::Statement')->[0];
        my $matched = $rule->match($statement);
        is $matched, undef;
    };
}

sub parts : Tests {
    my $rule = ReplaceMethodCall::Rule->new(
        method_name => 'foo',
    );

    my $doc = doc_from_content('print foo()->bar()');
    my $statement = $doc->find('PPI::Statement')->[0];
    my $matched = $rule->match($statement);
    cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
            & methods(
                method_name => 'foo',
                part1 => ['print', ' '],
                part2 => ['->', 'bar', '(', ')'],
                args => [],
            );
}

sub dont_match_sub : Tests {
    my $rule = ReplaceMethodCall::Rule->new(
        method_name => 'foo',
    );

    my $doc = doc_from_content('sub foo { print(1); }');
    my $statement = $doc->find('PPI::Statement')->[0];
    my $matched = $rule->match($statement);
    is $matched, undef;
}

sub match_scalar : Tests {
    my $rule = ReplaceMethodCall::Rule->new(
        method_name => 'puts',
    );

    subtest 'number' => sub {
        my $doc = doc_from_content('puts(1)');
        my $statement = $doc->find('PPI::Statement')->[0];

        my $matched = $rule->match($statement);
        cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
            & methods(
                method_name => 'puts',
                part1 => [],
                part2 => [],
                args => [ 1 ],
            );
    };

    subtest 'string' => sub {
        my $doc = doc_from_content('puts("hello")');
        my $statement = $doc->find('PPI::Statement')->[0];

        my $matched = $rule->match($statement);
        cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
            & methods(
                method_name => 'puts',
                part1 => [],
                part2 => [],
                args => [ q(hello) ],
            );
    };

    subtest 'variable' => sub {
        my $doc = doc_from_content('puts($name)');
        my $statement = $doc->find('PPI::Statement')->[0];

        my $matched = $rule->match($statement);
        cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
            & methods(
                method_name => 'puts',
                part1 => [],
                part2 => [],
                args => [ isa('ReplaceMethodCall::Quoted')  & methods(content => q($name)) ],
            );
    };

    subtest 'method' => sub {
        my $doc = doc_from_content('puts($user->name)');
        my $statement = $doc->find('PPI::Statement')->[0];

        my $matched = $rule->match($statement);
        cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
            & methods(
                method_name => 'puts',
                part1 => [],
                part2 => [],
                args => [ isa('ReplaceMethodCall::Quoted')  & methods(content => q($user->name)) ],
            );
    };

    subtest 'two methods' => sub {
        my $doc = doc_from_content('puts($user->name, $user->name)');
        my $statement = $doc->find('PPI::Statement')->[0];

        my $matched = $rule->match($statement);
        cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
            & methods(
                method_name => 'puts',
                part1 => [],
                part2 => [],
                args => [
                    isa('ReplaceMethodCall::Quoted')  & methods(content => q($user->name)),
                    isa('ReplaceMethodCall::Quoted')  & methods(content => q($user->name)),
                ],

            );
    };

    subtest 'method with paren' => sub {
        my $doc = doc_from_content('puts($user->name(1))');
        my $statement = $doc->find('PPI::Statement')->[0];

        my $matched = $rule->match($statement);
        cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
            & methods(
                method_name => 'puts',
                part1 => [],
                part2 => [],
                args => [ isa('ReplaceMethodCall::Quoted')  & methods(content => q($user->name(1))) ],
            );
    };

    subtest 'nested method call' => sub {
        my $doc = doc_from_content('puts($user->name($user->name(1)))');
        my $statement = $doc->find('PPI::Statement')->[0];

        my $matched = $rule->match($statement);
        cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
            & methods(
                method_name => 'puts',
                part1 => [],
                part2 => [],
                args => [ isa('ReplaceMethodCall::Quoted')  & methods(content => q{$user->name($user->name(1))}) ],
            );
    };
}

sub match_scalar_two : Tests {
    my $rule = ReplaceMethodCall::Rule->new(
        method_name => 'add',
    );

    my $doc = doc_from_content('add(1, 2)');
    my $statement = $doc->find('PPI::Statement')->[0];

    my $matched = $rule->match($statement);
    cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
         & methods(
             method_name => 'add',
             part1 => [],
             part2 => [],
             args => [ 1, 2 ],
         );
}

sub match_hash : Tests {
    my $rule = ReplaceMethodCall::Rule->new(
        method_name => 'dump',
    );

    subtest 'empty' => sub {
        my $doc = doc_from_content('dump({})');
        my $statement = $doc->find('PPI::Statement')->[0];

        my $matched = $rule->match($statement);
        cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
            & methods(
                method_name => 'dump',
                part1 => [],
                part2 => [],
                args => [ {} ],
            );
    };

    subtest 'number, string' => sub {
        my $doc = doc_from_content('dump({num => 1, str => "a"})');
        my $statement = $doc->find('PPI::Statement')->[0];

        my $matched = $rule->match($statement);
        cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
            & methods(
                method_name => 'dump',
                part1 => [],
                part2 => [],
                args => [ {num => 1, str => "a"} ],
            );
    };

    subtest 'variable, method' => sub {
        my $doc = doc_from_content('dump({var => $var, method => $obj->method})');
        my $statement = $doc->find('PPI::Statement')->[0];

        my $matched = $rule->match($statement);
        cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
            & methods(
                method_name => 'dump',
                part1 => [],
                part2 => [],
                # args => [ +{ var => '$var', method => '$obj->method'} ],
            );
    };
}

sub match_array : Tests {
    my $rule = ReplaceMethodCall::Rule->new(
        method_name => 'l',
    );

    subtest 'empty' => sub {
        my $doc = doc_from_content('l([])');
        my $statement = $doc->find('PPI::Statement')->[0];

        my $matched = $rule->match($statement);
        cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
            & methods(
                method_name => 'l',
                part1 => [],
                part2 => [],
                args => [ [] ],
            );
    };

    subtest '1 argument' => sub {
        my $doc = doc_from_content('l([1])');
        my $statement = $doc->find('PPI::Statement')->[0];

        my $matched = $rule->match($statement);
        cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
            & methods(
                method_name => 'l',
                part1 => [],
                part2 => [],
                args => [ [1] ],
            );
    };

    subtest '2 argument' => sub {
        my $doc = doc_from_content('l([1 , 2])');
        my $statement = $doc->find('PPI::Statement')->[0];

        my $matched = $rule->match($statement);
        cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
            & methods(
                method_name => 'l',
                part1 => [],
                part2 => [],
                args => [ [1, 2] ],
            );
    };

    subtest '2 argument' => sub {
        my $doc = doc_from_content('l([1 , 2, $three, $four->five($six)])');
        my $statement = $doc->find('PPI::Statement')->[0];

        my $matched = $rule->match($statement);
        cmp_deeply $matched, isa('ReplaceMethodCall::Matched')
            & methods(
                method_name => 'l',
                part1 => [],
                part2 => [],
                args => [
                    [
                        1,
                        2,
                        isa('ReplaceMethodCall::Quoted')  & methods(content => q{$three}),
                        isa('ReplaceMethodCall::Quoted')  & methods(content => q{$four->five($six)}),
                    ],
                ]
            );
    };
}

1;
