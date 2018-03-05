use strict;
use warnings;

use Test::More;
use Test::MockModule;

my $submitfilter;
BEGIN {
    # poor mans main mocking
    sub find_submitfilter {$submitfilter};

    unshift(@INC, '.', 't');
}

require 'qsub.pl';

my $sbatch = which("sbatch");
my $salloc = which("salloc");


# TODO: mixed order (ie permute or no order); error on unknown options

# key = generated command text (w/o sbatch)
# value = arrayref

# default args
my @da = qw(script arg1 -l nodes=2:ppn=4);
# default batch argumnet string
my $dba = "-e script.e%A -o script.o%A -N2 -n8";
# default script args
my $dsa = "script arg1";

my %comms = (
    "$dba $dsa", [@da],
    # should be equal
    "$dba -t1 --mem=1024M $dsa Y", [qw(-l mem=1g,walltime=1), @da, 'Y'],
    "$dba -t1 --mem=1024M $dsa X", [qw(-l mem=1g -l walltime=1), @da, 'X'],
    "$dba --mem=2048M $dsa", [qw(-l vmem=2gb), @da],
    "$dba --mem-per-cpu=10M $dsa", [qw(-l pvmem=10mb), @da],
    "$dba --mem-per-cpu=20M $dsa", [qw(-l pmem=20mb), @da],
    );

=head1 test all commands in %comms hash

=cut

foreach my $cmdtxt (sort keys %comms) {
    my $arr = $comms{$cmdtxt};
    diag "args ", join(" ", @$arr);
    diag "cmdtxt '$cmdtxt'";

    @ARGV = (@$arr);
    my ($interactive, $command, $block, $script, $script_args) = make_command();
    diag "interactive ", $interactive ? 1 : 0;
    diag "command '$command'";
    diag "block '$block'";

    is(join(" ", @$command), "$sbatch $cmdtxt", "expected command for '$cmdtxt'");
    is($script, 'script', "expected script $script for '$cmdtxt'");
    my @expargs = qw(arg1);
    push(@expargs, $1) if $cmdtxt =~ m/(X|Y)$/;
    is_deeply($script_args, \@expargs, "expected scriptargs ".join(" ", @$script_args)." for '$cmdtxt'");
}

=head1 test submitfilter

=cut

# set submitfilter
$submitfilter = "/my/submitfilter";

@ARGV = (@da);
my ($interactive, $command, $block, $script, $script_args) = make_command($submitfilter);
diag "submitfilter command $command";
is(join(" ", @$command), "$sbatch $dba", "expected command for submitfilter");


done_testing();
