package TAP::Runner::Option;
# ABSTRACT: Option object
use Moose;
use Moose::Util::TypeConstraints;

subtype 'ArrayRef::' . __PACKAGE__,
    as 'ArrayRef[' . __PACKAGE__ . ']';

coerce 'ArrayRef::' . __PACKAGE__,
    from 'ArrayRef[HashRef]',
    via { [ map { __PACKAGE__->new($_) } @{$_} ] };

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
    isa           => 'Bool',
    default       => 0,
);

# Build array used for cartesian multiplication
# Example: [ [ opt_name, opt_val1 ], [ opt_name1, opt_val2 ] ]
sub get_values_array {
    my $self = shift;

    [ map { [ $self->name, $_ ] } @{ $self->values } ];
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
