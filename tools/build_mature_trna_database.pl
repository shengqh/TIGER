#!/usr/bin/env perl

use strict;
use File::Basename;
use LWP::Simple;
use LWP::UserAgent;
use Bio::SeqIO;
use POSIX qw(strftime);
use URI::Escape;
use File::Spec;
use Getopt::Long;
use SmallRNA::GtRNAdb2;
use Utils::FileUtils;
use Utils::SequenceUtils;

my $usage = "

Synopsis:

build_mature_trna_database -d directory

Options:

  -d|--dir {directory}         Target directory
  -h|--help                    This page.
";

sub run_command {
  my $command = shift;
  print "$command \n";
  `$command `;
}

sub processFile {
  my ( $bedFile, $fastaFile, $species, $category, $matureFileHandle, $preFileHandle, $mapFileHandle, $idMap, $dupFile ) = @_;

  my $matureFile = changeExtension( $fastaFile, ".mature.fa" );
  if ( !-s $matureFile ) {
    buildMatureFasta( $bedFile, $fastaFile, $matureFile );
  }

  my $seqio = Bio::SeqIO->new( -file => $fastaFile, -format => 'fasta' );
  my $ignored = {};
  while ( my $seq = $seqio->next_seq ) {
    my $id       = $seq->id;
    my $sequence = $seq->seq;
    if ( exists $idMap->{$id} ) {
      print $dupFile "$id\t$species\t$idMap->{$id}\n";
      $ignored->{$id} = 1;
      #print STDERR "$id in $species found in $idMap->{$id} \n";
      next;
    }

    $idMap->{$id} = $species;
    my $desc = $seq->desc;

    print $mapFileHandle "${id}\t${species}\t${category}\n";
    print $preFileHandle ">$id $desc\n$sequence\n";
  }

  $seqio = Bio::SeqIO->new( -file => $matureFile, -format => 'fasta' );
  while ( my $seq = $seqio->next_seq ) {
    my $id       = $seq->id;
    my $sequence = $seq->seq;
    if ( exists $ignored->{$id} ) {
      next;
    }

    my $desc = $seq->desc;
    print $matureFileHandle ">$id $desc\n$sequence\n";
  }
}

Getopt::Long::Configure('bundling');

my $targetDirectory;
my $help;

GetOptions(
  'h|help' => \$help,
  'd=s'    => \$targetDirectory,
);

my $pass = 1;

if ( defined $help ) {
  print $usage;
  exit(1);
}

my $ignoreSpecies = {
  "Mmusc"      => 1,
  "Hsapi38"    => 1,
  "Scere3.bak" => 1,
  "Btaur7"     => 1,
};

my $individualSpecies = {
  "Mmusc10" => 1,
  "Hsapi19" => 1,
  "Hsapi38" => 1,
  "Rnorv5"  => 1,
};

my $targetDirectoryTemp;
if ( !defined($targetDirectory) ) {
  $targetDirectory     = "/scratch/cqs/shengq1/references/smallrna/v3/GtRNAdb2";
  $targetDirectoryTemp = "/scratch/cqs/shengq1/references/ucsc/GtRNAdb2/temp";
}
else {
  $targetDirectoryTemp = $targetDirectory . "/temp/";
}

if ( !-e $targetDirectory ) {
  mkdir($targetDirectory) or die "cannot mkdir directory: $targetDirectory $!\n";
}

if ( !-e $targetDirectoryTemp ) {
  mkdir($targetDirectoryTemp) or die "cannot mkdir directory: $targetDirectoryTemp $!\n";
}

my $targetDirectoryIndividuals = $targetDirectory . "/individuals/";
if ( !-e $targetDirectoryIndividuals ) {
  mkdir($targetDirectoryIndividuals) or die "cannot mkdir directory $targetDirectoryIndividuals: $!\n";
}

chdir($targetDirectoryTemp) or die "cannot change: $!\n";

#my $datestring = strftime "%Y%m%d", localtime;
my $datestring = "20161214";

my $structureFile = $targetDirectory . "/GtRNAdb2." . $datestring . ".structure.tsv";
my $structures    = getStructure($structureFile);

my $prefix = $targetDirectory . "/GtRNAdb2." . $datestring;

my $trnafa          = $prefix . ".mature.fa";
my $trnaPrematureFa = $prefix . ".premature.fa";
my $trnafamap       = $prefix . ".map";
my $trnafaspecies   = $prefix . ".speciesmap";
my $trnaSpeciesDup  = $prefix . ".speciesRedundant";
my $trnaNameDup     = $prefix . ".nameDuplicated";

