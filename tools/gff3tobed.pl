#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long;
use Bio::Tools::GFF;

my $usage = "
gff3 to bed converter

Synopsis:

perl gff3tobed.pl -i gff3file -o bedfile -k gffKey

Options:

  -i|--input {gff3file}   Gff3 format file
  -o|--output {bedfile}   Output bed format file
  -k|--key {gffKey}       Primary key of gtf entry (default miRNA), none for not filtering
  -h|--help               This page.
";

Getopt::Long::Configure('bundling');

my $input_file;
my $output_file;
my $gff_key;
my $help;

GetOptions(
  'h|help'     => \$help,
  'i|input=s'  => \$input_file,
  'o|output=s' => \$output_file,
  'k|key=s'    => \$gff_key,
);

if ( defined $help ) {
  print $usage;
  exit(1);
}

if ( !defined $gff_key ) {
  $gff_key = "miRNA";
}

#$input_file  = "H:/shengquanhu/projects/database/miRBase21/hsa.gff3";
#$output_file = "H:/shengquanhu/projects/database/miRBase21/hsa.bed";

die "Input file not exists: " . $input_file       if ( !-e $input_file );
die "Output file already exists: " . $output_file if ( -e $output_file );

my $gffio = Bio::Tools::GFF->new( -file => $input_file, -gff_version => 3 );

my $feature;
open( my $output, ">$output_file" ) or die( "Cannot create file: " . $output_file );
while ( $feature = $gffio->next_feature() ) {
  if ( ( $gff_key eq "none" ) || ( $feature->primary_tag eq $gff_key ) ) {
    print $output $feature->seq_id, "\t", ( $feature->start - 1 ), "\t", $feature->end, "\t", $feature->get_tag_values("Name"), "\t", "1000", "\t", ( $feature->strand eq '-1' ) ? "-" : "+", "\n";
  }
}
$gffio->close();

close($output);
