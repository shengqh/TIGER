#!/usr/bin/perl
use strict;
use warnings;

use File::Basename;
use Pipeline::SmallRNA;
use Pipeline::SmallRNAUtils;
use CQS::ClassFactory;

my $smallrna_db="/workspace/shengq2/smallrna_db";
my $blast_db="/scratch/cqs/shengq2/references/blastdb";

my $def = {
  #task_name of the project. Don't contain space in the name which may cause problem.
  'task_name'  => '3018-KCV_76_mouse',
  
  #cluster manager, either slurm or Torque
  'cluster'    => 'slurm',
  
  #node constraint of slurm
  #'constraint' => 'haswell',
  
  #target folder to save the result. Don't contain space in the name which may cause problem.
  'target_dir' => '/workspace/shengq2/20171219_smallRNA_3018-KCV_76_mouse_v3',
  
  #email for cluster notification
  'email'      => 'quanhu.sheng.1@vanderbilt.edu',
  
  #absolute cqstools location
  'cqstools'   => '/home/shengq2/cqstools/cqstools.exe',

  #preprocessing
  
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
  'hasYRNA'              => 0,
  'hasSnRNA'             => 1,

  #non-host genome
  'search_nonhost_genome'         => 1,
  'bowtie1_bacteria_group1_index' => "$smallrna_db/20170206_Group1SpeciesAll",
  'bacteria_group1_species_map'   => "$smallrna_db/20170206_Group1SpeciesAll.species.map",
  'bowtie1_bacteria_group2_index' => "$smallrna_db/20160907_Group2SpeciesAll",
  'bacteria_group2_species_map'   => "$smallrna_db/20160907_Group2SpeciesAll.species.map",
  'bowtie1_fungus_group4_index'   => "$smallrna_db/20160225_Group4SpeciesAll",
  'fungus_group4_species_map'     => "$smallrna_db/20160225_Group4SpeciesAll.species.map",

  #non-host library
  'search_nonhost_library' => 1,
  'bowtie1_miRBase_index'  => '$smallrna_db/mature.dna',
  #the host prefix in mirbase, set "-p hsa" for human and "-p rno" for rat
  'mirbase_count_option'   => '-p mmu',
  'bowtie1_tRNA_index'     => "$smallrna_db/GtRNAdb2.20161214.mature",
  'trna_category_map'      => "$smallrna_db/GtRNAdb2.20161214.category.map",
  'trna_map'               => "$smallrna_db/GtRNAdb2.20161214.map",
  'bowtie1_rRNA_index'     => "$smallrna_db/SILVA_128.rmdup",
  'rrna_category_map'      => "$smallrna_db/SILVA_128.rmdup.category.map",

  #blast
  'blast_top_reads'      => 0,
  'blast_localdb'        => $blast_db,
  'blast_unmapped_reads' => 0,

  #differential expression
  'DE_pvalue'                   => '0.05',
  'DE_fold_change'              => '1.5',
  'DE_detected_in_both_group'   => 1,
  'DE_use_raw_pvalue'           => 0,
  'DE_library_key'              => 'TotalReads',
  'DE_min_median_read'          => 5,
  'DE_min_median_read_smallRNA' => 5,
  
  #report
  perform_report => 1,

  #data
  'files' => {
    'IP_ApoE_HFD_02'  => ['/scratch/cqs/zhaos/vickers/data/3018/3018-KCV-76/3018/3018-KCV-76-i34_S10_R1_001.fastq.gz'],
    'IP_ApoE_Chow_02' => ['/scratch/cqs/zhaos/vickers/data/3018/3018-KCV-76/3018/3018-KCV-76-i30_S6_R1_001.fastq.gz'],
    'IP_ApoE_HFD_04'  => ['/scratch/cqs/zhaos/vickers/data/3018/3018-KCV-76/3018/3018-KCV-76-i36_S12_R1_001.fastq.gz'],
    'IP_WT_Chow_03'   => ['/scratch/cqs/zhaos/vickers/data/3018/3018-KCV-76/3018/3018-KCV-76-i27_S3_R1_001.fastq.gz'],
    'IP_WT_Chow_02'   => ['/scratch/cqs/zhaos/vickers/data/3018/3018-KCV-76/3018/3018-KCV-76-i26_S2_R1_001.fastq.gz'],
    'IP_ApoE_Chow_03' => ['/scratch/cqs/zhaos/vickers/data/3018/3018-KCV-76/3018/3018-KCV-76-i31_S7_R1_001.fastq.gz'],
    'IP_ApoE_HFD_01'  => ['/scratch/cqs/zhaos/vickers/data/3018/3018-KCV-76/3018/3018-KCV-76-i33_S9_R1_001.fastq.gz'],
    'IP_WT_Chow_04'   => ['/scratch/cqs/zhaos/vickers/data/3018/3018-KCV-76/3018/3018-KCV-76-i28_S4_R1_001.fastq.gz'],
    'IP_ApoE_HFD_03'  => ['/scratch/cqs/zhaos/vickers/data/3018/3018-KCV-76/3018/3018-KCV-76-i35_S11_R1_001.fastq.gz'],
    'IP_ApoE_Chow_01' => ['/scratch/cqs/zhaos/vickers/data/3018/3018-KCV-76/3018/3018-KCV-76-i29_S5_R1_001.fastq.gz'],
    'IP_WT_Chow_01'   => ['/scratch/cqs/zhaos/vickers/data/3018/3018-KCV-76/3018/3018-KCV-76-i25_S1_R1_001.fastq.gz'],
    'IP_ApoE_Chow_04' => ['/scratch/cqs/zhaos/vickers/data/3018/3018-KCV-76/3018/3018-KCV-76-i32_S8_R1_001.fastq.gz']
  },
  'groups' => {
    'IP_ApoE_HFD'  => [ 'IP_ApoE_HFD_01',  'IP_ApoE_HFD_02',  'IP_ApoE_HFD_03',  'IP_ApoE_HFD_04' ],
    'IP_ApoE_Chow' => [ 'IP_ApoE_Chow_01', 'IP_ApoE_Chow_02', 'IP_ApoE_Chow_03', 'IP_ApoE_Chow_04' ],
    'IP_WT_Chow'   => [ 'IP_WT_Chow_01',   'IP_WT_Chow_02',   'IP_WT_Chow_03',   'IP_WT_Chow_04' ],
  },
  'pairs' => {
    'IP_ApoE_Chow_VS_IP_WT_Chow' => {
      'groups' => [ 'IP_WT_Chow', 'IP_ApoE_Chow' ]
    },
    'IP_ApoE_HFD_VS_IP_ApoE_Chow' => {
      'groups' => [ 'IP_ApoE_Chow', 'IP_ApoE_HFD' ]
    },
  },
};

my $config = performSmallRNA($def, 1);

1;
