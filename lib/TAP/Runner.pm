package TAP::Runner;
# ABSTRACT: Running tests with options
use Moose;

use TAP::Harness;
use TAP::Runner::Test;

use Math::Cartesian::Product;

has harness_args  => (
    is            => 'rw',
    isa           => 'HashRef',
    default       => sub{ {} },
);

has tests         => (
    is            => 'rw',
    isa           => 'ArrayRef[HashRef]',
    required      => 1,
);

has tap_tests     => (
    is            => 'rw',
    isa           => 'ArrayRef[TAP::Runner::Test]',
    lazy_build    => 1,
);

sub _build_tap_tests {
    my $self  = shift;
    my @tests = ();

    foreach my $test ( @{ $self->tests } ) {

        if ( defined $test->{options} && ref $test->{options} eq 'HASH' ) {

            # Build arrays of all options and add option name to each value
            my @all_options_array = ();
            while ( my ( $option_name, $values ) = each %{ $test->{options} } ) {
                push @all_options_array,  [ map{ [ $option_name, $_ ] } @$values ];
            }

            # Make cartesian multiplication with all options
            foreach ( cartesian { @_ } @all_options_array ) {
                # Build correct test args array
                # First element this is option name and second option value
                my @test_args  = ( map { ($_->[0],$_->[1]) } @$_ );
                my $test_alias = $test->{alias}  .' '. join(' ',@test_args);
                push @tests, TAP::Runner::Test->new({
                    file  => $test->{file},
                    alias => $test_alias,
                    args  => \@test_args,
                });
            }

        } else {

            push @tests, TAP::Runner::Test->new($test);

        }

    }

    \@tests;
}

sub run {
    my $self    = shift;
    my $harness = TAP::Harness->new( $self->get_harness_args );

    $harness->runtests( $self->get_harness_tests_list );
}

sub get_harness_args {
    my $self      = shift;

    $self->harness_args->{test_args} = {
        map { ( $_->alias, $_->args ) } @{$self->tap_tests}
    };

    $self->harness_args;
}

sub get_harness_tests_list {
    my $self  = shift;
    my @tests = ();

    foreach my $test ( @{ $self->tap_tests } ) {

        push @tests, [ $test->file, $test->alias ];

    }

    @tests;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
