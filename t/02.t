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

our $water2 = decode_json($json);

my $p1 = polylabel($water2);
$p1 = join(', ', @$p1);
printf("p1 = %s", dumper($p1));
# [3263.5, 3263.5], { distance: 960.5 }
