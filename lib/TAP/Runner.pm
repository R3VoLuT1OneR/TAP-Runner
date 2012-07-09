package TAP::Runner;
# ABSTRACT: Running tests with options
use Moose;
use Carp;
use TAP::Runner::Test;

has harness_class => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'TAP::Harness',);

has harness_formatter => (
    is            => 'rw',
    predicate     => 'has_custom_formatter',
);

has harness_args  => (
    is            => 'rw',
    isa           => 'HashRef',
    default       => sub{ {} },
);

has tests         => (
    is            => 'rw',
    isa           => 'ArrayRef::TAP::Runner::Test',
    coerce        => 1,
    required      => 1,
);

sub run {
    my $self          = shift;
    my $harness_class = $self->harness_class;
    my $harness_args  = $self->_get_harness_args;
    my @harness_tests = $self->_get_harness_tests;

    # Load harness class
    eval "require $harness_class";
    croak "Can't load $harness_class" if $@;

    my $harness = $harness_class->new( $harness_args );

    # Custom formatter
    $harness->formatter( $self->harness_formatter )
        if $self->has_custom_formatter;

    $harness->runtests( @harness_tests );
}

# Harness args with building test arguments
sub _get_harness_args {
    my $self      = shift;

    # Build tests args hash ref
    $self->harness_args->{test_args} = {
        map { ( $_->{alias}, $_->{args} ) }
        map { @{ $_->harness_tests }      } @{ $self->tests } };

    $self->harness_args;
}

# Return array of tests to run with it aliases
sub _get_harness_tests {
    my $self  = shift;

    map { [ $_->{file}, $_->{alias} ] }
    map { @{ $_->harness_tests }      } @{ $self->tests };
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

This module allows to run tests more flexible. Allows to use TAP::Harness, not just for unit tests.

=head1 METHODS

=head2 new

=head2 run

=head1 ATTRIBUTES

=head2 harness_class

=head2 harness_formatter

=head2 tests

=head2 tests_args
