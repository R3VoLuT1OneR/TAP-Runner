package TAP::Runner::Test;
# ABSTRACT: Runner test class
use Moose;
use TAP::Runner::Option;
use Moose::Util::TypeConstraints;

subtype 'ArrayRef::' . __PACKAGE__,
    as 'ArrayRef[' . __PACKAGE__ . ']';

coerce 'ArrayRef::' . __PACKAGE__,
    from 'ArrayRef[HashRef]',
    via { [ map { __PACKAGE__->new($_) } @{$_} ] };

has file          => (
    is            => 'ro',
    isa           => 'Str',
    required      => 1,
);

has alias         => (
    is            => 'ro',
    isa           => 'Str',
    lazy_build    => 1,
);

has args          => (
    is            => 'ro',
    isa           => 'ArrayRef',
    default       => sub{ [] },
);

has options       => (
    is            => 'ro',
    isa           => 'ArrayRef::TAP::Runner::Option',
    predicate     => 'has_options',
    coerce        => 1,
);

has harness_tests => (
    is            => 'ro',
    isa           => 'ArrayRef[HashRef]',
    lazy_build    => 1,
);

# Build alias if it not defined
sub _build_alias {
    my $self = shift;
    $self->file;
}

# Build harness tests list from all the options and args
sub _build_harness_tests {
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

    \@harness_tests;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
