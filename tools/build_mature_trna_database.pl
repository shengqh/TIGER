#!/usr/local/bin/perl

use strict;
use File::Basename;
use LWP::Simple;
use LWP::UserAgent;
use Bio::SeqIO;
use POSIX qw(strftime);
use URI::Escape;

my $target_dir      = "/scratch/cqs/shengq1/references/ucsc/GtRNAdb2/";
my $target_dir_temp = $target_dir . "temp/";
if ( !-e $target_dir_temp ) {
  mkdir($target_dir_temp) or die "cannot mkdir directory: $!\n";
}
chdir($target_dir_temp) or die "cannot change: $!\n";

sub getStructure {
  my $structureFile = shift;

  if ( !-e $structureFile ) {
    my $tmpFile = $structureFile . ".tmp";

    my $ua = new LWP::UserAgent;
    $ua->agent( "AgentName/0.1 " . $ua->agent );

    # Create a request
    my $url = 'http://gtrnadb.ucsc.edu/GtRNAdb2/genomes/';
    my $req = new HTTP::Request GET => $url;

    # Pass request to the user agent and get a response back
    my $res = $ua->request($req);

    if ( $res->is_success ) {
      open( my $tmp, ">$tmpFile" ) or die "Cannot create $tmpFile";
      my $rescontent = $res->content;

      my @categories = ( $rescontent =~ m/folder.gif" alt="\[DIR\]"> <a href="(.*?)\/"/g );
      foreach my $category (@categories) {
        print $category, "\n";

        my $categoryurl     = $url . $category;
        my $categoryreq     = new HTTP::Request GET => $categoryurl;
        my $categoryres     = $ua->request($categoryreq);
        my $categorycontent = $categoryres->content;

        my @species_array = $categorycontent =~ m/folder.gif" alt="\[DIR\]"> <a href="(.*?)\/"/g;

        foreach my $species (@species_array) {
          if ( $species =~ /_old/ ) {
            next;
          }
          my $speciesurl     = $categoryurl . "/" . $species;
          my $speciesreq     = new HTTP::Request GET => $speciesurl;
          my $speciesres     = $ua->request($speciesreq);
          my $speciescontent = $speciesres->content;

          #print $speciescontent, "\n";

          my $tarUrl;
          my $faUrl;
          my $filePrefix;
          if ( $speciescontent =~ /href="(.*?)\.tar.gz">/ ) {
            $filePrefix = $1;
            my $tarfile = $1 . ".tar.gz";
            $tarUrl = $speciesurl . "/" . uri_escape($tarfile);
          }
          else {
            print "Cannot find tar url of " . $species . " in " . $category . "; Species url = " . $speciesurl . "\n";
            next;
          }

          if ( $speciescontent =~ /href="(.*?\.fa)">/ ) {
            my $fastafile = $1;
            $faUrl = $speciesurl . "/" . uri_escape($fastafile);
          }
          else {
            print "Cannot find fa url of " . $species . " in " . $category . "; Species url = " . $speciesurl . "\n";
            next;
          }

          print $tmp $species . "\t" . $category . "\t" . $filePrefix . "\t" . $tarUrl . "\t" . $faUrl . "\n";
        }
      }
      `mv $tmpFile $structureFile`;
    }
  }

  my $result = [];
  open( my $sr, $structureFile ) or die "Could not open file '$structureFile' $!";
  while ( my $row = <$sr> ) {
    chomp $row;
    my @parts = split( "\t", $row );
    push( @$result, \@parts );
  }

  close($sr);

  return $result;
}

sub readBedFile {
  my $bedFile = shift;

  open( my $bedio, $bedFile ) or die "Could not open file '$bedFile' $!";
  my $result = {};
  while ( my $row = <$bedio> ) {
    chomp $row;
    my @parts     = split( "\t", $row );
    my $name      = $parts[3];
    my @sizes     = map( int($_), split( ",", $parts[10] ) );
    my @positions = map( int($_), split( ",", $parts[11] ) );

    $result->{$name} = { sizes => \@sizes, positions => \@positions };
  }

  return $result;
}

sub dealFile {
  my ( $bedfile, $fastafile, $test, $species, $category, $maturefile, $prefile, $mapfile, $idmap ) = @_;

  my $beds = readBedFile($bedfile);

  my $seqio = Bio::SeqIO->new( -file => $fastafile, -format => 'fasta' );
  my $seqnames = {};
  while ( my $seq = $seqio->next_seq ) {
    my $id       = $seq->id;
    my $sequence = $seq->seq;
    if ( exists $idmap->{$id} ) {
      next;
    }

    $idmap->{$id} = 1;
    my $desc = $seq->desc;

    if ( !$test ) {
      print $mapfile "${id}\t${species}\t${category}\n";
      print $prefile ">$id $desc\n$sequence\n";
    }

    my $values = undef;
    for my $key ( keys %$beds ) {
      my $keylen = length($key);
      if ( $key eq substr( $id, -$keylen ) ) {
        $values = $beds->{$key};
        last;
      }
    }

    $id = "$id $desc";

    if ( !defined $values ) {
      print STDERR "Cannot find " . $id . " in bed file of " . $bedfile . "\n";
      print $maturefile ">$id\n$sequence\n";
      next;
    }

    my $sizes     = $values->{sizes};
    my $positions = $values->{positions};

    my $numberOfExon = scalar(@$sizes);
    if ( $numberOfExon > 1 ) {
      my $tmpSeq = "";
      for my $i ( 0 .. ( $numberOfExon - 1 ) ) {
        my $start  = @$positions[$i];
        my $length = @$sizes[$i];
        $tmpSeq = $tmpSeq . substr( $sequence, $start, $length );
      }
      $sequence = $tmpSeq;
      $id       = $id . " intron_removed";
    }
    if ( !$test ) {
      print $maturefile ">$id\n$sequence\n";
    }
  }
}

sub extractFile {
  my ( $inputFile, $pattern, $outputFile, $overwrite ) = @_;

  if ( -s $outputFile && !$overwrite ) {
    print STDOUT "$outputFile exists, ignored.\n";
    return;
  }

  print STDOUT "Extracting $outputFile ...\n";
  open( my $output, ">$outputFile" ) or die "Could not create file '$outputFile' $!";

  my $seqio = Bio::SeqIO->new( -file => $inputFile, -format => 'fasta' );
  while ( my $seq = $seqio->next_seq ) {
    my $id       = $seq->id;
    my $desc     = $seq->desc;
    my $sequence = $seq->seq;

    if ( $id =~ /$pattern/ ) {
      print $output ">$id $desc\n$sequence\n";
    }
  }

  close($output);
  print STDOUT "$outputFile extracted.\n";
}

#my $datestring = strftime "%Y%m%d", localtime;
my $datestring = "20161214";

my $structureFile = "../GtRNAdb2." . $datestring . ".structure.tsv";
my $structures    = getStructure($structureFile);

my $prefix = "../GtRNAdb2." . $datestring;

my $trnafa          = $prefix . ".mature.fa";
my $trnaPrematureFa = $prefix . ".pre.fa";
my $trnafamap       = $prefix . ".map";
my $trnafaspecies   = $prefix . ".speciesmap";

my $trnafaTmp = $trnafa . ".tmp";

my $idmap = {};

my $ignoreSpecies = {
  "Mmusc"   => 1,
  "Hsapi38" => 1,
};

if ( !-e $trnafa ) {
  if ( -e $trnafaTmp ) {
    unlink($trnafaTmp);
  }

  my $ua = new LWP::UserAgent;
  $ua->agent( "AgentName/0.1 " . $ua->agent );

  open( my $maturefile, ">$trnafaTmp" )       or die "Cannot create $trnafaTmp";
  open( my $prefile,    ">$trnaPrematureFa" ) or die "Cannot create $trnaPrematureFa";
  open( my $mapfile,    ">$trnafamap" )       or die "Cannot create $trnafamap";
  print $mapfile "Id\tName\tSpecies\n";

  open( my $smapfile, ">$trnafaspecies" ) or die "Cannot create $trnafaspecies";
  print $smapfile "Species\tCategory\n";

  foreach my $species_array (@$structures) {
    my $species  = @$species_array[0];
    my $category = @$species_array[1];
    my $file     = @$species_array[2];
    my $tarUrl   = @$species_array[3];
    my $faUrl    = @$species_array[4];
    
    if($ignoreSpecies->{$species}){
      print STDERR "WARNING: " . $species . " ignored.\n";
      next;
    }

    print $category . " : " . $species . "\n";

    print $smapfile $species, "\t", $category, "\n";

    my $tarfile   = $file . ".tar.gz";
    my $bedfile   = $file . ".bed";
    my $fastafile = $file . ".fa";

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

    dealFile( $bedfile, $fastafile, 0, $species, $category, $maturefile, $prefile, $mapfile, $idmap );
  }
  close($smapfile);
  close($mapfile);
  close($maturefile);
  close($prefile);

  `mv $trnafaTmp $trnafa`;
}

extractFile( $trnafa, "Homo_sapiens",      "../GtRNAdb2.${datestring}.mature.Homo_sapiens.fa" );
extractFile( $trnafa, "Mus_musculus",      "../GtRNAdb2.${datestring}.mature.Mus_musculus.fa" );
extractFile( $trnafa, "Rattus_norvegicus", "../GtRNAdb2.${datestring}.mature.Rattus_norvegicus.fa" );

exit(1);
