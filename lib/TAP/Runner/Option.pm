package TAP::Runner::Option;
# ABSTRACT: Option object
use Moose;
use Moose::Util::TypeConstraints;

=head1 DESCRIPTION

Object used for L<TAP::Runner::Test> options

=head1 MOOSE SUBTYPES

=head2 ArrayRef::TAP::Runner::Option

Coerce ArrayRef[HashRef] to ArrayRef[TAP::Runner::Test] Used b L<TAP::Runner::Test>

=cut
subtype 'ArrayRef::' . __PACKAGE__,
    as 'ArrayRef[' . __PACKAGE__ . ']';

coerce 'ArrayRef::' . __PACKAGE__,
    from 'ArrayRef[HashRef]',
    via { [ map { __PACKAGE__->new($_) } @{$_} ] };

=head1 ATTRIBUTES

=head2 name Str

Option name

=cut
has name          => (
    is            => 'ro',
    isa           => 'Str',
    required      => 1,
);

=head2 values ArrayRef[Str]

Array of option values

=cut
has values        => (
    is            => 'ro',
    isa           => 'ArrayRef[Str]',
    required      => 1,
);

=head2 multiple Bool

If option multiple ( default not ) so for each option value will be new test
with this value

    Example:
    For option { name => '--opt_exampl', values => [ 1, 2 ], multiple => 1 }
    will run to tests, with diferrent optoins:
    t/test.t --opt_exampl 1
    t/test.t --opt_exampl 2

=cut
has multiple      => (
    is            => 'ro',
    isa           => 'Bool',
    default       => 0,
);

=head2 parallel Bool

If option should run in parallel. Run in parallel can be just multiple option.

=cut
has parallel      => (
    is            => 'ro',
    isa           => 'Bool',
    default       => 0,
);

=head1 METHODS

=head2 get_values_array

Build array used for cartesian multiplication

    Example: [ [ opt_name, opt_val1 ], [ opt_name1, opt_val2 ] ]

=cut
sub get_values_array {
    my $self = shift;

    [ map { [ $self->name, $_ ] } @{ $self->values } ];
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__
