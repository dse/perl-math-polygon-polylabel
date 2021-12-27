package Math::Polygon::PolyLabel::Cell;
use warnings;
use strict;

use List::Util qw(min);

sub new {
    my ($class, $x, $y, $h, $polygon) = @_;
    my $self = bless({}, $class);
    $self->{x} = $x;
    $self->{y} = $y;
    $self->{h} = $h;
    $self->{d} = pointToPolygonDist($x, $y, $polygon);
    $self->{max} = $self->{d} + $self->{h} * sqrt(2);
    return $self;
}

sub x   { return shift->{x}; }
sub y   { return shift->{y}; }
sub h   { return shift->{h}; }
sub d   { return shift->{d}; }
sub max { return shift->{max}; }

sub pointToPolygonDist {
    my ($x, $y, $polygon) = @_;
    my $inside = 0;
    my $minDistSq = 0 + 'inf';
    for (my $k = 0; $k < scalar @$polygon; $k++) {
        my $ring = $polygon->[$k];
        my $len = scalar @$ring;
        my $j = $len - 1;
        for (my $i = 0; $i < $len; $j = $i++) {
            my $a = $ring->[$i];
            my $b = $ring->[$j];
            if ((($a->[1] > $y) ? 1 : 0) != (($b->[1] > $y) ? 1 : 0)
                &&
                ($x < ($b->[0] - $a->[0]) * ($y - $a->[1]) / ($b->[1] - $a->[1]) + $a->[0])) {
                $inside = !$inside;
            }
            $minDistSq = min($minDistSq, getSegDistSq($x, $y, $a, $b));
        }
    }
    return $minDistSq == 0 ? 0 : ($inside ? 1 : -1) * sqrt($minDistSq);
}

sub getSegDistSq {
    my ($px, $py, $a, $b) = @_;
    my $x = $a->[0];
    my $y = $a->[1];
    my $dx = $b->[0] - $x;
    my $dy = $b->[1] - $y;
    if ($dx != 0 || $dy != 0) {
        my $t = (($px - $x) * $dx + ($py - $y) * $dy) / ($dx * $dx + $dy * $dy);
        if ($t > 1) {
            $x = $b->[0];
            $y = $b->[1];
        } elsif ($t > 0) {
            $x += $dx * $t;
            $y += $dy * $t;
        }
    }
    $dx = $px - $x;
    $dy = $py - $y;
    return $dx * $dx + $dy * $dy;
}

1;
