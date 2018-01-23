#!/usr/bin/perl
use strict;
use warnings;

use File::Basename;
use Pipeline::SmallRNA;
use Pipeline::SmallRNAUtils;
use CQS::ClassFactory;

my $def = {
  'task_name'  => '3018-KCV_76_mouse',
  'constraint' => 'haswell',
  'cluster'    => 'slurm',
  'target_dir' => '/scratch/cqs/shengq2/temp/20171219_smallRNA_3018-KCV_76_mouse_v3',
  'email'      => 'quanhu.sheng.1@vanderbilt.edu',
  'cqstools'   => '/home/shengq2/cqstools/cqstools.exe',

  #preprocessing
  'fastq_remove_N'      => 1,
  'remove_sequences'    => '\'CCACGTTCCCGTGG;ACAGTCCGACGATC\'',
  'perform_cutadapt'    => 1,
  'adapter'             => 'TGGAATTCTCGGGTGCCAAGG',
  'fastq_remove_random' => 4,
  'consider_tRNA_NTA'   => 1,
  'consider_miRNA_NTA'  => 1,
  'min_read_length'     => 16,

  #host genome
  'search_host_genome'   => 1,
  'search_not_identical' => 1,
  'bowtie1_index'        => '/scratch/cqs/shengq2/references/smallrna/v3/bowtie_index_1.1.2/mm10_miRBase21_GtRNAdb2_gencode12_ncbi',
  'coordinate'           => '/scratch/cqs/shengq2/references/smallrna/v3/mm10_miRBase21_GtRNAdb2_gencode12_ncbi.bed',
  'coordinate_fasta'     => '/scratch/cqs/shengq2/references/smallrna/v3/mm10_miRBase21_GtRNAdb2_gencode12_ncbi.bed.fa',
  'hasSnoRNA'            => 1,
  'hasYRNA'              => 0,
  'hasSnRNA'             => 1,

  #non-host genome
  'search_nonhost_genome'         => 1,
  'bowtie1_bacteria_group1_index' => '/scratch/cqs/zhaos/vickers/reference/bacteria/group1/bowtie_index_1.1.2/bacteriaDatabaseGroup1',
  'bacteria_group1_species_map'   => '/scratch/cqs/zhaos/vickers/reference/bacteria/group1/20170206_Group1SpeciesAll.species.map',
  'bowtie1_bacteria_group2_index' => '/scratch/cqs/zhaos/vickers/reference/bacteria/group2/bowtie_index_1.1.2/bacteriaDatabaseGroup2',
  'bacteria_group2_species_map'   => '/scratch/cqs/zhaos/vickers/reference/bacteria/group2/20160907_Group2SpeciesAll.species.map',
  'bowtie1_fungus_group4_index'   => '/scratch/cqs/zhaos/vickers/reference/bacteria/group4/bowtie_index_1.1.2/group4',
  'fungus_group4_species_map'     => '/scratch/cqs/zhaos/vickers/reference/bacteria/group4/20160225_Group4SpeciesAll.species.map',

  #non-host library
  'search_nonhost_library' => 1,
  'bowtie1_miRBase_index'  => '/scratch/cqs/shengq2/references/miRBase21/bowtie_index_1.1.1/mature.dna',
  'mirbase_count_option'   => '-p mmu',
  'bowtie1_tRNA_index'     => '/scratch/cqs/shengq2/references/smallrna/v3/GtRNAdb2/bowtie_index_1.1.2/GtRNAdb2.20161214.mature',
  'trna_category_map'      => '/scratch/cqs/shengq2/references/smallrna/v3/GtRNAdb2/GtRNAdb2.20161214.category.map',
  'trna_map'               => '/scratch/cqs/shengq2/references/smallrna/v3/GtRNAdb2/GtRNAdb2.20161214.map',
  'bowtie1_rRNA_index'     => '/scratch/cqs/shengq2/references/smallrna/v3/SILVA/bowtie_index_1.1.2/SILVA_128.rmdup',
  'rrna_category_map'      => '/scratch/cqs/shengq2/references/smallrna/v3/SILVA/SILVA_128.rmdup.category.map',

  #blast
  'blast_top_reads'      => 1,
  'blast_localdb'        => '/scratch/cqs/shengq2/references/blastdb',
  'blast_unmapped_reads' => 1,

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