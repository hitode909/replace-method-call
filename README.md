# replace-method-call

- static analyze, find method call, parse arguments, replace


↓ doesn't work yet

```perl
my $replacer = ReplaceMethodCall->new;

$replacer->register(
    method_name => 'add',
    arguments => [qw(scalar scalar)],
    apply => sub {
        my ($arg1, $arg2) = @_;
        "reverse_add($arg2, $arg1)"
    },
);
```