#!/usr/bin/perl
use strict;
use warnings;

use TAP::Runner;
use TAP::Formatter::HTML;

TAP::Runner->new(
    {
        # harness_class => 'TAP::Harness::JUnit',
        # harness_formatter => TAP::Formatter::HTML->new,
        harness_args => {
            rules => {
                par => [
                    # { seq => qr/^Test alias$/ },
                    { seq => qr/^Test alias 2.*$/  },
                    { seq => '*' },
                ],
            },
            jobs  => 4,
        },
        tests => [
            {
                file    => 't/examples/test.t',
                alias   => 'Test alias',
                args    => [
                    '-s', 't/etc/test_server'
                ],
                options => [
                    {
                        name   => '-w',
                        values => [
                            'first opt',
                            'second opt',
                        ],
                        multiple => 1,
                    },
                    {
                        name   => '-r',
                        values => [
                            'test2',
                            'test44',
                        ],
                        multiple => 1,
                    },
                ],
            },
            {
                file    => 't/examples/test2.t',
                alias   => 'Test alias 2',
                args    => [
                    '-s', 't/etc/test_server'
                ],
            },
            {
                file    => 't/examples/test2.t',
                alias   => 'Test alias 22',
                args    => [
                    '-s', 't/etc/test_server'
                ],
            },
        ],
    }
)->run;
