#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use Bio::SeqIO;

sub run_command {
  my $command = shift;
  print "$command \n";
  `$command `;
}

my $usage = "
Build rRNA category map file

Synopsis:

perl remove_duplicate_id.pl -i fastaFile -o outputFile

Options:

  -i|--input {fastaFile}       Fasta format sequence file
  -o|--output {fastaFile}      Output file
  -h|--help                    This page.
";

Getopt::Long::Configure('bundling');

my $inputFile;
my $outputFile;
my $help;

GetOptions(
  'h|help'     => \$help,
  'i|input=s'  => \$inputFile,
  'o|output=s' => \$outputFile,
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

if ( !defined $outputFile ) {
  die "Output file required";
}
else {
  die "Output file already exists: " . $outputFile if ( -e $outputFile );
}

my @categories = ( "Embryophyta", "Archaeplastida", "Fungi", "SAR", "Excavata", "Amoebozoa", "Choanozoa", "Metazoa (Animalia)", "Archaea", "Bacteria", "Eukaryota" );
my %categoryMap = (
  "SAR"                => "Protists",
  "Excavata"           => "Protists",
  "Amoebozoa"          => "Protists",
  "Choanozoa"          => "Protists",
  "Metazoa (Animalia)" => "Metazoa"
);

my $tmpFile = $outputFile . ".tmp";
open( my $mapfile, ">$tmpFile" ) or die "Cannot create $tmpFile";
print $mapfile "Name\tCategory\tDescription\n";

my $seqio = Bio::SeqIO->new( -file => $inputFile, -format => 'fasta' );
while ( my $seq = $seqio->next_seq ) {
  my $id       = $seq->id;
  my $desc       = $seq->desc;
  my $category = "Others";
  for my $cat (@categories) {
    if ( $desc =~ /${cat};/ ) {
      $category = $categoryMap{$cat} ? $categoryMap{$cat} : $cat;
      last;
    }
  }
  print $mapfile "$id\t$category\t$desc\n";
}
close($mapfile);

if(-s $outputFile){
  unlink($outputFile);
}
rename($tmpFile, $outputFile);

exit(1);
