#!/usr/bin/perl
use strict;
use warnings;

use File::Basename;
use Pipeline::SmallRNA;
use Pipeline::SmallRNAUtils;
use CQS::ClassFactory;

my $smallrna_db="/data/cqs/references/smallrna";
my $singularity_image="/data/cqs/softwares/singularity/cqs-smallRNA.simg";
my $report_image="/data/cqs/softwares/singularity/report.sif";
my $binding_folder="/scratch,/data";

my $def = {
  'docker_command' => "singularity exec -e -B $binding_folder -H `pwd` $singularity_image ",
  'report_docker_command' => "singularity exec -e -B $binding_folder -H `pwd` $report_image ",

  #task_name of the project. Don't contain space in the name which may cause problem.
  'task_name'  => 'test_proj',
  
  #cluster manager, either slurm or Torque
  'cluster'    => 'slurm',
  
  #node constraint of slurm
  #'constraint' => 'haswell',
  
  #target folder to save the result. Don't contain space in the name which may cause problem.
  'target_dir' => '/scratch/cqs/shengq2/temp/smallrna_test_proj',
  
  #email for cluster notification
  'email'      => 'quanhu.sheng.1@vumc.org',
  
  #preprocessing
  
  #is paired end data?
  'is_paired_end' => 0,

  #remove terminal 'N' in fastq reads
  'fastq_remove_N'      => 1,
  
  #remove contanination sequences before adapter trimming
  'remove_sequences'    => '\'CCACGTTCCCGTGG;ACAGTCCGACGATC\'',
  
  #trimming reads or not
  'perform_cutadapt'    => 1,
  
  #remove random bases before adapter trimming (NextFlex), set to 0 if no bases need to be removed (TruSeq).
  'fastq_remove_random' => 4,
  
  #trimming adapter
  'adapter'             => 'TGGAATTCTCGGGTGCCAAGG',
  
  #consider nontemplated nucleotide addition (NTA) of tRNA
  'consider_tRNA_NTA'   => 1,
  
  #consider nontemplated nucleotide addition (NTA) of miRNA
  'consider_miRNA_NTA'  => 1,
  
  #minimum read length after adapter trimming
  'min_read_length'     => 16,

  #host genome
  'search_host_genome'   => 1,
  'search_not_identical' => 1,
  'bowtie1_index'        => "$smallrna_db/mm10_miRBase22_GtRNAdb2_gencode24_ncbi",
  'coordinate'           => "$smallrna_db/mm10_miRBase22_GtRNAdb2_gencode24_ncbi.bed",
  'coordinate_fasta'     => "$smallrna_db/mm10_miRBase22_GtRNAdb2_gencode24_ncbi.bed.fa",
  'hasSnoRNA'            => 1,
  'hasYRNA'              => 0, #set to 1 for hg38 or hg19
  'hasSnRNA'             => 1,

  #non-host genome
  'search_nonhost_genome'         => 1,
  'bowtie1_bacteria_group1_index' => "$smallrna_db/20170206_Group1SpeciesAll",
  'bacteria_group1_species_map'   => "$smallrna_db/20170206_Group1SpeciesAll.species.map",
  'bowtie1_bacteria_group2_index' => "$smallrna_db/20160907_Group2SpeciesAll",
  'bacteria_group2_species_map'   => "$smallrna_db/20160907_Group2SpeciesAll.species.map",
  'bowtie1_fungus_group4_index'   => "$smallrna_db/20160225_Group4SpeciesAll",
  'fungus_group4_species_map'     => "$smallrna_db/20160225_Group4SpeciesAll.species.map",

  #this feature is not open yet
  'search_refseq_bacteria' => 0,

  #virus
  'bowtie1_virus_group6_index' => "$smallrna_db/20200305_viral_genomes",
  'virus_group6_species_map'   => "$smallrna_db/20200305_viral_genomes.map",

  #algae database
  'bowtie1_algae_group5_index' => "$smallrna_db/20200214_AlgaeSpeciesAll.species",
  'algae_group5_species_map'   => "$smallrna_db/20200214_AlgaeSpeciesAll.species.map",

  #non-host library
  'search_nonhost_library' => 1,
  'bowtie1_miRBase_index'  => "$smallrna_db/mature.dna",
  #the host prefix in mirbase, set "-p hsa" for human and "-p rno" for rat
  'mirbase_count_option'   => '-p mmu',
  'bowtie1_tRNA_index'     => "$smallrna_db/GtRNAdb2.20161214.mature",
  'trna_category_map'      => "$smallrna_db/GtRNAdb2.20161214.category.map",
  'trna_map'               => "$smallrna_db/GtRNAdb2.20161214.map",
  'bowtie1_rRNA_index'     => "$smallrna_db/SILVA_128.rmdup",
  'rrna_category_map'      => "$smallrna_db/SILVA_128.rmdup.category.map",

  #differential expression
  #If you don't want to perform comparison, remove the definition of 'pairs'.
  'DE_pvalue'                   => '0.05',
  'DE_fold_change'              => '1.5',
  'DE_detected_in_both_group'   => 1,
  'DE_use_raw_pvalue'           => 0,
  
  #TotalReads, FeatureReads, or none. 
  #TotalReads will use all valid reads for size factor calculation
  #FeatureReads will use all mapped host smallRNA reads for size factor calculation
  #none will use mapped category reads (for example, all miRNA reads when performing DE for miRNA) for size factor calculation
  'DE_library_key'              => 'TotalReads', 
  'DE_min_median_read'          => 5,
  'DE_min_median_read_smallRNA' => 5,
  
  #report
  'perform_report' => 1,

  #data
  'files' => {
    'Ctrl_1' => [ '/scratch/cqs/pipeline_example/smallrna_data/S1_R1_001.fastq.gz' ],
    'Ctrl_2' => [ '/scratch/cqs/pipeline_example/smallrna_data/S2_R1_001.fastq.gz' ],
    'Ctrl_3' => [ '/scratch/cqs/pipeline_example/smallrna_data/S3_R1_001.fastq.gz' ],
    'Treat_4' => [ '/scratch/cqs/pipeline_example/smallrna_data/S4_R1_001.fastq.gz' ],
    'Treat_5' => [ '/scratch/cqs/pipeline_example/smallrna_data/S5_R1_001.fastq.gz' ],
    'Treat_6' => [ '/scratch/cqs/pipeline_example/smallrna_data/S6_R1_001.fastq.gz' ],
  },
  
  'groups_pattern' => {
    'Ctrl'  => "Ctrl",
    'Treat'   => "Treat",
  },
  #you can also define group directly
  # 'groups' => {
  #   'Ctrl' => ["Ctrl_1","Ctrl_2","Ctrl_3"],
  #   'Treat' => ["Treat_4","Treat_5","Treat_6"],
  # },

  #define comparison. 
  'pairs' => {
    'Treat_vs_Ctrl' => {
      #the first group would be control group
      'groups' => [ 'Ctrl', 'Treat' ]
    },
  },
};

my $config = performSmallRNA($def, 1);

1;
