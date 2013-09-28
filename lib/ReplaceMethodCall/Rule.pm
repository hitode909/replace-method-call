package ReplaceMethodCall::Rule;
use strict;
use warnings;
use Class::Accessor::Lite (
    new => 1,
    ro => [
        'method_name',
        'apply',
    ],
);
use feature 'switch';

use ReplaceMethodCall::Matched;
use ReplaceMethodCall::Quoted;

# returns: Matched or undef
sub match {
    my ($self, $statement) = @_;

    # ignore Statement::Sub, ...
    return undef unless ref $statement eq 'PPI::Statement';

    # statement = <part1>method_name(<args>)<part2>

    my ($part1, $part2, $args, $method_found, $paren_level, $paren_found) = ([], [], [], 0, 0, 0);

    for my $token (@{$statement->find('PPI::Token')}) {
        if ($paren_found) {
            # part2
            push @$part2, $token;
        } elsif ($method_found) {
            # args
            if ($token eq '(') {
                if ($paren_level > 0) {
                    push @$args, $token;
                }
                $paren_level++;
                next;
            } elsif ($token eq ')') {
                $paren_level--;
                if ($paren_level == 0) {
                    $paren_found = 1;
                } else {
                    push @$args, $token;
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

    unless ($method_found) {
        return undef;
    }

    my $part1_content = [ map { $_->content} @$part1];
    my $part2_content = [ map { $_->content} @$part2];
    my $args_content = [ map { $_->content } @$args ];
    my $parsed_args = $self->parse_args($args_content);
    return unless $parsed_args;
    ReplaceMethodCall::Matched->new(
        part1           => $part1_content,
        method_name     => $self->method_name,
        args => $parsed_args,
        part2           => $part2_content,
    );
}

sub parse_args {
    my ($self, $tokens) = @_;

    return [] unless @$tokens;

    my $last_code;

    for (0..5) {
        my $code =  '[' . join('', @$tokens) . ']';

        if ($last_code && $code eq $last_code) {
            die "failed to parse $code";
        }
        $last_code = $code;

        # warn "code is $code";
        my $res = eval $code;
        unless ($@) {
            return $res;
        }

        my ($name) = $@ =~ /Global symbol "([^"]+)"/;
        unless (defined $name) {
            die "cannot handlle $@";
        }

        my $separators = [',', '=>', ']', '}' ];
        my $found = 0;
        my $paren_level = 0;
        my $new_tokens = [];
        my $buffer = '';

        for my $token (@$tokens) {
            # use Data::Dumper; warn Dumper +{
            #     token => $token.q(),
            #     buffer => $buffer,
            #     new_tokens => $new_tokens,
            #     found => $found,
            #     paren_level => $paren_level,
            #     sep => $token ~~ $separators,
            # };
            if ($found) {
                if ($token ~~ $separators && $paren_level == 0) {
                    # warn 'zero';
                    push @$new_tokens, ReplaceMethodCall::Quoted->new($buffer)->to_source;
                    $buffer = '';
                    $found = 0;
                    push @$new_tokens, $token;
                    next;
                }

                if ($token eq '(') {
                    $paren_level++;
                }
                if ($token eq ')') {
                    $paren_level--;
                }
                $buffer .= $token;
            } else {
                if ($token eq $name) {
                    $buffer .= $token;
                    $found++;
                } else {
                    push @$new_tokens, $token;
                }
            }
        }
        if (length $buffer) {
            push @$new_tokens, ReplaceMethodCall::Quoted->new($buffer)->to_source;
        }
        $tokens = $new_tokens;
    }
}

1;
