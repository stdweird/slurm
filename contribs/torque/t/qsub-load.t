use strict;
use warnings;

use Test::More;
use Test::MockModule;

BEGIN {unshift(@INC, '.', 't');}
require 'qsub.pl';

ok(1, "Basic loading ok");

=head1 convert_mb_format

=cut

is(convert_mb_format('2g'), '2048M', 'Convert GB to MB');


=head1 get_miutes

=cut

# any started second is a full minute
is(get_minutes('1:2:0'), 62, 'Convert to minutes');
is(get_minutes('1:2:1'), 63, 'Convert to minutes (ceil up)');

is(get_minutes(1000), 17, 'Convert seconds to minutes');

=head1 parse_resource_list

key/value with undef value are stripped from result

=cut

my %resc = (
    "" => {},
    "walltime=1,nodes=2,mem=2g" => {mem => '2048M', nodes => 2, walltime => 1},
    );

# TODO: fix bugs: 144 hours, single digit minutes/seconds?, ppn=123

foreach my $resctxt (sort keys %resc) {
    my $resc = parse_resource_list($resctxt);
    # strip undefs
    $resc = {map {$_ => $resc->{$_}} grep {defined $resc->{$_}} sort keys %$resc};
    diag "resource '$resctxt' ", explain $resc;
    is_deeply($resc, $resc{$resctxt}, "converted rescource list '$resctxt'");
}

done_testing;
