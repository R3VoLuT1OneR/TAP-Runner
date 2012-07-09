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
    required      => 1,
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

__END__

=head1 DESCRIPTION

Object used for L<TAP::Runner::Test> options

=head1 METHODS

=head2 get_values_array

Build array used for cartesian multiplication
Example: [ [ opt_name, opt_val1 ], [ opt_name1, opt_val2 ] ]

=head1 ATTRIBUTES

=head2 name

Option name

=head2 values

Array of option values

=head2 multiple

If option multiple ( default not ) so for each option value will be new test
with this value

Example:
For option { name => '--opt_exampl', values => [ 1, 2 ], multiple => 1 }
will run to tests, with diferrent optoins:
t/test.t --opt_exampl 1
t/test.t --opt_exampl 2
