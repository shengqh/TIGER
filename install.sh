#!/bin/bash

NORMAL="\\033[0;39m"
RED="\\033[0;31m"
BLUE="\\033[0;34m"
TEST=`pwd`

die() {
    echo -e "$RED""Exit - ""$*""$NORMAL" 1>&2
    exit 1
}

echo -e "$RED""Make sure internet connection works for your shell prompt under current user's privilege ...""$NORMAL";
echo -e "$BLUE""Starting TIGER installation ...""$NORMAL";

################ Initialize ###################

#check for make
which make > /dev/null;
if [ $? != "0" ]; then
        echo -e "$RED""Can not proceed without make, please install and re-run""$NORMAL"
        exit 1;
fi

#check for g++
which g++ > /dev/null;
if [ $? != "0" ]; then
        echo -e "$RED""Can not proceed without g++, please install and re-run""$NORMAL"
        exit 1;
fi

# check for unzip
which unzip > /dev/null;
if [ $? != "0" ]; then
    echo -e "$RED""Can not proceed without unzip, please install and re-run""$NORMAL"
    exit 1;
fi

# check for zcat
which zcat > /dev/null;
if [ $? != "0" ]; then
    echo -e "$RED""Can not proceed without zcat, please install and re-run""$NORMAL"
    exit 1;
fi

# perl
which perl > /dev/null;
if [ $? != "0" ]; then
    echo -e "$RED""Can not proceed without Perl, please install and re-run""$NORMAL"
    exit 1;
fi

# java
which java > /dev/null;
if [ $? != "0" ]; then
    echo -e "$RED""Can not proceed without Java, please install and re-run""$NORMAL"
    exit 1;
fi

# mono
which mono > /dev/null;
if [ $? != "0" ]; then
    echo -e "$RED""Can not proceed without mono, please install and re-run""$NORMAL"
    exit 1;
fi

# git
which git > /dev/null;
if [ $? != "0" ]; then
    echo -e "$RED""Can not proceed without git, please install and re-run""$NORMAL"
    exit 1;
fi

# python
which python > /dev/null;
if [ $? != "0" ]; then
    echo -e "$RED""Can not proceed without Python, please install and re-run""$NORMAL"
    exit 1;
fi

# pip
which pip > /dev/null;
if [ $? != "0" ]; then
    echo -e "$RED""Can not proceed without pip, please install and re-run""$NORMAL"
    exit 1;
fi

# R
which R > /dev/null;
if [ $? != "0" ]; then
    echo -e "$RED""Can not proceed without R, please install and re-run""$NORMAL"
    exit 1;
fi
check=`R --version|grep "R version 3"`;
if [ $? != "0" ]; then
    echo -n -e "$BLUE""The required R version 3 appear to be installed. ""$NORMAL"
    exit 1;
fi

#check OS (Unix/Linux or Mac)
os=`uname`;

# get the right download program
if [ "$os" = "Darwin" ]; then
        # use curl as the download program
        get="curl -L -o"
else
        # use wget as the download program
        get="wget --no-check-certificate -O"
fi


################ Install dependencies  ###################

PREFIX_BIN=${HOME}/bin;
echo "Where should missing software prerequisites be installed ? [$PREFIX_BIN]\nWrite new directory or press Enter to continue... "
read ans
ans=${ans:-$PREFIX_BIN}
PREFIX_BIN=$ans
if [ ! -d $PREFIX_BIN ]; then
    echo "Directory $PREFIX_BIN does not exist!"
    echo -n "Do you want to create $PREFIX_BIN folder ? (y/n) [n] : "
    read ans
    if [ XX${ans} = XXy ]; then
        mkdir $PREFIX_BIN || die "Cannot create  $PREFIX_BIN folder. Maybe missing super-user (root) permissions"
    else
        die "Must specify a directory to install required softwares!"
    fi
fi

if [ ! -w $PREFIX_BIN ]; then
    die "Cannot write to directory $PREFIX_BIN. Maybe missing super-user (root) permissions to write there.";
