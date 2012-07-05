package TAP::Runner::Option;
# ABSTRACT: Option object
use Moose;

has name          => (
    is            => 'ro',
    isa           => 'Str',
    required      => 1,
);

has values        => (
    is            => 'ro',
    isa           => 'ArrayRef',
    lazy_build    => 1,
);

has multiple      => (
    is            => 'ro',
    isa           => 'ArrayRef',
    default       => 0,
);

no Moose;
__PACKAGE__->meta->make_immutable;
1;
