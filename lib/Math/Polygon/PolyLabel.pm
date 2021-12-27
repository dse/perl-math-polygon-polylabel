package Math::Polygon::PolyLabel;
use warnings;
use strict;

use List::Util qw(min);
use POSIX qw(round);

use Math::Polygon::PolyLabel::Cell;
use Math::Polygon::PolyLabel::Queue;

use base 'Exporter';
our @EXPORT = qw();
our @EXPORT_OK = qw(polylabel);
our %EXPORT_TAGS = (
    all => [qw(polylabel)],
);

sub polylabel {
    my ($polygon, $precision) = @_;
    $precision //= 1.0;
    my ($minX, $minY, $maxX, $maxY);
    for (my $i = 0; $i < scalar @{$polygon->[0]}; $i += 1) {
        my $p = $polygon->[0]->[$i];
        if (!$i || $p->[0] < $minX) { $minX = $p->[0]; }
        if (!$i || $p->[1] < $minY) { $minY = $p->[1]; }
        if (!$i || $p->[0] > $maxX) { $maxX = $p->[0]; }
        if (!$i || $p->[1] > $maxY) { $maxY = $p->[1]; }
    }
    my $width = $maxX - $minX;
    my $height = $maxY - $minY;
    my $cellSize = min($width, $height);
    my $h = $cellSize / 2;
    if ($cellSize == 0) {
        return [$minX, $minY, 0];
    }
    my $cellQueue = Math::Polygon::PolyLabel::Queue->new(undef, \&compareMax);
    for (my $x = $minX; $x < $maxX; $x += $cellSize) {
        for (my $y = $minY; $y < $maxY; $y += $cellSize) {
            $cellQueue->push(Math::Polygon::PolyLabel::Cell->new(
                $x + $h, $y + $h, $h, $polygon
            ));
        }
    }
    my $bestCell = getCentroidCell($polygon);
    my $bboxCell = Math::Polygon::PolyLabel::Cell->new(
        $minX + $width / 2, $minY + $height / 2, 0, $polygon
    );
    if ($bboxCell->d > $bestCell->d) {
        $bestCell = $bboxCell;
    }
    my $numProbes = $cellQueue->length;
    while ($cellQueue->length) {
        my $cell = $cellQueue->pop();
        if ($cell->d > $bestCell->d) {
            $bestCell = $cell;
        }
        if ($cell->max - $bestCell->d <= $precision) {
            next;
        }
        $h = $cell->h / 2;
        $cellQueue->push(Math::Polygon::PolyLabel::Cell->new($cell->x - $h, $cell->y - $h, $h, $polygon));
        $cellQueue->push(Math::Polygon::PolyLabel::Cell->new($cell->x + $h, $cell->y - $h, $h, $polygon));
        $cellQueue->push(Math::Polygon::PolyLabel::Cell->new($cell->x - $h, $cell->y + $h, $h, $polygon));
        $cellQueue->push(Math::Polygon::PolyLabel::Cell->new($cell->x + $h, $cell->y + $h, $h, $polygon));
        $numProbes += 4;
    }
    return [$bestCell->x, $bestCell->y, $bestCell->d];
}

sub compareMax {
    my ($a, $b) = @_;
    return $b->max - $a->max;
}

sub getCentroidCell {
    my ($polygon) = @_;
    my $area = 0;
    my $x = 0;
    my $y = 0;
    my $points = $polygon->[0];
    my $len = scalar @$points;
    my $j = $len - 1;
    for (my $i = 0; $i < $len; $j = $i++) {
        my $a = $points->[$i];
        my $b = $points->[$j];
        my $f = $a->[0] * $b->[1] - $b->[0] * $a->[1];
        $x += ($a->[0] + $b->[0]) * $f;
        $y += ($a->[1] + $b->[1]) * $f;
        $area += $f * 3;
    }
    if ($area == 0) {
        return Math::Polygon::PolyLabel::Cell->new($points->[0]->[0], $points->[0]->[1], 0, $polygon);
    }
    return Math::Polygon::PolyLabel::Cell->new($x / $area, $y / $area, 0, $polygon);
}

1;
