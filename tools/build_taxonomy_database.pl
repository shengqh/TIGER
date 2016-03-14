#!/usr/local/bin/perl

use strict;
use File::Basename;
use LWP::Simple;
use LWP::UserAgent;
use Bio::SeqIO;
use POSIX qw(strftime);

my $nodesDB     = "nodes.parent.map";
my $namesDB     = "names.scientific.map";

if ( !-e $nodesDB ) {
  `wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdmp.zip`
}

exit(1);
