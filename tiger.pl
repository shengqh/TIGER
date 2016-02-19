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
  --create                Create default project config file
  -g|--genome {string}    Genome name (such like hg19/hg38/mm10/rn5, the name in your tiger.xml file)
  -p|--project {string}   Project config file (the definition of your fastq files, groups and pairs et.al.)
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

my $merge = Hash::Merge->new( 'LEFT_PRECEDENT' );

if ( defined $create ) {
  if ( !defined $genome_name ) {
    print "Input genome name in tiger.xml\n";
    print $usage;
    exit(1);
  }

  if ( !defined $project_file ) {
    print "Input project xml file\n";
    print $usage;
    exit(1);
  }

  my $config_file = dirname(__FILE__) . "/tiger.xml";
  my $config = eval { XMLin($config_file) };

  defined $config->{options}      or die "No options defined in file " . $config_file;
  defined $config->{supplement}   or die "No supplement defined in file" . $config_file;
  defined $config->{$genome_name} or die "No $genome_name defined in file" . $config_file;

  my $genome = {
    genome     => $config->{$genome_name},
    supplement => $config->{supplement}
  };

  my $project_options;
  if ( !-e $project_file ) {
    $project_options = {
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
    };
  }
  else {
    my $oldproject = eval { XMLin($project_file) };
    $project_options = $oldproject->{options};
  }

  my $options = merge(
    $config->{options},
    $project_options
  );
  my $project = merge(
    $genome,
    {
      options => $options
    }
  );
  open my $fh, '>:encoding(utf8)', $project_file or die "open($project_file): $!";
  XMLout(
    $project,
    OutputFile => $fh,
    noattr     => 1
  );
  close($fh);
}
else {
  if ( !defined $project_file ) {
    print "Input project xml file!\n";
    print $usage;
    exit(1);
  }

  if ( !-e $project_file ) {
    print "Project xml file not exist " . $project_file . "\n";
    print $usage;
    exit(1);
  }

  my $project = eval { XMLin($project_file) };
  performSmallRNA($project);
}

