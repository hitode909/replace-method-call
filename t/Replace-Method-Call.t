package t::ReplaceMethodCall;
use t::test;
use Path::Class;
use File::Temp;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'ReplaceMethodCall';
}

sub instantiate: Tests {
    isa_ok ReplaceMethodCall->new, 'ReplaceMethodCall';
    isa_ok ReplaceMethodCall->new, 'PPI::Transform';
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

sub quote : Tests {
    my $r = ReplaceMethodCall->new;

    is $r->quote(1), '1';
    is $r->quote('a'), "'a'";
    is $r->quote(ReplaceMethodCall::Quoted->new('$user->name')), '$user->name';
    is $r->quote([ReplaceMethodCall::Quoted->new('$user1->name'), ReplaceMethodCall::Quoted->new('$user2->name')]), '[$user1->name, $user2->name]';
    is $r->quote([[ReplaceMethodCall::Quoted->new('$user1->name'), [ReplaceMethodCall::Quoted->new('$user2->name')]]]), '[[$user1->name, [$user2->name]]]';
}

sub document : Tests {

    subtest 'rules are empty' => sub {
        my $r = ReplaceMethodCall->new;

        my $doc = doc_from_content('print 1');

        is $r->document($doc), 0;
    };

    subtest 'rules not match' => sub {
        my $r = ReplaceMethodCall->new;

        $r->register(
            method_name => 'foo',
            apply => sub { },
        );

        my $doc = doc_from_content('print 1');

        is $r->document($doc), 0;
    };

    subtest 'match but not changed' => sub {
        my $r = ReplaceMethodCall->new;

        $r->register(
            method_name => 'foo',
            apply => sub { undef },
        );

        my $doc = doc_from_content('foo()');

        is $r->document($doc), 0;
    };

    subtest 'match, changed' => sub {
        my $r = ReplaceMethodCall->new;

        $r->register(
            method_name => 'foo',
            apply => sub { 'bar()' },
        );

        my $doc = doc_from_content('foo()');

        is $r->document($doc), 1;
        is $doc, 'bar()', 'doc changed';
    };

    subtest 'match, changed, with indent' => sub {
        my $r = ReplaceMethodCall->new;

        $r->register(
            method_name => 'foo',
            apply => sub { "bar(\n)" },
        );

        my $doc = doc_from_content('  foo()');

        is $r->document($doc), 1;
        is $doc, "  bar(\n  )", 'doc changed';
    };

    subtest 'match, changed, using arguments' => sub {
        my $r = ReplaceMethodCall->new;

        $r->register(
            method_name => 'add',
            apply => sub {
                my ($args) = @_;
                my $arg1 = $args->[0];
                my $arg2 = $args->[1];
                "reverse_add(@{[ $r->quote($arg2) ]}, @{[ $r->quote($arg1) ]})";
            },
        );

        subtest 'number literal' => sub {
            my $doc = doc_from_content('add(1, 2)');

            is $r->document($doc), 1;
            is $doc, 'reverse_add(2, 1)';
        };

        subtest 'match multil' => sub {
            my $doc = doc_from_content("add(1, 2);\nadd(3, 4);");

            is $r->document($doc), 2;
            is $doc, "reverse_add(2, 1);\nreverse_add(4, 3);";
        };

        subtest 'string literal' => sub {
            my $doc = doc_from_content(q{add('a', 'b')});

            is $r->document($doc), 1;

            is $doc, q{reverse_add('b', 'a')};
        };

        subtest 'variable' => sub {
            my $doc = doc_from_content('add($x, $y)');

            is $r->document($doc), 1;
            is $doc, 'reverse_add($y, $x)';
        };

        subtest 'nested' => sub {
            local $TODO = 'not supported';
            my $doc = doc_from_content('add(add(1, 2), 3)');
            is $r->document($doc), 1;
            is $doc, 'reverse_add(3, reverse_add(2, 1))';
        };
    };
}

sub _file : Tests {
    my $r = ReplaceMethodCall->new;

    $r->register(
        method_name => 'foo',
        apply => sub { 'bar' },
    );

    my $fh = File::Temp->new;
    print $fh 'foo';
    my $file = $fh->filename;
    $fh->close;

    ok $r->file($file);

    is file($file)->slurp, 'bar';
}

1;
