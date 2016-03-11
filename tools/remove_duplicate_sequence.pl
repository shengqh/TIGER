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
Merge sequences in fasta format by id, then by sequence

Synopsis:

perl remove_duplicate_sequence.pl -f fastaFile

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

my $seqio = Bio::SeqIO->new( -file => $inputFile, -format => 'fasta' );

my $seqnames      = {};
my $totalcount    = 0;
my $uniqueidcount = 0;

while ( my $seq = $seqio->next_seq ) {
  $totalcount++;
  my $id = $seq->id;
  if ( !exists $seqnames->{$id} ) {
    $seqnames->{$id} = $seq->seq;
    $uniqueidcount++;
  }
}

my $sequences      = {};
my $uniqueseqcount = 0;
for my $id ( keys %{$seqnames} ) {
  my $seq = $seqnames->{$id};
  if ( !exists $sequences->{$seq} ) {
    $sequences->{$seq} = [$id];
    $uniqueseqcount++;
  }
  else {
    my @ids = @{ $sequences->{$seq} };
    push( @ids, $id );
    $sequences->{$seq} = \@ids;
  }
}

open( my $info, ">${outputFile}.info" ) or die "Cannot create ${outputFile}.info";
print $info "Total entries\t$totalcount
Unique id\t$uniqueidcount
Unique sequence\t$uniqueseqcount
";
close($info);

system("cat ${outputFile}.info");

my $dupidfile = "${outputFile}.dupid";
open( my $fasta,   ">$outputFile" ) or die "Cannot create $outputFile";
open( my $fastaid, ">$dupidfile" )  or die "Cannot create $dupidfile";
for my $seq ( keys %{$sequences} ) {
  my @ids = @{ $sequences->{$seq} };
  my $id  = $ids[0];
  print $fasta ">$id
$seq
";
  if ( scalar(@ids) > 1 ) {
    print $fastaid "$id\t" . join( ";", @ids ) . "\n";
  }
}
close($fasta);
close($fastaid);
1;
