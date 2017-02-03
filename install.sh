#!/bin/bash

NORMAL="\\033[0;39m"
RED="\\033[0;31m"
BLUE="\\033[0;34m"
CURDIR=`pwd`
BASEDIR=$(dirname $0)

if [ -s add_to.bashrc ]; then
  rm add_to.bashrc
fi

die() {
    echo -e "$RED""Exit - ""$*""$NORMAL" 1>&2
    exit 1
}

echo -e "$RED""Make sure internet connection works for your shell prompt under current user's privilege ...""$NORMAL";
echo -e "Starting TIGER installation ...";

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
    echo -e "$RED""Can not proceed without git, please install and re-run\n""$NORMAL"
    exit 1;
fi

# python
which python > /dev/null;
if [ $? != "0" ]; then
    echo -e "$RED""Can not proceed without Python, please install and re-run\n""$NORMAL"
    exit 1;
fi

which pip > /dev/null;
if [ $? != "0" ]; then
    echo -e "$RED""Can not proceed without pip, please make sure your python version >= 2.7.12, or please install and re-run""$NORMAL"
    exit 1;
fi

# R
which R > /dev/null;
if [ $? != "0" ]; then
    echo -e "$RED""Can not proceed without R, please install and re-run\n""$NORMAL"
    exit 1;
fi
check=`R --version|grep "R version 3"`;
if [ $? != "0" ]; then
    check=`R --version|grep "R version"`;
    echo -e "$RED""R version 3 is required, current is: $check \n""$NORMAL"
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

PREFIX_BIN=${CURDIR}/bin;
if [ ! -d $PREFIX_BIN ]; then
    mkdir $PREFIX_BIN || die "Cannot create  $PREFIX_BIN folder. Maybe missing super-user (root) permissions"
fi
if [ ! -w $PREFIX_BIN ]; then
    die "Cannot write to directory $PREFIX_BIN. Maybe missing super-user (root) permissions to write there.";
fi
export PATH=$PREFIX_BIN:$PATH
echo "export PATH=$PREFIX_BIN:\$PATH" >> add_to.bashrc

if [ -z "$PYTHONUSERBASE" ]; then
    export PYTHONUSERBASE=${CURDIR}/pylib
    pyver=`python -c 'import sys; print(".".join(map(str, sys.version_info[:2])))'`
    export PYTHONPATH=$PYTHONUSERBASE/lib/python${pyver}:$PYTHONPATH
    export PATH=$PYTHONUSERBASE/bin:$PATH
    echo "export PYTHONPATH=$PYTHONUSERBASE/lib/python${pyver}:$PYTHONPATH" >> add_to.bashrc
    echo "export PATH=$PYTHONUSERBASE/bin:$PATH" >> add_to.bashrc
fi

echo;
echo  "Checking dependencies ... "
################ Bowtie ###################

which bowtie > /dev/null;
if [ $? = "0" ]; then
    echo -e "Bowtie Aligner appears to be already installed. "
else
    echo -e "$RED""Would you like to install Bowtie? (y/n) [n] : ""$NORMAL"
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
            echo -e "Bowtie Aligner appears to be installed successfully""$NORMAL"
            rm -rf bowtie-0.12.9*
        else
            echo -e "$RED""Bowtie Aligner NOT installed successfully.\n""$NORMAL"; exit 1;
        fi
    fi
fi

################ Cutadapt ###################
which cutadapt > /dev/null;
if [ $? = "0" ]; then
    echo -e "Cutadapt appears to be already installed.\n "
