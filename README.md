TIGER: Tools for Intensive Genome alignment of Extracellular small RNA
==
* [Introduction](#Introduction)
* [Prerequisites](#Prerequisites)
* [Installation](#Installation)
* [Changes](#changes)

<a name="Introduction"/>

# Introduction

Recent advances in high-throughput small RNA (sRNA) sequencing and the ever expanding transcriptome have opened incredible opportunities to better understand sRNA gene regulation and the biological roles of extracellular sRNAs. Although the field of extracellular RNA is rapidly emerging, there is a great need for better informatics tools to analyze sRNA sequencing (sRNAseq) datasets. Extracellular small RNAs (sRNA) are transported in circulation by lipoproteins, namely low-density lipoproteins (LDL) and high-density lipoproteins (HDL). These sRNAs include microRNAs (miRNA), tRNA-derived sRNAs (tDR), sRNAs-derived from small nuclear RNAs (sndRNA), sRNAs-derived ribosomal RNAs (rDR) and many other classes. To fully characterize lipoprotein sRNA transport and define their link to hepatic and biliary sRNA signatures, high-throughput sRNAseq was used to profile the entire sRNA transcriptome of in apolipoprotein B-containing lipoproteins (apoB), HDL, bile, and liver. To analyze these large lipoprotein datasets, improvements to existing data analysis pipelines were required. To address these analysis issues, we developed a novel sRNAseq data analysis pipeline optimized for extracellular sRNA entitled, “Tools for Intensive Genome alignment of Extracellular small RNA (TIGER).” This pipeline has several advantages over existing data analysis pipelines, including microRNA variant analyses, non-host genome alignments for microbiome and soil bacteria, data visualization packages and quantitative tools for tRNA-derived sRNAs (tDR), and optimization for lipoprotein extracellular sRNAs. Using TIGER, we were able to make critical discoveries in lipoprotein and biliary sRNA changes that would not be quantified by existing pipelines.

<a name="Prerequisites"/>

# Prerequisites

## perl 5+

The TIGER framework is developed using object oriented perl: (http://dev.perl.org/perl5/). Following perl packages are required:

```
curl -L http://cpanmin.us | perl - File::Basename;
curl -L http://cpanmin.us | perl - Getopt::Long;
curl -L http://cpanmin.us | perl - Bio::SeqIO;
```

I use following code to let perl install the packages into my own folder /home/shengq2/perl5

```
export PERL_MB_OPT="--install_base /home/shengq2/perl5"
export PERL_MM_OPT="INSTALL_BASE=/home/shengq2/perl5"
```

You also need to install ngsperl package from github server. I will install it to my folder /scratch/cqs/shengq2/packages

```
cd /scratch/cqs/shengq2/packages
git clone https://github.com/shengqh/ngsperl.git

```

Please remember to add the folder directories to perl path in your .bashrc file.
```
export PERL5LIB=/scratch/cqs/shengq2/packages/ngsperl/lib:/home/shengq2/perl5/lib/perl5:$PERL5LIB
```

## python 2.7+

A few softwares require the python environment, such as cutadapt. You may install the packages to default folder:

```
pip install operator
pip install Bio.Seq
pip install pysam
pip install xml.etree.ElementTree
pip install cutadapt
```

Or you can install packages into your own folder if you don't have root permission. Here, I install the packages into my own python library folder "/scratch/cqs/shengq2/pythonlib", please replace it with your own folder.

```
pip install --install-option="--prefix=/scratch/cqs/shengq2/pythonlib" operator
pip install --install-option="--prefix=/scratch/cqs/shengq2/pythonlib" Bio.Seq
pip install --install-option="--prefix=/scratch/cqs/shengq2/pythonlib" pysam
pip install --install-option="--prefix=/scratch/cqs/shengq2/pythonlib" xml.etree.ElementTree
```

Also, remember to add the folder directory to python path in your .bashrc file.

```
export PYTHONPATH=/scratch/cqs/shengq2/pythonlib/lib/python2.7/site-packages:$PYTHONPATH
export PATH=/scratch/cqs/shengq2/pythonlib/bin:$PATH
```

## mono 4+

Although one essential software cqstools in TIGER is developed by C#, it is majorly executed under linux through [mono] (https://github.com/mono/mono). So mono on your linux system is required for cqstools.
For people who doesn't have root permission to install mono, you may install mono into your own directory (mine is /scratch/cqs/shengq2/mono4):

```
wget https://github.com/mono/mono/archive/mono-4.4.0.40.tar.gz
tar -xzvf mono-4.4.0.40.tar.gz
cd mono-mono-4.4.0.40
#here, I will install mono to my own directory /scratch/cqs/shengq2/mono4, change it to your directory
./autogen.sh --prefix=/scratch/cqs/shengq2/mono4 --with-large-heap=yes --with-ikvm-native=no --disable-shared-memory --enable-big-arrays
make get-monolite-latest
make EXTERNAL_MCS=${PWD}/mcs/class/lib/monolite/basic.exe
make install
```

Remember to add the bin directory of that installed directory into your path enviroment:

```
export PATH=/scratch/cqs/shengq2/mono4/bin:$PATH
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
VER=0.11.5
wget fastqc_v${VER}.zip http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v${VER}.zip
unzip fastqc_v${VER}.zip
if [ -s FastQC ]; then
  rm fastqc_v${VER}.zip
  chmod 755 FastQC/fastqc
fi
```

### cutadapt (https://cutadapt.readthedocs.io/en/stable/)

cutadapt will be used for adapter trimming. You can install cutadapt by:

```
pip install cutadapt
```

or

```
pip install --install-option="--prefix=/scratch/cqs/shengq2/pythonlib" cutadapt
```

### bowtie (http://bowtie-bio.sourceforge.net/index.shtml)

bowtie will be used to map read to host genome, non-host library and non-host genome. Following commands install bowtie into folder $TARGET_BIN ($TARGET_BIN should be in your path):

```
VER=0.12.9
TARGET_BIN=/scratch/cqs/shengq2/local/bin
wget http://sourceforge.net/projects/bowtie-bio/files/bowtie/${VER}/bowtie-${VER}-src.zip
unzip bowtie-${VER}-src.zip
if [ -s bowtie-${VER} ]; then
  rm bowtie-${VER}-src.zip
  cd bowtie-${VER}
  make
  if [ -s bowtie ]; then
    cp bowtie bowtie-build bowtie-inspect $TARGET_BIN
  fi
fi

```

### cqstools (https://github.com/shengqh/CQS.Tools)

cqstools will be used in preprocessing the reads, counting mapping result and summerizing table. You can install it as following. You will use absolute path of cqstools.exe in your configuration file.

```
VER=1.7.5
wget https://github.com/shengqh/CQS.Tools/releases/download/v${VER}/cqstools.${VER}.zip
unzip cqstools.${VER}.zip
if [ -s cqstools.${VER} ]; then
  if [ -s cqstools ]; then
    rm cqstools
  fi
  ln -s cqstools.${VER} cqstools
  chmod 755 cqstools/cqstools
  rm cqstools.${VER}.zip
fi
```

### samtools (https://github.com/samtools/samtools)

samtools is widely used in next generation sequencing analysis. You can install it as following.

```
VER=1.3.1
TARGET_BIN=${HOME}/local/bin
wget https://github.com/samtools/samtools/releases/download/${VER}/samtools-${VER}.tar.bz2
tar -xjvf samtools-${VER}.tar.bz2
if [ -s samtools-${VER} ]; then
  rm samtools-${VER}.tar.bz2
  cd samtools-${VER}
  ./configure --prefix=${TARGET_BIN}
  make
  make install
fi
```

<a name="Installation"/>

#Installation

##software

TIGER and required R packages can be installed from github server.

```
git clone https://github.com/shengqh/TIGER.git
cd TIGER
R CMD BATCH install_packages.r
```

## database

### host genome

gencode hg19 genome database is recommended.

### non host library

miRBase for microRNA 

GtRNAdb2 from UCSC for tRNA

rRNA database

### non host genome
