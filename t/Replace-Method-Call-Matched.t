package t::ReplaceMethodCall::Matched;
use t::test;

use ReplaceMethodCall::Rule;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'ReplaceMethodCall::Matched';
}

sub instantiate: Tests {
    isa_ok +ReplaceMethodCall::Matched->new, 'ReplaceMethodCall::Matched';
}

sub part1_as_string : Tests {
    subtest 'when empty' => sub {
        my $m = ReplaceMethodCall::Matched->new(
            part1           => [],
        );
        is $m->part1_as_string, '';
    };

    subtest 'when has content' => sub {
        my $m = ReplaceMethodCall::Matched->new(
            part1           => ['print', ' '],
        );
        is $m->part1_as_string, 'print ';
    };
}

sub part2_as_string : Tests {
    subtest 'when empty' => sub {
        my $m = ReplaceMethodCall::Matched->new(
            part2           => [],
        );
        is $m->part2_as_string, '';
    };

    subtest 'when has content' => sub {
        my $m = ReplaceMethodCall::Matched->new(
            part2           => ['->', 'reverse'],
        );
        is $m->part2_as_string, '->reverse';
    };
}

sub convert : Tests {
    subtest 'when apply is missing' => sub {
        my $r = ReplaceMethodCall::Rule->new;
        my $m = ReplaceMethodCall::Matched->new;
        like exception { $m->convert($r) }, qr(apply not defined);
    };

    subtest 'when return undef' => sub {
        my $r = ReplaceMethodCall::Rule->new(
            apply => sub { undef; },
        );
        my $m = ReplaceMethodCall::Matched->new;
        is $m->convert($r), undef;
    };

    subtest 'when return string' => sub {
        my $r = ReplaceMethodCall::Rule->new(
            apply => sub { 'converted()' },
        );
        my $m = ReplaceMethodCall::Matched->new;
        isa_ok $m->convert($r), 'PPI::Statement';
        is $m->convert($r), 'converted()';
    };

    subtest 'part 1, 2' => sub {
        my $r = ReplaceMethodCall::Rule->new(
            apply => sub { 'converted()' },
        );
        my $m = ReplaceMethodCall::Matched->new(
            part1 => [ 'print', ' ' ],
            part2 => [ '->', 'done', ';' ],
        );
        isa_ok $m->convert($r), 'PPI::Statement';
        is $m->convert($r), 'print converted()->done;';
    };
}

1;
