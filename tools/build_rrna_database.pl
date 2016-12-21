#!/usr/bin/env perl

use strict;
use File::Basename;
use Utils::FileUtils;
use Utils::SequenceUtils;

sub run_command {
  my $command = shift;
  print "$command \n";
  `$command `;
}

my $targetDirectory = "/scratch/cqs/shengq1/references/smallrna/v3/SILVA";
chdir($targetDirectory) or die "cannot change: $!\n";

my $finalFile = "SILVA_128.rmdup.fasta";
if ( !-s $finalFile ) {
  if ( !-s "SILVA_128.fasta" ) {
    if ( !-s "SILVA_128_LSURef_tax_silva.fasta" ) {
      run_command('wget https://www.arb-silva.de/fileadmin/silva_databases/release_128/Exports/SILVA_128_LSURef_tax_silva.fasta.gz; gunzip SILVA_128_LSURef_tax_silva.fasta.gz;');
    }

    if ( !-s "SILVA_128_SSURef_Nr99_tax_silva.fasta" ) {
      run_command('wget https://www.arb-silva.de/fileadmin/silva_databases/release_128/Exports/SILVA_128_SSURef_Nr99_tax_silva.fasta.gz; gunzip SILVA_128_SSURef_Nr99_tax_silva.fasta.gz;');
    }

    run_command('cat SILVA_128_LSURef_tax_silva.fasta SILVA_128_SSURef_Nr99_tax_silva.fasta > SILVA_128.fasta');
  }

  my $script = dirname(__FILE__) . "/remove_rRNA_duplicate_id.pl";
  if ( !-e $script ) {
    die "File not found : " . $script;
  }

  run_command("perl $script -i SILVA_128.fasta -o $finalFile -p SILVA_");

  if ( -s $finalFile ) {
    unlink("SILVA_128_LSURef_tax_silva.fasta")      if ( -e "SILVA_128_LSURef_tax_silva.fasta" );
    unlink("SILVA_128_SSURef_Nr99_tax_silva.fasta") if ( -e "SILVA_128_SSURef_Nr99_tax_silva.fasta" );

    #unlink("SILVA_128.fasta")                       if ( -e "SILVA_128.fasta" );

    my $buildindex = dirname(__FILE__) . "/buildindex.pl";
    if ( !-e $buildindex ) {
      die "File not found : " . $buildindex;
    }
    run_command("perl $buildindex -f $finalFile -b");
  }
}

my $categoryFile = changeExtension( $finalFile, ".category.map" );
if ( !-s $categoryFile ) {
  my $buildcategory = dirname(__FILE__) . "/build_rrna_category.pl";
  if ( !-e $buildcategory ) {
    die "File not found : " . $buildcategory;
  }
  run_command("perl $buildcategory -i $finalFile -o $categoryFile");
}

extractFastaFile( $finalFile, "Homo_sapiens_",           "SILVA_128.rmdup.human.fasta", 0 );
extractFastaFile( $finalFile, "Mus_musculus_",     "SILVA_128.rmdup.mouse.fasta", 0 );
extractFastaFile( $finalFile, "Rattus_norvegicus_", "SILVA_128.rmdup.rat.fasta",   0 );

1;
