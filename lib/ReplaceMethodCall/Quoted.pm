package ReplaceMethodCall::Quoted;
use strict;
use warnings;

sub new {
    my ($class, $content) = @_;
    bless {
        content => $content,
    }, $class;
}

sub content {
    my ($self) = @_;
    $self->{content};
}

1;
