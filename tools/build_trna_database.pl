#!/usr/local/bin/perl

use strict;
use File::Basename;
use LWP::Simple;
use LWP::UserAgent;
use Bio::SeqIO;
use POSIX qw(strftime);

my $datestring = strftime "%Y%m%d", localtime;
my $trnafa     = "GtRNAdb2." . $datestring . ".fa";
my $trnafamap  = $trnafa . ".map";

if ( !-e $trnafa ) {
  my $ua = new LWP::UserAgent;
  $ua->agent( "AgentName/0.1 " . $ua->agent );

  # Create a request
  my $url = 'http://gtrnadb.ucsc.edu/GtRNAdb2/genomes/';
  my $req = new HTTP::Request GET => $url;

  # Pass request to the user agent and get a response back
  my $res = $ua->request($req);

  #print $res->content;

  open( my $mapfile, ">$trnafamap" ) or die "Cannot create $trnafamap";
  print $mapfile "Id\tName\tSpecies\n";

  if ( $res->is_success ) {
    my $rescontent = $res->content;

    my @categories = ( $rescontent =~ m/folder.gif" alt="\[DIR\]"> <a href="(.*?)\/"/g );
    foreach my $category (@categories) {
      
      #ignore the viruses to simplify the pie chart may drawn
      if ($category eq "viruses"){
        continue;
      }
      
      print $category, "\n";

      my $categoryurl     = $url . $category;
      my $categoryreq     = new HTTP::Request GET => $categoryurl;
      my $categoryres     = $ua->request($categoryreq);
      my $categorycontent = $categoryres->content;

      my @species_array = $categorycontent =~ m/folder.gif" alt="\[DIR\]"> <a href="(.*?)\/"/g;

      foreach my $species (@species_array) {
        print $category, " : ", $species, "\n";

        my $speciesurl     = $categoryurl . "/" . $species;
        my $speciesreq     = new HTTP::Request GET => $speciesurl;
        my $speciesres     = $ua->request($speciesreq);
        my $speciescontent = $speciesres->content;

        #print $speciescontent, "\n";

        if ( $speciescontent =~ /href="(.*?\.fa)">FASTA Seqs/ ) {
          my $file  = $1;
          my $faurl = $speciesurl . "/" . $1;
          print $faurl, "\n";

          `wget $faurl; cat $file >> $trnafa`;

          if ( -e $file ) {
            my $seqio = Bio::SeqIO->new( -file => $file, -format => 'fasta' );
            my $seqnames = {};
            while ( my $seq = $seqio->next_seq ) {
              my $id = $seq->id;
              print $mapfile "${id}\t$species\t${category}\n";
            }
            unlink($file);
          }
        }
      }
    }
  }
}
my $script         = dirname(__FILE__) . "/remove_duplicate_sequence.pl";
my $trnaRmdupFasta = "GtRNAdb2." . $datestring . ".rmdup.fa";

`perl $script -i $trnafa -o $trnaRmdupFasta`;

exit(1);
