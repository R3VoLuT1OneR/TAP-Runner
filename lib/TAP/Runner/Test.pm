package TAP::Runner::Test;
# ABSTRACT: Runner test class
use Moose;

has file          => (
    is            => 'rw',
    isa           => 'Str',
    required      => 1,
);

has alias         => (
    is            => 'rw',
    isa           => 'Str',
    lazy_build    => 1,
);

has args          => (
    is            => 'rw',
    isa           => 'ArrayRef',
    default       => sub{ [] },
);

# Build alias if it not defined
sub _build_alias {
    my $self = shift;
    $self->file;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
