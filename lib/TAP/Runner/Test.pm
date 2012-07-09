package TAP::Runner::Test;
# ABSTRACT: Runner test class
use Moose;
use Moose::Util::TypeConstraints;

use TAP::Runner::Option;

# Use cartesian multiplication
use Math::Cartesian::Product;

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
    default       => sub{ [] },
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
    my @multiple_options = ();
    my @harness_tests    = ();

    # Array of args that same for all the tests
    my @test_args        = @{ $self->args };

    foreach my $option ( @{ $self->options } ) {

        if ( $option->multiple ) {
            push @multiple_options, $option;
            next;
        }

        # Add options that same for all the tests
        push @test_args, map { ( $option->name, $_ ) } @{ $option->values };

    }

    # If there are multiple options, that should passed to tests, build correct
    # tests args and harness tests
    if ( @multiple_options ) {

        # Make array of arrays that contains merged options values with it names
        # Example:
        # (
        #   [ [ opt_name1, opt_val1.1 ], [ opt_name1, opt_val1.2 ] ],
        #   [ [ opt_name2, opt_val2.1 ], [ opt_name2, opt_val2.2 ] ],
        # )
        #
        my @merged_options = map { $_->get_values_array } @multiple_options;

        # Make cartesian multiplication with all options
        # Result of example multiplication:
        # [ opt_name1, opt_val1.1 ],[ opt_name2, opt_val2.1 ]
        # [ opt_name1, opt_val1.1 ],[ opt_name2, opt_val2.2 ]
        # [ opt_name1, opt_val1.2 ],[ opt_name2, opt_val2.1 ]
        # [ opt_name1, opt_val1.2 ],[ opt_name2, opt_val2.2 ]
        #
        cartesian {
            # Unmerge options make separated option name and value
            # Example: ( opt_name1, opt_val1, opt_name2, opt_val2 )
            my @opt_args = map { ($_->[0],$_->[1]) } @_;

            # Build new alias defends on options that passed to test
            my $alias    = $self->alias .' '. join(' ',@opt_args);

            push @harness_tests, {
                file  => $self->file,
                alias => $alias,
                args  => [ @test_args, @opt_args ],
            }
        } @merged_options;

    } else {
        push @harness_tests, {
            file  => $self->file,
            alias => $self->alias,
            args  => \@test_args,
        }
    }

    \@harness_tests;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 DESCRIPTION

Test object used by L<TAP::Runner>

=head1 METHODS

=head1 ATTRIBUTES

=head2 file

Test file to run ( required )

=head2 alias

Alias for tests ( by default used file name )

=head2 args

Arguments that will pass to all the tests

=head2 options

Array of L<TAP::Runner::Option> used by test.

=head2 harness_tests

Array of hashes prepared for testing with L<TAP::Harness>
