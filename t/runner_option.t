use strict;
use warnings;
use Test::More;
use Test::Fatal;
use Test::Deep;

plan tests => 6;

    use_ok( 'TAP::Runner::Option' );

    like(
        exception { TAP::Runner::Option->new },
        qr/^Attribute \(name\) is required/,
        'Check that name required',
    );

    like(
        exception {
            TAP::Runner::Option->new(
                name => 'test_option_name',
            )
        },
        qr/^Attribute \(values\) is required/,
        'Check that values required',
    );

my $option = TAP::Runner::Option->new(
    name   => 'test_option',
    values => [ 1, 2 ,3 ],
);

    isa_ok(
        $option,
        'TAP::Runner::Option',
    );

    can_ok(
        $option,
        'get_values_array',
    );

    cmp_deeply(
        $option->get_values_array,
        [
            [ 'test_option' => '1' ],
            [ 'test_option' => '2' ],
            [ 'test_option' => '3' ],
        ],
        'get_values_array functionality test',
    );

done_testing;
