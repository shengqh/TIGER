#!/usr/bin/perl
use strict;
use warnings;

use File::Basename;
use Pipeline::SmallRNA;
use Pipeline::SmallRNAUtils;
use CQS::ClassFactory;
use CQS::ConfigUtils;

#The folder that you download the databases by download_tigerdb_v2022.sh
my $smallrna_db="/data/cqs/references/smallrna";

#The folder that you download the data by download_example_data.sh
my $example_folder="/nobackup/h_cqs/pipeline_example/smallrna_data";

my $singularity_image="/data/cqs/softwares/singularity/cqs-smallRNA.simg";
my $report_image="/data/cqs/softwares/singularity/report.sif";

#binding folder for singularity, should include the folder with data, the folder for output and the folder with ngsperl
my $binding_folder="/nobackup,/data,/home/`whoami`";

my $hg38_genome = {
  #genome database
  mirbase_count_option => "-p hsa",
  miRNA_coordinate     => "$smallrna_db/v202211/hg38/hg38_miRBase22_GtRNAdb19_gencode42.miRNA.bed",
  coordinate           => "$smallrna_db/v202211/hg38/hg38_miRBase22_GtRNAdb19_gencode42_HERVd.bed",
  coordinate_fasta     => "$smallrna_db/v202211/hg38/hg38_miRBase22_GtRNAdb19_gencode42_HERVd.bed.fa",
  bowtie1_index        => "$smallrna_db/v202211/hg38/bowtie_index_1.3.1/hg38_miRBase22_GtRNAdb19_gencode42",

  hasYRNA   => 1,
  hasSnRNA  => 1,
  hasSnoRNA => 1,
  hasERV => 1,

  software_version => {
    host => "GENCODE GRCh38.p13",
  }
};

my $mm10_genome = {
  #genome database
  mirbase_count_option => "-p mmu",
  miRNA_coordinate     => "$smallrna_db/mm10_miRBase22_GtRNAdb2_gencode24_ncbi.miRNA.bed",
  coordinate           => "$smallrna_db/mm10_miRBase22_GtRNAdb2_gencode24_ncbi.bed",
  coordinate_fasta     => "$smallrna_db/mm10_miRBase22_GtRNAdb2_gencode24_ncbi.bed.fa",
  bowtie1_index        => "$smallrna_db/mm10_miRBase22_GtRNAdb2_gencode24_ncbi",

  hasYRNA   => 0,
  hasSnRNA  => 1,
  hasSnoRNA => 1,

  software_version => {
    host => "GENCODE GRCm38.p6",
  }
};

my $rn6_genome = {
  #genome database
  mirbase_count_option => "-p rno",
  miRNA_coordinate     => "$smallrna_db/rn6_miRBase22_GtRNAdb2_ensembl99_ncbi.miRNA.bed",
  coordinate           => "$smallrna_db/rn6_miRBase22_GtRNAdb2_ensembl99_ncbi.bed",
  coordinate_fasta     => "$smallrna_db/rn6_miRBase22_GtRNAdb2_ensembl99_ncbi.bed.fa",
  bowtie1_index        => "$smallrna_db/rn6_miRBase22_GtRNAdb2_ensembl99_ncbi",

  hasYRNA   => 1,
  hasSnRNA  => 1,
  hasSnoRNA => 1,

  software_version => {
    host => "Ensembl Rnor_6.0",
  }
};

