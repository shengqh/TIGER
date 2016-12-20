#!/usr/local/bin/perl

use strict;
use Getopt::Long;
use SmallRNA::GtRNAdb2;

my $usage = "

Synopsis:

build_mature_fasta -i preMatureFasta -b bedFile -o matureFasta

Options:

  -i|--preMatureFasta {FILE}   GtRNAdb2 pre-mature fasta file
  -b|--bedFile {FILE}          GtRNAdb2 bed file
  -o|--matureFasta {FILE}      Output mature fasta file
  -h|--help                    This page.
";

Getopt::Long::Configure('bundling');

my $preMatureFasta;
my $bedFile;
my $matureFasta;
my $help;

GetOptions(
  'h|help' => \$help,
  'i=s'    => \$preMatureFasta,
  'b=s'    => \$bedFile,
  'o=s'    => \$matureFasta,
);

if ( defined $help ) {
  print $usage;
  exit(1);
}

die "Input valid pre-mature fasta file!" unless (-s $preMatureFasta);
die "Input valid bed file!" unless (-s $bedFile);
die "Input output mature fasta file!" unless (defined $preMatureFasta);

buildMatureFasta( $bedFile, $preMatureFasta, $matureFasta );

exit(1);
