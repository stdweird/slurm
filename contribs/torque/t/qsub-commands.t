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
# default batch argument string
my $dba = "-N2 -n8 --ntasks-per-node=4";
# defaults
my $defs = {
    e => '%x.e%A',
    o => '%x.o%A',
    J => 'script',
    export => 'NONE',
    'get-user-env' => '60L',
};
# default script args
my $dsa = "script arg1";

my %comms = (
    "$dba $dsa", [@da],
    # should be equal
    "$dba -t1 --mem=1024M $dsa Y", [qw(-l mem=1g,walltime=1), @da, 'Y'],
    "$dba -t1 --mem=1024M $dsa X", [qw(-l mem=1g -l walltime=1), @da, 'X'],
    "$dba -t1 --mem=1024M $dsa X", [@da, 'X', qw(-l vmem=1g -l walltime=1)],

    "$dba --mem=2048M $dsa", [qw(-l vmem=2gb), @da],
    "$dba --mem-per-cpu=10M $dsa", [qw(-l pvmem=10mb), @da],
    "$dba --mem-per-cpu=20M $dsa", [qw(-l pmem=20mb), @da],
    "$dba --abc=123 --def=456 $dsa", [qw(--pass=abc=123 --pass=def=456), @da],
    );

=head1 test all commands in %comms hash

=cut

foreach my $cmdtxt (sort keys %comms) {
    my $arr = $comms{$cmdtxt};
    diag "args ", join(" ", @$arr);
    diag "cmdtxt '$cmdtxt'";

    @ARGV = (@$arr);
    my ($mode, $command, $block, $script, $script_args, $defaults) = make_command();
    diag "mode ", $mode || 0;
    diag "interactive ", ($mode & 1 << 2) ? 1 : 0;
    diag "dryrun ", ($mode & 1 << 3) ? 1 : 0;
    diag "command '".join(" ", @$command)."'";
    diag "block '$block'";

    is(join(" ", @$command), "$sbatch $cmdtxt", "expected command for '$cmdtxt'");
    is($script, 'script', "expected script $script for '$cmdtxt'");
    my @expargs = qw(arg1);
    push(@expargs, $1) if $cmdtxt =~ m/(X|Y)$/;
    is_deeply($script_args, \@expargs, "expected scriptargs ".join(" ", @$script_args)." for '$cmdtxt'");
    is_deeply($defaults, $defs, "expected defaults for '$cmdtxt'");
}

=head1 test submitfilter

=cut

# set submitfilter
$submitfilter = "/my/submitfilter";

@ARGV = (@da);
my ($interactive, $command, $block, $script, $script_args, $defaults) = make_command($submitfilter);
diag "submitfilter command @$command";
my $txt = "$sbatch $dba";
is(join(" ", @$command), $txt, "expected command for submitfilter");

# no match
$txt .= " -J script -e %x.e%A --export=NONE --get-user-env=60L -o %x.o%A";
my ($newtxt, $newcommand) = parse_script("", $command, $defaults);
is(join(" ", @$newcommand), $txt, "expected command after parse_script without eo");

# replace PBS_JOBID
# no -o/e/J
my $stdin = "#\n#PBS -l abd -o stdout.\${PBS_JOBID}..\$PBS_JOBID\n#\n#PBS -e abc -N def\ncmd\n";
($newtxt, $newcommand) = parse_script($stdin, $command, $defaults);
is(join(" ", @$newcommand),
   "$sbatch -N2 -n8 --ntasks-per-node=4 --export=NONE --get-user-env=60L",
   "expected command after parse_script with eo");
is($newtxt, "#\n#PBS -l abd -o stdout.%A..%A\n#\n#PBS -e abc -N def\ncmd\n",
   "PBS_JOBID replaced");

done_testing();
