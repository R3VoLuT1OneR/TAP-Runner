package TAP::Runner;
# ABSTRACT: Running tests with options
use Moose;
use Carp;
use TAP::Runner::Test;

=head1 SYNOPSIS

    #!/usr/bin/perl
    use strict;
    use warnings;

    use TAP::Runner;
    use TAP::Formatter::HTML;

    TAP::Runner->new(
        {
            # harness_class => 'TAP::Harness::JUnit',
            harness_formatter => TAP::Formatter::HTML->new,
            tests => [
                {
                    file    => 't/examples/test.t',
                    alias   => 'Test alias',
                    args    => [
                        '--option', 'option_value_1'
                    ],
                    options => [
                        {
                            name   => '--website',
                            values => [
                                'first.local',
                                'second.local',
                            ],
                            multiple => 0,
                        },
                        {
                            name   => '--browser',
                            values => [
                                'firefox',
                                'chrome',
                            ],
                            multiple => 1,
                            parallel => 1,
                        },
                    ],
                },
                {
                    file    => 't/examples/test.t',
                    alias   => 'Test alias 2',
                    args    => [
                        '--option', 'option_value_1'
                    ],
                },
            ],
        }
    )->run;

=head1 DESCRIPTION

This module allows to run tests more flexible. Allows to use TAP::Harness, not just for unit tests.

=head1 ATTRIBUTES

=cut

=head2 harness_class

Harness class to run the tests ( default L<TAP::Harness> )

=cut

has harness_class => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'TAP::Harness',
);

=head2 harness_formatter

Custom formatter for Harness.

=cut

has harness_formatter => (
    is            => 'rw',
    predicate     => 'has_custom_formatter',
);

=head2 harness_args HashRef

Default args that will pass to Harness object

=cut

has harness_args  => (
    is            => 'rw',
    isa           => 'HashRef',
    default       => sub{ {} },
);

=head2 tests ArrayRef[TAP::Runner::Test]

Tests configs that should run. See L<TAP::Runner::Test>

=cut

has tests         => (
    is            => 'rw',
    isa           => 'ArrayRef::TAP::Runner::Test',
    coerce        => 1,
);

=head1 METHODS

=cut

=head2 new

Create a new L<TAP::Runner> object. tests atribute required

    # Tests to run with runner
    my @tests  = ( { file => 't/test.t' } );

    # Tests auto coerce to L<TAP::Runner::Test>
    my $runner = TAP::Runner->new(
        tests => \@tests,
    );

=cut

=head2 run

Run the tests

=cut

sub run {
    my $self          = shift;
    my $harness_class = $self->harness_class;
    my $harness_args  = $self->_get_harness_args;
    my @harness_tests = $self->_get_harness_tests;

    # Load harness class
    eval "use $harness_class";
    croak "Can't load $harness_class" if $@;

    my $harness = $harness_class->new( $harness_args );

    # Custom formatter
    $harness->formatter( $self->harness_formatter )
        if $self->has_custom_formatter;

    $harness->runtests( @harness_tests );
}

# Harness args with building test arguments
sub _get_harness_args {
    my $self  = shift;

    # Build parallel runing test rules
    my @rules = (
        map { $_->get_parallel_rules } @{ $self->tests },
        exists $self->harness_args->{rules}->{par} ?
            @{ $self->harness_args->{rules}->{par} } : ()
    );

    # Set correct jobs counter if jobs not set
    $self->harness_args->{jobs} = int @rules
        if ( @rules and not exists $self->harness_args->{jobs} );

    # Build tests args hash ref
    my %test_args =
        map { ( $_->{alias}, $_->{args} ) }
        map { @{ $_->harness_tests }      } @{ $self->tests };

    $self->harness_args->{rules} = { par => \@rules } if @rules;
    $self->harness_args->{test_args} = \%test_args;
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
