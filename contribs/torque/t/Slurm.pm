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

1;

