#!/usr/bin/env perl

use strict;
use warnings;
use File::Basename;
use LWP::Simple;
use LWP::UserAgent;
use Bio::SeqIO;
use POSIX qw(strftime);
use Getopt::Long;

sub run_command {
  my $command = shift;
  print "$command \n";
  `$command `;
}

my $usage = "
Build taxonomy database file

Synopsis:

perl build_taxonomy_database.pl -o outputFilePrefix

Options:

  -o|--outputFilePrefix {STRING}   Output file prefix
  -h|--help                        This page.
";

Getopt::Long::Configure('bundling');

my $outputDirectory;
my $help;

GetOptions(
  'h|help'             => \$help,
  'o|tagetDirectory=s' => \$outputDirectory,
);

if ( defined $help ) {
  print $usage;
  exit(1);
}

if ( !defined $outputDirectory ) {
  die "Output directory required";
}
else {
  chdir($outputDirectory) or die "Cannot change to directory " . $outputDirectory;
}

my $nodesDB         = "nodes.parent.map";
my $namesDB         = "names.scientific.map";
my $trna_categoryDB = "trna_category.map";

sub read_map {
  my ($filename) = shift;
  open( my $file, "<$filename" ) or die "Cannot open file $filename";
  my $result = {};
  while ( my $line = (<$file>) ) {

    # get rid of the line terminator
    chomp $line;

    # skip malformed lines.  for something important you'd print an error instead
    next unless $line =~ /^(\S*)\s*(.+)$/;

    # insert into %map
    $result->{$1} = $2;
  }
  close($file);
  return $result;
}

if ( !-e $nodesDB ) {
  `wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdmp.zip`;
  `unzip taxdmp.zip; rm taxdmp.zip;`;
  `cut -f1,3 nodes.dmp > $nodesDB`;
  `grep "scientific name" names.dmp | cut -f1,3 > $namesDB`;
}

my $id_name_map = read_map($namesDB);
my %name_id_map = reverse %$id_name_map;

my $child_parent_id_map = read_map($nodesDB);

sub get_category_by_id {
  my ( $species_id, $categories ) = @_;
  my $species_name = $id_name_map->{$species_id};

  #print $species_name, "\n";
  my $category = $categories->{$species_name};
  if ($category) {
    return $category;
  }
  else {
    my $parent_id = $child_parent_id_map->{$species_id};
    if ($parent_id) {
      if ( $parent_id == $species_id ) {
        return "Others";
      }
      else {
        return get_category_by_id( $parent_id, $categories );
      }
    }
    else {
      return "Others";
    }
  }
}

sub get_category_by_name {
  my ( $species_name, $categories ) = @_;
  my $species_id = $name_id_map{$species_name};
  if ($species_id) {
    return get_category_by_id( $species_id, $categories );
  }
  else {
    die "Cannot find taxonomy id for " . $species_name;
  }
}

#print get_category_by_name("Chrysotimus");

my $trna_categories = {
  "Archaea"     => "Archaea",
  "Bacteria"    => "Bacteria",
  "Eukaryota"   => "Eukaryota",
  "Embryophyta" => "Embryophyta",
  "Fungi"       => "Fungi",
  "Vertebrata"  => "Vertebrata",
  "Viruses"     => "Viruses"
};

open( my $trna_output, ">$trna_categoryDB" ) or die "Cannot write to $trna_categoryDB";
for my $id ( sort keys %$id_name_map ) {
  my $species_name = $id_name_map->{$id};
  my $category = get_category_by_id( $id, $trna_categories );
  print $trna_output $species_name, "\t", $category, "\n";
}
close($trna_output);

`rm *.dmp; rm gc.prt; rm readme.txt;`;

exit(1);


