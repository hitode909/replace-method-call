add(a => 1, b => 2);

my ($x, $y) = (3, 4);
add(a => $x, b => $y);
add('b', $y, 'a', $x);
