package TAP::Runner;
# ABSTRACT: Running tests with options
use Moose;
use Carp;
use TAP::Runner::Test;
use Math::Cartesian::Product;

has harness_class => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'TAP::Harness',
);

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
                my @test_opts  = ( map{ ($_->[0],$_->[1]) } @$_ );
                my @test_args  = ( @{$test->{args}}, @test_opts );
                my $test_alias = $test->{alias}  .' '. join(' ',@test_opts);

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
    my $self          = shift;
    my $harness_class = $self->harness_class;
    my $harness_args  = $self->get_harness_args;
    my @harness_tests = $self->get_harness_tests;

    # Load harness class
    eval "require $harness_class";
    croak "Can't load $harness_class" if $@;

    my $harness = $harness_class->new( $harness_args );

    # Custom formatter
    $harness->formatter( $self->harness_formatter )
        if $self->has_custom_formatter;

    $harness->runtests( @harness_tests );
}

sub get_harness_args {
    my $self      = shift;
    my %test_args = map { ( $_->alias, $_->args ) } @{$self->tap_tests};

    $self->harness_args->{test_args} = \%test_args;
    $self->harness_args;
}

sub get_harness_tests {
    my $self  = shift;

    map{ [ $_->file, $_->alias ] } @{ $self->tests };
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