my $trnafaTmp = $trnafa . ".tmp";

my $idmap = {};

my $speciesMap = {};
open( my $trnaSpeciesDupFile, ">$trnaSpeciesDup" ) or die "Cannot create $trnaSpeciesDup";
print $trnaSpeciesDupFile "RedundantSpecies\tLastVersion\n";
foreach my $species_array (@$structures) {
  my $species = @$species_array[0];
  $speciesMap->{$species} = 1;
}
foreach my $species_array (@$structures) {
  my $species = @$species_array[0];
  for ( my $index = 10 ; $index >= 1 ; $index-- ) {
    my $newSpecies = $species . "_" . $index;
    if ( exists $speciesMap->{$newSpecies} ) {
      for ( my $dupIndex = $index - 1 ; $dupIndex >= 1 ; $dupIndex-- ) {
        my $dupSpecies = $species . "_" . $dupIndex;
        $speciesMap->{$dupSpecies} = 0;
        print $trnaSpeciesDupFile "$dupSpecies\t$newSpecies\n";
      }
      $speciesMap->{$species} = 0;
      print $trnaSpeciesDupFile "$species\t$newSpecies\n";
      last;
    }
  }
}
close($trnaSpeciesDupFile);

if ( !-s $trnafa ) {
  if ( -s $trnafaTmp ) {
    unlink($trnafaTmp);
  }

  my $ua = new LWP::UserAgent;
  $ua->agent( "AgentName/0.1 " . $ua->agent );

  open( my $maturefile, ">$trnafaTmp" )       or die "Cannot create $trnafaTmp";
  open( my $prefile,    ">$trnaPrematureFa" ) or die "Cannot create $trnaPrematureFa";
  open( my $mapfile,    ">$trnafamap" )       or die "Cannot create $trnafamap";
  open( my $smapfile,   ">$trnafaspecies" )   or die "Cannot create $trnafaspecies";
  open( my $dupfile,    ">$trnaNameDup" )     or die "Cannot create $trnaNameDup";

  print $mapfile "Id\tName\tSpecies\n";
  print $smapfile "Species\tCategory\n";

  foreach my $species_array (@$structures) {
    my $species = @$species_array[0];

    if ( !$speciesMap->{$species} ) {
      print STDERR "$species has been ignored due to redundant! \n";
      next;
    }

    my $category = @$species_array[1];
    my $file     = @$species_array[2];
    my $tarUrl   = @$species_array[3];
    my $faUrl    = @$species_array[4];

    my $tarfile   = $file . ".tar.gz";
    my $bedfile   = $file . ".bed";
    my $fastafile = $file . ".fa";
    if ( $individualSpecies->{$species} || !$ignoreSpecies->{$species} ) {
      print $category . " : " . $species . "\n";

      if ( !-e $bedfile ) {
        print $tarUrl, "\n";
        `wget $tarUrl; tar -xzvf $tarfile; rm $tarfile; rm ${file}.out; rm ${file}.ss.sort`;
      }

      if ( !-e $bedfile ) {
        print STDERR "WARNING: cannot download or extract " . $tarfile . "\n";
        next;
      }

      if ( !-e $fastafile ) {
        print $faUrl, "\n";
        `wget $faUrl`;
      }

      if ( !-e $fastafile ) {
        print STDERR "WARNING: cannot download or extract " . $fastafile . "\n";
        next;
      }
    }

    if ( $individualSpecies->{$species} ) {
      my $indBed         = $targetDirectoryIndividuals . $bedfile;
      my $indFasta       = $targetDirectoryIndividuals . $fastafile;
      my $indMatureFasta = $targetDirectoryIndividuals . $file . ".mature.fa";
      `cp $bedfile $indBed; cp $fastafile $indFasta;`;
      buildMatureFasta( $indBed, $indFasta, $indMatureFasta );
    }

    if ( $ignoreSpecies->{$species} ) {
      print STDERR "WARNING: " . $species . " ignored.\n";
      next;
    }

    print $smapfile $species, "\t", $category, "\n";

    processFile( $bedfile, $fastafile, $species, $category, $maturefile, $prefile, $mapfile, $idmap, $dupfile );
  }
  close($smapfile);
  close($mapfile);
  close($maturefile);
  close($prefile);
  close($dupfile);

  `mv $trnafaTmp $trnafa`;
}

exit(1);