fi

export PATH=$PREFIX_BIN:$PATH

echo;
echo  "Checking dependencies ... "

################ R ###################
echo "Installing R packages ...";
R CMD BATCH ../install_packages_check.R > install_packages_check.Rout
check=`grep proc.time install_packages_check.Rout`;
if [ $? = "0" ]; then
    echo -e "$BLUE""R/BioConductor packages appear to be installed successfully""$NORMAL"
else
    echo -e "$RED""R/BioConductor packages NOT installed successfully. Look at the install_packages.Rout for additional informations""$NORMAL"; exit 1;
fi

################ Bowtie ###################

which bowtie > /dev/null;
if [ $? = "0" ]; then
    echo -e -n "$BLUE""Bowtie Aligner appears to be already installed. ""$NORMAL"
else
    echo -n "Would you like to install Bowtie? (y/n) [n] : "
    read ans
    if [ XX${ans} = XXy ]; then
        $get bowtie-0.12.9-src.zip http://sourceforge.net/projects/bowtie-bio/files/bowtie/0.12.9/bowtie-0.12.9-src.zip/download?use_mirror=freefr
        unzip bowtie-0.12.9-src.zip
        cd bowtie-0.12.9
        make
        cp bowtie bowtie-build bowtie-inspect $PREFIX_BIN
        cd ..
        which bowtie > /dev/null;
        if [ $? = "0" ]; then
            echo -e "$BLUE""Bowtie Aligner appears to be installed successfully""$NORMAL"
        else
            echo -e "$RED""Bowtie Aligner NOT installed successfully.""$NORMAL"; exit 1;
        fi
    fi
fi

################ Cutadapt ###################
which cutadapt > /dev/null;
if [ $? = "0" ]; then
    echo -e -n "$BLUE""Cutadapt appears to be already installed. ""$NORMAL"
else
    echo -n "Would you like to install Cutadapt? (y/n) [n] : "
    read ans
    if [ XX${ans} = XXy ]; then
        $get cutadapt-1.12.tar.gz https://pypi.python.org/packages/41/9e/5b673f766dcf2dd787e0e6c9f08c4eea6f344ea8fce824241db93cc2175f/cutadapt-1.12.tar.gz
        tar xvzf cutadapt-1.12.tar.gz
        cd cutadapt-1.12
        python setup.py build
        python setup.py install
        cd ..
        which cutadapt > /dev/null;
        if [ $? = "0" ]; then
            echo -e "$BLUE""cutadapt appears to be installed successfully""$NORMAL"
        else
            echo -e "$RED""cutadapt NOT installed successfully.""$NORMAL"; exit 1;
        fi
    fi
fi

################ Samtools ###################
which samtools > /dev/null;
if [ $? = "0" ]; then
    echo -e -n "$BLUE""samtools appears to be already installed. ""$NORMAL"
else
    echo -n "Would you like to install samtools? (y/n) [n] : "
    read ans
    if [ XX${ans} = XXy ]; then
        $get bowtie-0.12.9-src.zip http://sourceforge.net/projects/bowtie-bio/files/bowtie/0.12.9/bowtie-0.12.9-src.zip/download?use_mirror=freefr
        unzip bowtie-0.12.9-src.zip
        cd bowtie-0.12.9
        make
        cp bowtie bowtie-build bowtie-inspect $PREFIX_BIN
        cd ..
        wasInstalled=0;
    fi
fi

################ FastQC ###################
which fastqc > /dev/null;
if [ $? = "0" ]; then
    echo -e -n "$BLUE""fastqc appears to be already installed. ""$NORMAL"
else
    echo -n "Would you like to install fastqc? (y/n) [n] : "
    read ans
    if [ XX${ans} = XXy ]; then
        $get http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip
        unzip fastqc_v0.11.5.zip
        chmod 755 FastQC/fastqc
        mv FastQC $PREFIX_BIN
        export PATH=$PREFIX_BIN/FastQC:$PATH
    fi
fi
