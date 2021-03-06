package ReplaceMethodCall;
use strict;
use warnings;
use parent qw(PPI::Transform);
use List::MoreUtils qw(any);
use List::Util qw(first);
use Data::Dumper;

use ReplaceMethodCall::Rule;

sub new {
    my ($class, %args) = @_;

    $class->SUPER::new(
        rules => [],
        matched_objects => [],
    );
}

sub rules {
    my ($self) = @_;
    $self->{rules};
}

# args:
#   method_name: string methor_name
#   apply:    coderef
sub register {
    my ($self, %args) = @_;

    push @{$self->{rules}}, ReplaceMethodCall::Rule->new(%args);
}

sub document {
    my ($self, $document) = @_;

    my $changed = 0;

    my $statements = $document->find('PPI::Statement');

    for my $statement (@$statements) {
        $changed++ if $self->handle($document, $statement);
    }

    $changed;
}

sub handle {
    my ($self, $document, $statement) = @_;

    my $tokens = [ $statement->children ];

    my $rule = first {
        my $rule = $_;
        first {
            my $token = $_;
            $rule->method_name eq $token;
        } @$tokens
    } @{$self->{rules}};

    return unless $rule;

    my $matched = $rule->match($statement);
    return unless $matched;

    # use Data::Dumper; warn Dumper $matched;

    my $indent_level = do {
        my $indent = $statement->previous_token;
        if ($indent && $indent->isa('PPI::Token::Whitespace')) {
            $indent =~ s/\n//g;
            length $indent;
        } else {
            0;
        }
    };

    my $new_statement = $matched->convert($rule, $indent_level);

    # use Data::Dumper; warn Dumper $new_statement;

    return unless $new_statement;

    push @{$self->{_matched_objects}}, $matched;

    $statement->insert_before($new_statement);
    $statement->remove;

    1;
}

# quote value for argument
sub quote {
    my ($self, $value) = @_;
    if (ref $value ~~ 'ARRAY') {
        '[' . join(', ',  map { $self->quote($_) } @$value) . ']';
    } elsif (ref $value && $value->isa('ReplaceMethodCall::Quoted')) {
        $value->content;
    } else {
        Data::Dumper->new([$value])->Terse(1)->Sortkeys(1)->Indent(0)->Dump;
    }
}

1;
