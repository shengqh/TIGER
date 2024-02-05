TIGER: Tools for Intensive Genome alignment of Extracellular small RNA
==
* [Introduction](#Introduction)
* [Installation](#Installation)
* [Example](#Example)

<a name="Introduction"/>

# Introduction

Recent advances in high-throughput small RNA (sRNA) sequencing and the ever expanding transcriptome have opened incredible opportunities to better understand sRNA gene regulation and the biological roles of extracellular sRNAs. Although the field of extracellular RNA is rapidly emerging, there is a great need for better informatics tools to analyze sRNA sequencing (sRNAseq) datasets. Extracellular small RNAs (sRNA) are transported in circulation by lipoproteins, namely low-density lipoproteins (LDL) and high-density lipoproteins (HDL). These sRNAs include microRNAs (miRNA), tRNA-derived sRNAs (tDR), sRNAs-derived from small nuclear RNAs (sndRNA), sRNAs-derived ribosomal RNAs (rDR) and many other classes. To fully characterize lipoprotein sRNA transport and define their link to hepatic and biliary sRNA signatures, high-throughput sRNAseq was used to profile the entire sRNA transcriptome of in apolipoprotein B-containing lipoproteins (apoB), HDL, bile, and liver. To analyze these large lipoprotein datasets, improvements to existing data analysis pipelines were required. To address these analysis issues, we developed a novel sRNAseq data analysis pipeline optimized for extracellular sRNA entitled, "Tools for Intensive Genome alignment of Extracellular small RNA (TIGER)". This pipeline has several advantages over existing data analysis pipelines, including microRNA variant analyses, non-host genome alignments for microbiome and soil bacteria, data visualization packages and quantitative tools for tRNA-derived sRNAs (tDR), and optimization for lipoprotein extracellular sRNAs. Using TIGER, we were able to make critical discoveries in lipoprotein and biliary sRNA changes that would not be quantified by existing pipelines.

<a name="Installation"/>

# Installation

## perl 5+

The TIGER framework is developed using object oriented perl: (http://dev.perl.org/perl5/). 

I added following code into my .bashrc to let perl install the packages into my own folder /home/shengq2/perl5

```
export PERL_MB_OPT="--install_base /home/shengq2/perl5"
export PERL_MM_OPT="INSTALL_BASE=/home/shengq2/perl5"
```

You also need to download ngsperl package from github server. I downloaded it into my folder /home/shengq2/program

```
cd /home/shengq2/program
git clone https://github.com/shengqh/ngsperl.git
cd ngsperl
bash install_packages_nosudo.sh
```

Please remember to add the folders to perl path in your .bashrc file, for example
```
export PERL5LIB=/home/shengq2/program/ngsperl/lib:/home/shengq2/perl5/lib/perl5:$PERL5LIB
```

## Singularity

For all other software used in pipeline, you will need to use singularity image.

```
singularity build cqs-smallRNA.simg docker://shengqh/bioinfo:cqs-smallRNA
singularity build report.sif docker://shengqh/report
```

## database

You need to download the required databases using script [download_tigerdb_v2022.sh](download_tigerdb_v2022.sh):

```bash
wget https://cqsweb.app.vumc.org/download1/annotateGenome/TIGER/20220406_spcount.tar.gz
tar -xzvf 20220406_spcount.tar.gz

wget https://cqsweb.app.vumc.org/download1/annotateGenome/TIGER/TIGER.v202211.tar.gz
tar -xzvf TIGER.v202211.tar.gz

wget https://cqsweb.app.vumc.org/download1/annotateGenome/TIGER/20170206_Group1.tar.gz
tar -xzvf 20170206_Group1.tar.gz

wget https://cqsweb.app.vumc.org/download1/annotateGenome/TIGER/20160907_Group2.tar.gz
tar -xzvf 20160907_Group2.tar.gz

wget https://cqsweb.app.vumc.org/download1/annotateGenome/TIGER/20160225_Group4.tar.gz
tar -xzvf 20160225_Group4.tar.gz

wget https://cqsweb.app.vumc.org/download1/annotateGenome/TIGER/20200305_viral_genomes.tar.gz
tar -xzvf 20200305_viral_genomes.tar.gz

wget https://cqsweb.app.vumc.org/download1/annotateGenome/TIGER/20200214_AlgaeSpeciesAll.tar.gz
tar -xzvf 20200214_AlgaeSpeciesAll.tar.gz

wget https://cqsweb.app.vumc.org/download1/annotateGenome/TIGER/20200130_mm10_miRBase22_GtRNAdb2_gencode24.tar.gz
tar -xzvf 20200130_mm10_miRBase22_GtRNAdb2_gencode24.tar.gz

wget https://cqsweb.app.vumc.org/download1/annotateGenome/TIGER/20200130_rn6_miRBase22_GtRNAdb2_ensembl99.tar.gz
tar -xzvf 20200130_rn6_miRBase22_GtRNAdb2_ensembl99.tar.gz

rm *.tar.gz
```

## example data

You can download an example data using script [download_example_data.sh](download_example_data.sh):

```bash
for i in {1..6}; do
  wget https://cqsweb.app.vumc.org/download1/annotateGenome/TIGER/smallrna_data/S${i}_R1_001.fastq.gz
done
```

<a name="Example"/>

# Example

There is a configuration template file [tiger.pl](tiger.pl). 

Download the file and update the smallrna_db, example_folder, singularity_image and binding_folder in the file based on your enviroment.

When you have a new project, you may copy this template file to your project folder and modify the files, groups and pairs definition. Then you need to run following command to generate the folders and scripts.

```perl
perl tiger.pl
```

Once you generate the folder and scripts, go to the sequencetask/pbs folder. There are two choices you can run the project:
* Run the \_pipeline_st.pbs which will run all tasks in pipeline sequentially. 

```bash
bash XXXXX_pipeline_st.pbs
```

* Run the \_pipeline_st.pbs.submit to submit all jobs to cluster with dependency.

```bash
bash XXXXX_pipeline_st.pbs.submit
```
