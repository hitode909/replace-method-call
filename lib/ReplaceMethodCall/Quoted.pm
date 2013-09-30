package ReplaceMethodCall::Quoted;
use strict;
use warnings;
use Data::Dumper;

sub new {
    my ($class, $content) = @_;
    if ($content && $content =~ /\s/) {
        $content =~ s/^\s*//g;
        $content =~ s/\s*$//g;
    }
    bless {
        content => $content,
    }, $class;
}

sub content {
    my ($self) = @_;
    $self->{content};
}

sub to_source {
    my ($self) = @_;

    my $quoted = Data::Dumper->new([$self->content])->Terse(1)->Sortkeys(1)->Indent(0)->Dump;

    my $class = ref $self;
    "$class->new($quoted)";
}

1;
