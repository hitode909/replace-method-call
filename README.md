# replace-method-call

- static analyze, find method call, parse arguments, replace

## Install

```
carton install
```

## Examples

This example renames `add` to `reverse_add`, swap arguments.

```perl
my $r = ReplaceMethodCall->new;

$r->register(
    method_name => 'add',
    apply => sub {
        my ($args) = @_;
        my $arg1 = $args->[0];
        my $arg2 = $args->[1];
        "reverse_add(@{[ $r->quote($arg2) ]}, @{[ $r->quote($arg1) ]})";
    },
);

$r->file(@ARGV);

# carton exec -- perl samples/01_reverse_add.pl samples/01_in.pl samples/01_out.pl
```

#### Before

```perl
add(1 , 2);

my ($x, $y) = (3, 4);
add($x, $y);
```

#### After

```perl
reverse_add(2, 1);

my ($x, $y) = (3, 4);
reverse_add($y, $x);

```

## License

MIT