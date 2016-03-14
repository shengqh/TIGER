#!/usr/local/bin/perl

use strict;
use File::Basename;
use Bio::SeqIO;

my $file  = '/scratch/cqs/zhaos/vickers/reference/rRna/SILVA_123_LSURef_tax_silva.fasta';
my $log   = "/scratch/cqs/shengq1/references/smallrna/SILVA_123_LSURef_tax_silva.category.map";

my @categories = ( "Embryophyta", "Archaeplastida", "Fungi", "SAR", "Excavata", "Amoebozoa", "Choanozoa", "Metazoa (Animalia)", "Archaea", "Bacteria", "Eukaryota" );
my %categoryMap = (
  "SAR"                => "Protists",
  "Excavata"           => "Protists",
  "Amoebozoa"          => "Protists",
  "Choanozoa"          => "Protists",
  "Metazoa (Animalia)" => "Metazoa"
);

open( my $mapfile, ">$log" ) or die "Cannot create $log";
print $mapfile "Name\tCategory\n";

my $seqio = Bio::SeqIO->new( -file => $file, -format => 'fasta' );
while ( my $seq = $seqio->next_seq ) {
  my $id = $seq->id;
  for my $cat (@categories) {
    if ( $id =~ /${cat};/ ) {
      my $category = $categoryMap{$cat} ? $categoryMap{$cat} : $cat;
      print $mapfile "${id}\t${category}\n";
    }
  }
}
close($mapfile);

exit(1);
