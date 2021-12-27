package Math::Polygon::PolyLabel::Queue;
use warnings;
use strict;

sub new {
    my ($class, $data, $compare) = @_;
    $data //= [];
    $compare //= sub {
        my ($a, $b) = @_;
        return $a < $b ? -1 : $a > $b ? 1 : 0;
    };
    my $self = bless({}, $class);
    $self->{data} = [];
    $self->{compare} = $compare;
    $self->{length} = scalar @{$self->{data}};
    return $self;
}

sub push {
    my ($self, $item) = @_;
    push(@{$self->{data}}, $item);
    $self->_up($self->{length}++);
}

sub pop {
    my ($self) = @_;
    if ($self->{length} == 0) {
        return;
    }
    my $top = $self->{data}->[0];
    my $bottom = pop(@{$self->{data}});
    if (--$self->{length} > 0) {
        $self->{data}->[0] = $bottom;
        $self->_down(0);
    }
    return $top;
}

sub _up {
    my ($self, $pos) = @_;
    my $data = $self->{data};
    my $compare = $self->{compare};
    my $item = $data->[$pos];
    while ($pos > 0) {
        my $parent = ($pos - 1) >> 1;
        my $current = $data->[$parent];
        if ($compare->($item, $current) >= 0) {
            last;
        }
        $data->[$pos] = $current;
        $pos = $parent;
    }
    $data->[$pos] = $item;
}

sub _down {
    my ($self, $pos) = @_;
    my $data = $self->{data};
    my $compare = $self->{compare};
    my $halfLength = $self->{length} >> 1;
    my $item = $data->[$pos];
    while ($pos < $halfLength) {
        my $bestChild = ($pos << 1) + 1;
        my $right = $bestChild + 1;
        if ($right < $self->{length} && $compare->($data->[$right],
                                                   $data->[$bestChild]) < 0) {
            $bestChild = $right;
        }
        if ($compare->($data->[$bestChild], $item) >= 0) {
            last;
        }
        $data->[$pos] = $data->[$bestChild];
        $pos = $bestChild;
    }
    $data->[$pos] = $item;
}

sub length {
    my ($self) = @_;
    return $self->{length};
}

1;
