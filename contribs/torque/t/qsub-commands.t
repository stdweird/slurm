use strict;
use warnings;

use Test::More;
use Test::MockModule;

BEGIN {
    unshift(@INC, '.', 't');
}

require 'qsub.pl';

use FindBin;
my $sbatch = "${FindBin::Bin}/sbatch";
my $salloc = "${FindBin::Bin}/salloc";


# key = generated command text (w/o sbatch)
# value = arrayref

# default args
my @da = qw(script arg1 -l something);
# default batch argumnet string
my $dba = "-e script.e%A -o script.o%A";
# default script args
my $dsa = "script arg1 -l something";

my %comms = (
    "$dba $dsa", [@da],
    # should be equal
    "$dba -t1 --mem=1024M $dsa Y", [qw(-l mem=1g,walltime=1), @da, 'Y'],
    "$dba -t1 --mem=1024M $dsa X", [qw(-l mem=1g -l walltime=1), @da, 'X'],
    );

=head1 test all commands in %comms hash

=cut

foreach my $cmdtxt (sort keys %comms) {
    my $arr = $comms{$cmdtxt};
    diag "args ", join(" ", @$arr);
    diag "cmdtxt '$cmdtxt'";

    @ARGV = (@$arr);
    my ($interactive, $command, $block) = make_command();
    diag "interactive ", $interactive ? 1 : 0;
    diag "command '$command'";
    diag "block '$block'";

    is($command, "$sbatch $cmdtxt", "expected command for '$cmdtxt'");
}

done_testing();
