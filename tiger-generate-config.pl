#!/usr/bin/perl
use strict;
use warnings;

use File::Basename;
use Getopt::Long;
use XML::Simple;
use CQS::PerformSmallRNA;
use Pipeline::SmallRNAUtils;

my $config_file = dirname(__FILE__) . "/tiger.xml";

#my $config = eval { XMLin($config_file) };

my $config = {
  options    => getSmallRNADefinition( {},      {} ),
  supplement => supplement_genome(),
  hg19       => hg19_genome()
};

open my $fh, '>:encoding(utf8)', $config_file or die "open($config_file): $!";
XMLout(
  $config,
  OutputFile => $fh,
  noattr     => 1
);
close($fh);
