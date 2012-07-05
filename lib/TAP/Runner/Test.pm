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

has options       => (
    is            => 'rw',
    isa           => 'ArrayRef[TAP::Runner::Option]',
    predicate     => 'has_options',
);

# Build alias if it not defined
sub _build_alias {
    my $self = shift;
    $self->file;
}

sub _get_multiple_options {
    my $self = shift;

    grep { $_->multiple } @{ $self->options };
}

sub get_harrness_tests {
    my $self             = shift;
    my @test_args        = @{ $self->args };
    my @multiple_options = ();
    my @harness_tests    = ();

    foreach my $option ( @{ $self->options } ) {

        if ( $option->multiple ) {
            push @multiple_options, $option;
            next;
        }

        push @test_args, map { ( $option->name, $_ ) } @{ $option->values };

    }

    if ( @multiple_options ) {

        my @merged_options = ();

        # Make array of arrays that contains merged options values with it names
        foreach my $option ( @multiple_options ) {
            @merged_options = map { [ $option->name, $_ ] } @{ $option->values };
        }

        # Make cartesian multiplication with all options
        cartesian {
            # Unmerge options make separated option name and value
            my @opt_args = map { ($_->[0],$_->[1]) } @_;

            push @harness_tests, {
                file  => $self->file,
                alias => $self->alias,
                args  => ( @test_args, @opt_args ),
            }
        } @merged_options;

    } else {
        push @harness_tests, {
            file  => $self->file,
            alias => $self->alias,
            args  => @test_args,
        }
    }

    ( @harness_tests );
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
