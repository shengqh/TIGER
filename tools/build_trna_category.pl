#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use Bio::SeqIO;
use Utils::CollectionUtils;

sub run_command {
  my $command = shift;
  print "$command \n";
  `$command `;
}

my $usage = "
Build tRNA category map file

Synopsis:

perl build_trna_category.pl -i GtRNAdb2.20161214.map -c trna_category.map -o GtRNAdb2.20161214.category.map

Options:

  -i|--input {FILE}          tRNA sequence species map file
  -c|--category {FILE}       tRNA taxonomy category map file
  -o|--output {FILE}         Output file
  -h|--help                  This page.
";

Getopt::Long::Configure('bundling');

my $inputFile;
my $categoryFile;
my $outputFile;
my $help;

GetOptions(
  'h|help'       => \$help,
  'i|input=s'    => \$inputFile,
  'c|category=s' => \$categoryFile,
  'o|output=s'   => \$outputFile,
);

if ( defined $help ) {
  print $usage;
  exit(1);
}

if ( !defined $inputFile ) {
  die "Input file required";
}
else {
  die "Input file not exists: " . $inputFile if ( !-e $inputFile );
}

if ( !defined $categoryFile ) {
  die "Category file required";
}
else {
  die "Category file not exists: " . $categoryFile if ( !-e $categoryFile );
}

if ( !defined $outputFile ) {
  die "Output file required";
}
else {
  die "Output file already exists: " . $outputFile if ( -e $outputFile );
}

sub GetTrnaKey {
  my $trna = shift;
  my @parts = split( '_', $trna );
  if ( scalar(@parts) > 1 ) {
    return lc( $parts[0] . " " . $parts[1] );
  }
  else {
    return lc($trna);
  }
}

sub GetTaxonomyKey {
  my $key = shift;
  my @parts = split( ' ', $key );
  if ( scalar(@parts) > 1 ) {
    return lc( $parts[0] . " " . $parts[1] );
  }
  else {
    return lc($key);
  }
}

my $mydic = { "Ashbya gossypii" => "Eremothecium gossypii" };

my $taMap = readDictionaryByIndex( $categoryFile, 0, 1, 0 );
my $taxoMap = {};
for my $key ( keys %$taMap ) {
  $taxoMap->{ lc($key) } = $taMap->{$key};
  $taxoMap->{ GetTaxonomyKey($key) } = $taMap->{$key};
}

my $trMap = readDictionaryByColumnName( $inputFile, "Id", "Species" );
my $speciesMap = {};
for my $key ( keys %$trMap ) {
  my $species = lc( ( exists $mydic->{$key} ) ? $mydic->{$key} : $key );
  my @parts    = split( ' ', $species );
  my $name1    = $parts[0];
  my $category = $taxoMap->{$name1};
  if ( !defined $category ) {
    $category = $taxoMap->{$species};
  }
  if ( !defined $category ) {
    $species =~ s/\s+//g;
    $category = $taxoMap->{$species};
  }
  if ( !defined $category ) {
    print STDERR "Cannot find category of " . $key . "\n";
    next;
  }

  $speciesMap->{$key} = $category;
}

open( my $output, ">$outputFile" ) or die "Cannot write to file " . $outputFile;
print $output "Id\tSpecies\n";
for my $spec ( sort keys %$speciesMap ) {
  print $output $spec . "\t" . $speciesMap->{$spec} . "\n";
}
close($output);

1;
