TIGER: Tools for Intensive Genome alignment of Extracellular small RNA
==
* [Introduction](#Introduction)
* [Prerequisites](#Prerequisites)
* [Installation](#Installation)
* [Example](#Example)

<a name="Introduction"/>

# Introduction

Recent advances in high-throughput small RNA (sRNA) sequencing and the ever expanding transcriptome have opened incredible opportunities to better understand sRNA gene regulation and the biological roles of extracellular sRNAs. Although the field of extracellular RNA is rapidly emerging, there is a great need for better informatics tools to analyze sRNA sequencing (sRNAseq) datasets. Extracellular small RNAs (sRNA) are transported in circulation by lipoproteins, namely low-density lipoproteins (LDL) and high-density lipoproteins (HDL). These sRNAs include microRNAs (miRNA), tRNA-derived sRNAs (tDR), sRNAs-derived from small nuclear RNAs (sndRNA), sRNAs-derived ribosomal RNAs (rDR) and many other classes. To fully characterize lipoprotein sRNA transport and define their link to hepatic and biliary sRNA signatures, high-throughput sRNAseq was used to profile the entire sRNA transcriptome of in apolipoprotein B-containing lipoproteins (apoB), HDL, bile, and liver. To analyze these large lipoprotein datasets, improvements to existing data analysis pipelines were required. To address these analysis issues, we developed a novel sRNAseq data analysis pipeline optimized for extracellular sRNA entitled, "Tools for Intensive Genome alignment of Extracellular small RNA (TIGER)". This pipeline has several advantages over existing data analysis pipelines, including microRNA variant analyses, non-host genome alignments for microbiome and soil bacteria, data visualization packages and quantitative tools for tRNA-derived sRNAs (tDR), and optimization for lipoprotein extracellular sRNAs. Using TIGER, we were able to make critical discoveries in lipoprotein and biliary sRNA changes that would not be quantified by existing pipelines.

<a name="Prerequisites"/>

# Prerequisites

## perl 5+

The TIGER framework is developed using object oriented perl: (http://dev.perl.org/perl5/). 

I added following code into my .bashrc to let perl install the packages into my own folder /home/shengq2/perl5

```
export PERL_MB_OPT="--install_base /home/shengq2/perl5"
export PERL_MM_OPT="INSTALL_BASE=/home/shengq2/perl5"
```

The following perl packages are required: [install_perllib.sh](install_perllib.sh)

```
curl -L http://cpanmin.us | perl - File::Basename;
curl -L http://cpanmin.us | perl - Getopt::Long;
curl -L http://cpanmin.us | perl - Bio::SeqIO;
```

You also need to install ngsperl package from github server. I installed it into my folder /home/shengq2/program

```
cd /home/shengq2/program
git clone https://github.com/shengqh/ngsperl.git

```

Please remember to add the folders to perl path in your .bashrc file, for example
```
export PERL5LIB=/home/shengq2/program/ngsperl/lib:/home/shengq2/perl5/lib/perl5:$PERL5LIB
```

## python 2.7+

A few softwares require the python environment, such as cutadapt. You may install the required python packages/softwares to default folder:

```
pip install biopython
pip install pysam
pip install cutadapt
```

Or you can install them into your own folder if you don't have root permission. Here, I install the packages into my own python library folder "/scratch/cqs/shengq2/pythonlib", please replace it with your own folder.[install_pythonlib.sh](install_pythonlib.sh)

```
PYTHONLIB="/home/shengq2/python2"
pip install --install-option="--prefix=${PYTHONLIB}" biopython
pip install --install-option="--prefix=${PYTHONLIB}" pysam
pip install --install-option="--prefix=${PYTHONLIB}" cutadapt
```

If you installed the packages/softwares into your own folder, please remember to add the folder directory to python path in your .bashrc file.

```
export PYTHONPATH=/home/shengq2/python2/lib/python2.7/site-packages:$PYTHONPATH
export PATH=/home/shengq2/python2/bin:$PATH
```

## mono 5+

Although one essential software cqstools in TIGER is developed by C#, it is majorly executed under linux through [mono] (https://github.com/mono/mono). So mono on your linux system is required for cqstools.  Both mono4 and mono5 are good for running cqstools. For people who doesn't have root permission to install mono, you may install mono into your own directory (mine is /home/shengq2/mono5). It will take time to install mono since it is a big software package.

```
MONO_HOME="/home/shengq2/mono5"
git clone --recursive https://github.com/mono/mono.git
cd mono
./autogen.sh --prefix=${MONO_HOME} --with-large-heap=yes --with-ikvm-native=no --disable-shared-memory --enable-big-arrays
make get-monolite-latest
make EXTERNAL_MCS=${PWD}/mcs/class/lib/monolite/basic.exe
make install
```

Remember to add the bin directory of that installed directory into your path enviroment:

```
export PATH=/home/shengq2/mono5/bin:$PATH
```

## R 3.2+

A lot of statistical analysis and graph generation is based on R package. R 3.2+ is required to be installed in your system. (https://www.r-project.org/). Also, following libraries are required:

```
install.packages("RColorBrewer", repos='http://cran.us.r-project.org')
install.packages("Rcpp", repos='http://cran.us.r-project.org')
install.packages("VennDiagram", repos='http://cran.us.r-project.org')
install.packages("colorRamps", repos='http://cran.us.r-project.org')
install.packages("cowplot", repos='http://cran.us.r-project.org')
install.packages("dplyr", repos='http://cran.us.r-project.org')
install.packages("ggplot2", repos='http://cran.us.r-project.org')
install.packages("grid", repos='http://cran.us.r-project.org')
install.packages("heatmap3", repos='http://cran.us.r-project.org')
install.packages("lattice", repos='http://cran.us.r-project.org')
install.packages("plyr", repos='http://cran.us.r-project.org')
install.packages("reshape", repos='http://cran.us.r-project.org')
install.packages("reshape2", repos='http://cran.us.r-project.org')
install.packages("scales", repos='http://cran.us.r-project.org')
source("https://bioconductor.org/biocLite.R")
biocLite("DESeq2")
biocLite("edgeR")
biocLite("preprocessCore")
```

## Key software required by TIGER

### fastqc (http://www.bioinformatics.babraham.ac.uk/projects/fastqc/)

fastqc will be used to do quality control at raw read level. It can provide sufficient information for adapter trimming.You can install it as following. Remember to add the FastQC folder to your path.

```
FASTQ_VER=0.11.7
wget fastqc_v${FASTQ_VER}.zip http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v${FASTQ_VER}.zip
unzip fastqc_v${FASTQ_VER}.zip
if [ -s FastQC ]; then
  rm fastqc_v${FASTQ_VER}.zip
  chmod 755 FastQC/fastqc
fi
```

### bowtie (http://bowtie-bio.sourceforge.net/index.shtml)

bowtie will be used to map read to host genome, non-host library and non-host genome. Following commands install bowtie into folder $TARGET_BIN ($TARGET_BIN should be in your path):

```
TARGET_BIN=TARGET_BIN=${HOME}/local/bin
wget bowtie-1.2.2-linux-x86_64.zip https://github.com/BenLangmead/bowtie/releases/download/v1.2.2_p1/bowtie-1.2.2-linux-x86_64.zip
unzip bowtie-1.2.2-linux-x86_64.zip
rm bowtie-1.2.2-linux-x86_64.zip
cp bowtie-1.2.2-linux-x86_64/bowtie* $TARGET_BIN

```

### cqstools (https://github.com/shengqh/CQS.Tools)

cqstools will be used in preprocessing the reads, counting mapping result and summerizing table. You can install it as following. You will use absolute path of cqstools.exe in your configuration file.

```
CQS_VER=1.7.6
wget https://github.com/shengqh/CQS.Tools/releases/download/v${CQS_VER}/cqstools.${CQS_VER}.zip
unzip cqstools.${CQS_VER}.zip
if [ -s cqstools.${CQS_VER} ]; then
  if [ -s cqstools ]; then
    rm cqstools
  fi
  ln -s cqstools.${CQS_VER} cqstools
  chmod 755 cqstools/cqstools
  rm cqstools.${CQS_VER}.zip
fi
```

### samtools (https://github.com/samtools/samtools)

samtools is widely used in next generation sequencing analysis. You can install it as following.

```
SAMTOOLS_VER=1.7
TARGET_BIN=${HOME}/local
wget https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VER}/samtools-${SAMTOOLS_VER}.tar.bz2
tar -xjvf samtools-${SAMTOOLS_VER}.tar.bz2
if [ -s samtools-${SAMTOOLS_VER} ]; then
  rm samtools-${SAMTOOLS_VER}.tar.bz2
  cd samtools-${SAMTOOLS_VER}
  ./configure --prefix=${TARGET_BIN}
  make
  make install
fi
```

<a name="Installation"/>

# Installation

## Software

TIGER can be downloaded from github server.

```
git clone https://github.com/shengqh/TIGER.git
```

## database

You can download the required [databases](download_tigerdb.sh):

```
wget https://cqsweb.app.vumc.org/download1/bowtie_index/mirBase21.tar.gz
tar -xzvf mirBase21.tar.gz
wget https://cqsweb.app.vumc.org/download1/bowtie_index/GtRNAdb2.tar.gz
tar -xzvf GtRNAdb2.tar.gz
wget https://cqsweb.app.vumc.org/download1/bowtie_index/SILVA_128.tar.gz
tar -xzvf SILVA_128.tar.gz
wget https://cqsweb.app.vumc.org/download1/bowtie_index/group1.tar.gz
tar -xzvf group1.tar.gz
wget https://cqsweb.app.vumc.org/download1/bowtie_index/group2.tar.gz
tar -xzvf group2.tar.gz
wget https://cqsweb.app.vumc.org/download1/bowtie_index/group4.tar.gz
tar -xzvf group4.tar.gz
wget https://cqsweb.app.vumc.org/download1/bowtie_index/hg19.tar.gz
tar -xzvf hg19.tar.gz
wget https://cqsweb.app.vumc.org/download1/bowtie_index/hg38.tar.gz
tar -xzvf hg38.tar.gz
wget https://cqsweb.app.vumc.org/download1/bowtie_index/mm10.tar.gz
tar -xzvf mm10.tar.gz
wget https://cqsweb.app.vumc.org/download1/bowtie_index/rn5.tar.gz
tar -xzvf rn5.tar.gz
rm *.tar.gz
```

<a name="Example"/>

# Example

There is an example called [tiger.pl](tiger.pl) in the folder. Update the cqstools link and database locations in the file. When you have a new project, you may copy this template file to your project folder and modify the files, groups and pairs definition. Then you need to run following command to generate the folders and scripts.
```
perl tiger.pl
```
Once you generate the folder and scripts, go to the sequencetask/pbs folder. There are two choices you can run the project:
* Run the \_pipeline_st.pbs which will run all tasks in pipeline sequentially. 
* Run the step_1_st.sh to submit the individual file level tasks to cluster. Those individual tasks are usually time cost. Once all tasks are done, you can run \_pipeline_st.pbs to run all other tasks sequentially.




