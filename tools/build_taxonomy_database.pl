#!/usr/local/bin/perl

use strict;
use File::Basename;
use LWP::Simple;
use LWP::UserAgent;
use Bio::SeqIO;
use POSIX qw(strftime);

my $nodesDB    = "nodes.parent.map";
my $namesDB    = "names.scientific.map";
my $categoryDB = "category.map";

sub read_map {
  my ( $filename, $reverse ) = shift;
  open( my $file, "<$filename" ) or die "Cannot open file $filename";
  my $result = {};
  while ( my $line = (<$file>) ) {

    # get rid of the line terminator
    chomp $line;

    # skip malformed lines.  for something important you'd print an error instead
    next unless $line =~ /^(\S*)\s*(\S*)$/;

    # insert into %map
    if ($reverse) {
      $result->{$2} = $1;
    }
    else {
      $result->{$1} = $2;
    }
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

my $categories = {
  "Archaea"     => "Archaea",
  "Bacteria"    => "Bacteria",
  "Eukarya"     => "Eukarya",
  "Embryophyta" => "Embryophyta",
  "Fungi"       => "Fungi",
  "Vertebrata"  => "Vertebrata"
};

my $child_parent_id_map = read_map( $nodesDB, 0 );
my $id_name_map         = read_map( $namesDB, 0 );
my $name_id_map         = read_map( $namesDB, 1 );

sub get_category_by_id {
  my $species_id   = shift;
  my $species_name = $id_name_map->{$species_id};
  print $species_name, "\n";
  my $category     = $categories->{$species_name};
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
        return get_category_by_id($parent_id);
      }
    }
    else {
      return "Others";
    }
  }
}

sub get_category_by_name {
  my $species_name = shift;
  my $species_id   = $name_id_map->{$species_name};
  if ($species_id) {
    return get_category_by_id($species_id);
  }
  else {
    die "Cannot find taxonomy id for " . $species_name;
  }
}

print get_category_by_name("Chrysotimus");

#open( my $output, ">$categoryDB" ) or die "Cannot write to $categoryDB";
#for my $id ( sort keys %$id_name_map ) {
#  my $species_name = $id_name_map->{$id};
#  my $category     = get_category_by_id($id);
#  print $output $species_name, "\t", $category, "\n";
#}
#close($output);

exit(1);
