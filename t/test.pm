package t::test;

use strict;
use warnings;
use utf8;

use PPI;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;

use Exporter::Lite ();
our @EXPORT = qw(
                    test_file
                    doc_from_file
                    doc_from_content
);


sub import {
    my ($class) = @_;

    my ($package, $file) = caller;

    my $code = qq[
        package $package;
        use strict;
        use warnings;
        use utf8;

        use parent qw(Test::Class);
        use Test::More;
        use Test::Deep;
        use Test::Fatal;

        END { $package->runtests }
    ];

    eval $code;
    die $@ if $@;
    goto &Exporter::Lite::import;
}

sub test_file {
    my ($file_name) = @_;

    file(__FILE__)->dir->subdir('data')->file($file_name);
}

sub doc_from_file {
    my ($file_name) = @_;
    PPI::Document->new(test_file($file_name).q());
}

sub doc_from_content {
    my ($content) = @_;
    PPI::Document->new(\$content);
}

1;
