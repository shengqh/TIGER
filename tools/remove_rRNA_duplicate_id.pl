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
Remove duplicated id in fasta format

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
my $prefix;
my $help;

GetOptions(
  'h|help'     => \$help,
  'i|input=s'  => \$inputFile,
  'p|prefix=s' => \$prefix,
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

if ( !defined $prefix ) {
  $prefix = "";
}

my $seqio = Bio::SeqIO->new( -file => $inputFile, -format => 'fasta' );

my $seqnames      = {};
my $totalcount    = 0;
my $uniqueidcount = 0;

my $tmpFile = $outputFile . ".tmp";
open( my $fasta,   ">$tmpFile" ) or die "Cannot create $tmpFile";
open( my $dupid,   ">${outputFile}.dupid" ) or die "Cannot create ${outputFile}.dupid";
while ( my $seq = $seqio->next_seq ) {
  $totalcount++;
  my $id = $seq->id;
  my $desc = $seq->desc;
  if ( !exists $seqnames->{$id} ) {
    my $sequence = $seq->seq;
    $sequence =~ s/U/T/g;
    my @taxinomies = split(';', $desc);
    my $species=$taxinomies[scalar(@taxinomies)-1];
    my $newid = $prefix . $id . "_" . $species;
    $newid =~ s/[()\s]/_/g;
    $seqnames->{$id} = 1;
    $uniqueidcount++;
    print $fasta ">$newid $desc\n$sequence\n"
  }else{
    print STDERR " $id $desc\n";
    print $dupid "$id $desc\n";
  }
}
close($fasta);
close($dupid);

if(-e $outputFile){
  unlink($outputFile);
}
rename($tmpFile, $outputFile);

open( my $info, ">${outputFile}.info" ) or die "Cannot create ${outputFile}.info";
print $info "Total entries\t$totalcount
Unique id\t$uniqueidcount
";
close($info);

system("cat ${outputFile}.info");

1;
