# -*- perl -*-
use strict;
use warnings;

use FindBin;
use lib "${FindBin::Bin}/../lib";

use Math::Polygon::PolyLabel qw(polylabel);
use Data::Dumper;

sub dumper {
    local $Data::Dumper::Terse = 1;
    local $Data::Dumper::Useqq = 1;
    local $Data::Dumper::Indent = 1;
    return Data::Dumper::Dumper(@_);
}

my $p1 = polylabel([[[0, 0], [1, 0], [2, 0], [0, 0]]]);
print(dumper($p1));

my $p2 = polylabel([[[0, 0], [1, 0], [1, 1], [1, 0], [0, 0]]]);
print(dumper($p2));
