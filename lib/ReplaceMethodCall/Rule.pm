package ReplaceMethodCall::Rule;
use Class::Accessor::Lite (
    new => 1,
    ro => [
        'method_name',
        'arguments',
        'apply',
    ],
);
use feature 'switch';

use ReplaceMethodCall::Matched;

# returns: Matched or undef
sub match {
    my ($self, $statement) = @_;

    # statement = <part1>method_name(<args>)<part2>

    my ($part1, $part2, $args, $method_found, $paren_stack, $paren_found) = ([], [], [], 0, 0, 0);

    for my $token (@{$statement->find('PPI::Token')}) {
        if ($paren_found) {
            # part2
            push @$part2, $token;
        } elsif ($method_found) {
            # args
            if ($token eq '(') {
                $paren_stack++;
                next;
            } elsif ($token eq ')') {
                $paren_stack--;
                if ($paren_stack == 0) {
                    $paren_found = 1;
                }
            } else {
                push @$args, $token;
            }
        } else {
            # part1
            if ($token eq $self->method_name) {
                $method_found = 1;
            } else {
                push @$part1, $token;
            }
        }
    }
    my $parsed_args = $self->parse_args($args);
    return unless $parsed_args;
    ReplaceMethodCall::Matched->new(
        part1           => $part1,
        method          => $self->method_name,
        structured_args => $parsed_args,
        part2           => $part2,
    );
}

# [ tokens ] to [ tokens <-> arguments ]
# [ '1' ',' '2' ] to [1, 2]
sub parse_args {
    my ($self, $tokens) = @_;

    my $res = [];

    for my $argument (@{$self->arguments}) {
        my $parser_method = "parse_$argument";
        my $captured = $self->$parser_method($tokens);
        # warn '---captured---';
        # use Data::Dumper; warn Dumper $captured;
        return undef unless $res;
        push @$res, $captured;
    }
    $res;
}

# [tokens] -> [value] or undef
sub parse_scalar {
    my ($self, $tokens) = @_;

    # warn '---capturing scalar ---';
    # use Data::Dumper; warn Dumper $tokens;

    my $res = [];

    my $paren_stack = 0;

    while (@$tokens) {
        my $token = $tokens->[0];
        # warn "watching $token";
        given ($token->content) {
            when ([',', '=>']) {
                # TODO: see parens
                shift @$tokens;
                return $res;
            }
            default {
                given (ref $token) {
                    when ('PPI::Token::Whitespace') {
                    }
                    default {
                        push @$res, $token;
                    }
                }
            }
        }
        shift @$tokens;
    }
    return $res;
}

sub parse_hash {
    my ($self, $tokens) = @_;

    my $key;

    while (@$tokens) {
        my $token = $tokens->[0];
    }
}

1;
