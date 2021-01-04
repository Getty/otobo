# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2020 Rother OSS GmbH, https://otobo.de/
# --
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# --

package Kernel::System::UnitTest::Selenium::WebElement;

=head1 NAME

Kernel::System::UnitTest::Selenium::WebElement - Utility functions for Selenium WebElements

=head1 SUBROUTINES

=cut

use strict;
use warnings;
use v5.24;
use namespace::autoclean;
use utf8;

use parent qw(Test::Selenium::Remote::WebElement);

# core modules

# CPAN modules

# OTOBO modules
use Test2::API qw/context run_subtest/;

=head2 VerifiedSubmit()

Submit a form element, and wait for the page to be fully loaded (works only in OTOBO)

    $SeleniumObject->VerifiedSubmit();

=cut

sub VerifiedSubmit {
    my $Self  = shift;
    my ($Params) = @_;

    my $Context = context();

    my $Code = sub {
        $Self->submit();

        $Self->driver()->WaitFor(
            JavaScript =>
                'return typeof(Core) == "object" && typeof(Core.App) == "object" && Core.App.PageLoadComplete'
        ) || die "OTOBO API verification failed after element submit.";
    };

    run_subtest( 'VerifiedSubmit', $Code, { buffered => 1, inherit_trace => 1 } );

    $Context->release;

    return;
}

=head2 VerifiedClick()

click an element that causes a page get/reload/submit and wait for the page to be fully loaded
(works only in OTOBO).

    $SeleniumObject->VerifiedClick(
        $Button             # optional, see Selenium docs
    );

=cut

sub VerifiedClick {    ## no critic
    my $Self = shift;

    my $Context = context();

    my $Code = sub {
        $Self->driver()->execute_script('window.Core.App.PageLoadComplete = false;');

        $Self->SUPER::click(@_);

        $Self->driver()->WaitFor(
            JavaScript =>
                'return typeof(Core) == "object" && typeof(Core.App) == "object" && Core.App.PageLoadComplete'
        ) || die "OTOBO API verification failed after element click.";
    };

    run_subtest( 'VerifiedClick', $Code, { buffered => 1, inherit_trace => 1 } );

    $Context->release;

    return;
}

1;
