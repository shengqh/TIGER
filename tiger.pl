#!/usr/bin/perl
use strict;
use warnings;

use File::Basename;
use Getopt::Long;
use XML::Simple;
use Hash::Merge qw( merge );
use Pipeline::SmallRNA;
use Pipeline::SmallRNAUtils;

my $usage = "

Synopsis:

perl tiger.pl -g genome -p project_file --create

Options:
  -g|--genome {string}    Genome name (such like hg19/hg38/mm10/rn5, the name in your tiger.xml file)
  -p|--project {string}   Project config file (the definition of your fastq files, groups and pairs et.al.)
  --create                Create default project config file
  -h|--help               This page.
";

Getopt::Long::Configure('bundling');

my $genome_name;
my $project_file;
my $create;
my $help;

GetOptions(
  'g|genome=s'  => \$genome_name,
  'p|project=s' => \$project_file,
  'create'      => \$create,
  'h|help'      => \$help,
);

if ( defined $help ) {
  print $usage;
  exit(1);
}

if ( !defined $genome_name ){
  print "Input genome name in tiger.xml\n" ;
  print $usage;
  exit(1);
}  
 
if(!-e $project_file){
  print "Input project xml file\n" ;
  print $usage;
  exit(1);
} 
 
my $config_file = dirname(__FILE__) . "/tiger.xml";

my $config = eval { XMLin($config_file) };

defined $config->{options}      or die "No options defined in tiger.xml file";
defined $config->{supplement}   or die "No supplement defined in tiger.xml file";
defined $config->{$genome_name} or die "No $genome_name defined in tiger.xml file";

my $genome = {
  genome     => $config->{$genome_name},
  supplement => $config->{supplement}
};

my $def;
if ($create) {
  $def = merge(
    $genome,
    {
      options => merge(
        $config->{options},
        {
          'target_dir' => 'my_target_folder',
          'task_name'  => 'MyTask',
          'email'      => 'MyEmail',
          'max_thread' => 8,
          'cqstools'   => 'location of CQS.Tools.exe',
          'files'      => {
            'Control1' => ['sample1.fastq.gz'],
            'Control2' => ['sample2.fastq.gz'],
            'Control3' => ['sample3.fastq.gz'],
            'Sample1'  => ['sample1.fastq.gz'],
            'Sample2'  => ['sample2.fastq.gz'],
            'Sample3'  => ['sample3.fastq.gz'],
          },
          'groups' => {
            'Control' => [ 'Control1', 'Control2', 'Control3' ],
            'Sample'  => [ 'Sample1',  'Sample2',  'Sample3' ],
          },
          'pairs' => {
            'Sample_VS_Control' => {
              'groups' => [ 'Control', 'Sample' ]
            }
          },
        }
      )
    }
  );
  open my $fh, '>:encoding(utf8)', $project_file or die "open($project_file): $!";
  XMLout(
    $config,
    OutputFile => $fh,
    noattr     => 1
  );
  close($fh);
}
else {
  my $project = eval { XMLin($project_file) };
  $def = merge( $project, $genome );
  performSmallRNA($def);
}