my $def = merge_hash_right_precedent($mm10_genome, 
{
  'docker_command' => "singularity exec -e -B $binding_folder -H `pwd` $singularity_image ",
  'report_docker_command' => "singularity exec -e -B $binding_folder -H `pwd` $report_image ",

  #task_name of the project. Don't contain space in the name which may cause problem.
  'task_name'  => 'test_proj',
  
  #cluster manager, either slurm or Torque
  'cluster'    => 'slurm',
  
  #node constraint of slurm
  #'constraint' => 'haswell',
  
  #target folder to save the result. Don't contain space in the name which may cause problem.
  'target_dir' => '/nobackup/h_cqs/shengq2/temp/smallrna_test_proj',
  
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
  
  #remove random bases before adapter trimming (NextFlex), set to 0 if no bases need to be removed (for example, TruSeq).
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
  'search_not_identical' => 0,

  #non-host genomes
  'search_nonhost_genome'         => 1,
  'bowtie1_bacteria_group1_index' => "$smallrna_db/20170206_Group1SpeciesAll",
  'bacteria_group1_species_map'   => "$smallrna_db/20170206_Group1SpeciesAll.species.map",
  'bowtie1_bacteria_group2_index' => "$smallrna_db/20160907_Group2SpeciesAll",
  'bacteria_group2_species_map'   => "$smallrna_db/20160907_Group2SpeciesAll.species.map",
  'bowtie1_fungus_group4_index'   => "$smallrna_db/20160225_Group4SpeciesAll",
  'fungus_group4_species_map'     => "$smallrna_db/20160225_Group4SpeciesAll.species.map",

  #all bacteria genomes
  search_refseq_bacteria => 1,
  krona_taxonomy_folder => "$smallrna_db/spcount/",
  refseq_bacteria_species => "$smallrna_db/spcount/20220406_bacteria.taxonomy.txt",
  refseq_assembly_summary => "$smallrna_db/spcount/20220406_assembly_summary_refseq.txt",
  refseq_taxonomy => "$smallrna_db/spcount/20220406_taxonomy.txt",
  refseq_bacteria_bowtie_index => {
    'bacteria.001' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.001" ],
    'bacteria.002' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.002" ],
    'bacteria.003' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.003" ],
    'bacteria.004' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.004" ],
    'bacteria.005' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.005" ],
    'bacteria.006' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.006" ],
    'bacteria.007' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.007" ],
    'bacteria.008' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.008" ],
    'bacteria.009' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.009" ],
    'bacteria.010' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.010" ],
    'bacteria.011' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.011" ],
    'bacteria.012' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.012" ],
    'bacteria.013' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.013" ],
    'bacteria.014' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.014" ],
    'bacteria.015' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.015" ],
    'bacteria.016' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.016" ],
    'bacteria.017' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.017" ],
    'bacteria.018' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.018" ],
    'bacteria.019' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.019" ],
    'bacteria.020' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.020" ],
    'bacteria.021' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.021" ],
    'bacteria.022' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.022" ],
    'bacteria.023' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.023" ],
    'bacteria.024' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.024" ],
    'bacteria.025' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.025" ],
    'bacteria.026' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.026" ],
    'bacteria.027' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.027" ],
    'bacteria.028' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.028" ],
    'bacteria.029' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.029" ],
    'bacteria.030' => [ "$smallrna_db/spcount/fasta/20220406_bacteria.030" ],
  },

  #virus
  'bowtie1_virus_group6_index' => "$smallrna_db/20200305_viral_genomes",
  'virus_group6_species_map'   => "$smallrna_db/20200305_viral_genomes.map",

  #algae database
  'bowtie1_algae_group5_index' => "$smallrna_db/20200214_AlgaeSpeciesAll.species",
  'algae_group5_species_map'   => "$smallrna_db/20200214_AlgaeSpeciesAll.species.map",

  #non-host library
  'search_nonhost_library' => 1,
  'bowtie1_miRBase_index' => "$smallrna_db/v202211/miRBase.v22.1/bowtie_index_1.3.1/mature.dna",

  #UCSC tRNA database
  'bowtie1_tRNA_index' => "$smallrna_db/v202211/GtRNAdb.v19/bowtie_index_1.3.1/GtRNAdb.v19.mature",
  'trna_category_map'  => "$smallrna_db/v202211/GtRNAdb.v19/GtRNAdb.v19.category.map",

  #SILVA rRNA database
  'bowtie1_rRNA_index' => "$smallrna_db/v202211/SILVA_138.1/bowtie_index_1.3.1/SILVA_138.1.rmdup",
  'rrna_category_map'  => "$smallrna_db/v202211/SILVA_138.1/SILVA_138.1.category.map",

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
    'Ctrl_1' => [ "$example_folder/S1_R1_001.fastq.gz" ],
    'Ctrl_2' => [ "$example_folder/S2_R1_001.fastq.gz" ],
    'Ctrl_3' => [ "$example_folder/S3_R1_001.fastq.gz" ],
    'Treat_4' => [ "$example_folder/S4_R1_001.fastq.gz" ],
    'Treat_5' => [ "$example_folder/S5_R1_001.fastq.gz" ],
    'Treat_6' => [ "$example_folder/S6_R1_001.fastq.gz" ],
  },

  'groups_pattern' => "(.+?)_",
  # #you can also define group pattern individually
  # 'groups_pattern' => {
  #   'Ctrl' => "Ctrl",
  #   'Treat' => "Treat",
  # },
  # #you can also define group directly
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
});

my $config = performSmallRNA($def, 1);

1;
