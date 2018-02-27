package Slurm;

use strict;
use warnings;

# Minimal Slurm package.

use constant JOB_COMPLETE => 'JOB_COMPLETE';

use parent qw(Exporter);
our @EXPORT_OK = qw(JOB_COMPLETE);
our %EXPORT_TAGS = (
    all => \@EXPORT_OK,
    );


package Slurm::Hostlist;

use strict;
use warnings;


sub create {};

sub push {};

sub ranged_string {};

sub count {0};



1;

