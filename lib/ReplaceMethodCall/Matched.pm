package ReplaceMethodCall::Matched;
use Class::Accessor::Lite (
    new => 1,
    ro => [
        'part1',                # [ tokens ]
        'method_name',               # Str
        'structured_args',      # [ structured tokens ]
        'part2',                # [ tokens ]
    ],
);
use PPI;

sub as_string {
    my ($self) = @_;

    $self->part1_as_string . $self->method_name . '(' . $self->args_as_string . ')' . $self->part2_as_string;
}

sub part1_as_string {
    my ($self) = @_;
    join '', @{$self->part1};
}

sub args_as_string {
    my ($self) = @_;
    join '', @{$self->args};
}

sub part2_as_string {
    my ($self) = @_;
    join '', @{$self->part2};
}


sub as_statement {
    my ($self) = @_;

    my $doc = PPI::Document->new(\$self->as_string);
    $self->{_doc} = $doc;
    $doc->find('PPI::Statement')->[0];
}

1;
