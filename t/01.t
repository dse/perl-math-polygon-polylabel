# -*- perl -*-
use strict;
use warnings;

use FindBin;
use lib "${FindBin::Bin}/../lib";

use File::Basename qw(dirname);
use JSON;

use Math::Polygon::PolyLabel qw(polylabel);
use Data::Dumper;

sub dumper {
    local $Data::Dumper::Terse = 1;
    local $Data::Dumper::Useqq = 1;
    local $Data::Dumper::Indent = 1;
    return Data::Dumper::Dumper(@_);
}

my $json = do {
    my $fh;
    open($fh, '<', dirname($0) . '/water1.json') or die;
    local $/ = undef;
    <$fh>;
};

our $water1 = decode_json($json);

my $p1 = polylabel($water1, 1);
$p1 = join(', ', @$p1);
printf("p1 = %s", dumper($p1));
# [3865.85009765625, 2124.87841796875], { distance: 288.8493574779127 }

my $p2 = polylabel($water1, 50);
$p2 = join(', ', @$p2);
printf("p2 = %s", dumper($p2));
# [3854.296875, 2123.828125], { distance: 278.5795872381558 }
