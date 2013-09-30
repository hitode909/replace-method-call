package ReplaceMethodCall::Matched;
use Class::Accessor::Lite (
    new => 1,
    ro => [
        'part1',       # [ tokens ]
        'method_name', # Str
        'args',        # [ args ]
        'part2',       # [ tokens ]
    ],
);
use PPI;

# rule: Rule
# indent_level: ' ' x n
# returns:
#   PPI::Statement (when converted) or undef (when not)
sub convert {
    my ($self, $rule, $indent_level) = @_;

    die "apply not defined" unless defined $rule->apply;

    my $new_body = $rule->apply->($self->args);

    return undef unless defined $new_body;

    my $new_content = $self->part1_as_string . $new_body . $self->part2_as_string;

    my $indent_string = ' ' x $indent_level;
    $new_content =~ s/\n/\n$indent_string/gm;

    my $doc = PPI::Document->new(\$new_content);
    $self->{_doc} = $doc;
    $doc->find('PPI::Statement')->[0];
}

sub part1_as_string {
    my ($self) = @_;
    join '', @{$self->part1};
}

sub part2_as_string {
    my ($self) = @_;
    join '', @{$self->part2};
}

1;