else
    if [ -z "$PYTHONUSERBASE" ]; then
        export PYTHONUSERBASE=${CURDIR}/pylib
        pyver=`python -c 'import sys; print(".".join(map(str, sys.version_info[:2])))'`
        export PYTHONPATH=$PYTHONUSERBASE/lib:$PYTHONPATH
        export PATH=$PYTHONUSERBASE/bin:$PATH
        echo "export PYTHONPATH=$PYTHONUSERBASE/lib:$PYTHONPATH" >> add_to.bashrc
        echo "export PATH=$PYTHONUSERBASE/bin:$PATH" >> add_to.bashrc
    fi

    echo -e "$RED""Would you like to install Cutadapt? (y/n) [n] : ""$NORMAL"
    read ans
    if [ XX${ans} = XXy ]; then
        pip install cutadapt --user
        which cutadapt > /dev/null;
        if [ $? = "0" ]; then
            echo -e "cutadapt appears to be installed successfully""$NORMAL"
        else
            echo -e "$RED""cutadapt NOT installed successfully.""$NORMAL"; exit 1;
        fi
    fi
fi

################ Samtools ###################
which samtools > /dev/null;
if [ $? = "0" ]; then
    echo -e "samtools appears to be already installed. "
else
    echo -e "$RED""Would you like to install samtools? (y/n) [n] : ""$NORMAL"
    read ans
    if [ XX${ans} = XXy ]; then
        $get samtools-1.3.1.tar.bz2 https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2
        tar -xjvf samtools-1.3.1.tar.bz2
        cd samtools-1.3.1
        ./configure --prefix=${CURDIR}
        make
        make install
        cd ..
        which samtools > /dev/null;
        if [ $? = "0" ]; then
            echo -e "samtools appears to be installed successfully""$NORMAL"
        else
            echo -e "$RED""samtools NOT installed successfully.""$NORMAL"; exit 1;
        fi
    fi
fi

################ FastQC ###################
which fastqc > /dev/null;
if [ $? = "0" ]; then
    echo -e "fastqc appears to be already installed. "
else
    echo -e "$RED""Would you like to install fastqc? (y/n) [n] : ""$NORMAL"
    read ans
    if [ XX${ans} = XXy ]; then
        $get fastqc_v0.11.5.zip http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip
        unzip fastqc_v0.11.5.zip
        chmod 755 FastQC/fastqc
        mv FastQC $PREFIX_BIN
        export PATH=$PREFIX_BIN/FastQC:$PATH
        echo "export PATH=$PREFIX_BIN/FastQC:$PATH" >> add_to.bashrc
        which fastqc > /dev/null;
        if [ $? = "0" ]; then
            echo -e "fastqc appears to be installed successfully""$NORMAL"
        else
            echo -e "$RED""fastqc NOT installed successfully.""$NORMAL"; exit 1;
        fi
    fi
fi

################ R ###################
echo "Installing R packages to default library ..."
R CMD BATCH ${BASEDIR}/install_packages.r > install_packages.r.Rout
check=`grep "is not writable" install_packages.r.Rout`;
if [ $? = "0" ]; then
    PREFIX_R_LIBS="${CURDIR}/R_libs"
    if [ ! -d $PREFIX_R_LIBS ]; then
        mkdir $PREFIX_R_LIBS || die "Cannot create  $PREFIX_R_LIBS folder. Maybe missing super-user (root) permissions"
    fi
    if [ ! -w $PREFIX_R_LIBS ]; then
        die "Cannot write to directory $PREFIX_R_LIBS. Maybe missing super-user (root) permissions to write there.";
    fi
    export R_LIBS=${PREFIX_R_LIBS}
    echo "export R_LIBS=${PREFIX_R_LIBS}" >> add_to.bashrc
    echo "Installing R packages to $PREFIX_R_LIBS ..."
    R CMD BATCH ${BASEDIR}/install_packages.r > install_packages.r.Rout
fi
check=`grep proc.time install_packages.r.Rout`;
if [ $? = "0" ]; then
    echo -e "R/BioConductor packages appear to be installed successfully"
else
    echo -e "$RED""R/BioConductor packages NOT installed successfully. Look at the install_packages.r.Rout for additional informations""$NORMAL"; exit 1;
fi

 ###################
echo "Installing ngsperl package ..."
git clone https://github.com/shengqh/ngsperl.git


