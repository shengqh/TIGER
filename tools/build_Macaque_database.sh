smallrnaDir=/scratch/cqs/shengq1/references/smallrna/v3
genomeName=rheMac8
targetDir=${smallrnaDir}/${genomeName}

if [ ! -s $targetDir ]; then
  mkdir $targetDir
fi

cd $targetDir

if [ ! -s liftOver ]; then
  wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/liftOver
  chmod 755 liftOver
fi

if [ ! -s rheMac3ToRheMac8.over.chain.gz ]; then
  wget http://hgdownload.cse.ucsc.edu/goldenPath/rheMac3/liftOver/rheMac3ToRheMac8.over.chain.gz
fi

#miRBase
if [ ! -s rheMac8-miRNA.liftOver.bed ]; then
  if [ ! -s mml.mature.bed ]; then
    if [ ! -s mml.gff3 ]; then
      wget ftp://mirbase.org/pub/mirbase/CURRENT/genomes/mml.gff3
    fi

    grep -v primary mml.gff3 | grep -v '#' > mml.mature.gff3
    cqstools gtf2bed -i mml.mature.gff3 -o mml.mature.bed -n
  fi
  ./liftOver mml.mature.bed rheMac3ToRheMac8.over.chain.gz rheMac8-miRNA.liftOver.bed rheMac8-miRNA.unlifted.bed
fi

#GtRNAdb2
if [ ! -s rheMac8-tRNAs.liftOver.bed ]; then
  if [ ! -s rheMac3-tRNAs.bed ]; then
    wget http://gtrnadb.ucsc.edu/GtRNAdb2/genomes/eukaryota/Mmula3/rheMac3-tRNAs.tar.gz
    tar -xzvf rheMac3-tRNAs.tar.gz
    rm rheMac3-tRNAs.tar.gz rheMac3-tRNAs.ss.sort rheMac3-tRNAs.out
  fi
  ./liftOver rheMac3-tRNAs.bed rheMac3ToRheMac8.over.chain.gz rheMac8-tRNAs.liftOver.bed rheMac8-tRNAs.unlifted.bed
fi

#ensembl
if [ ! -s Macaca_mulatta.Mmul_8.0.1.87.gtf ]; then
  wget ftp://ftp.ensembl.org/pub/release-87/gtf/macaca_mulatta/Macaca_mulatta.Mmul_8.0.1.87.gtf.gz
  gunzip Macaca_mulatta.Mmul_8.0.1.87.gtf.gz
fi

#fasta
if [ ! -s Macaca_mulatta.Mmul_8.0.1.dna.toplevel.fa ]; then
  wget ftp://ftp.ensembl.org/pub/release-87/fasta/macaca_mulatta/dna/Macaca_mulatta.Mmul_8.0.1.dna.toplevel.fa.gz
  gunzip Macaca_mulatta.Mmul_8.0.1.dna.toplevel.fa.gz
fi

cd ..

ln -s ${genomeName}/Macaca_mulatta.Mmul_8.0.1.dna.toplevel.fa ${genomeName}.fa

if [ ! -s rheMac8_miRBase21_GtRNAdb2_ensembl87.bed ]; then
  echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<Root>
  <param name=\"miRNAFile\" value=\"${targetDir}/rheMac8-miRNA.liftOver.bed\" />
  <param name=\"miRNAKey\" value=\"miRNA\" />
  <param name=\"tRNAFile\" value=\"${targetDir}/rheMac8-tRNAs.liftOver.bed\" />
  <param name=\"matureTRNAFile\" value=\"\" />
  <param name=\"rRNAFile\" value=\"\" />
  <param name=\"ensemblFile\" value=\"${targetDir}/Macaca_mulatta.Mmul_8.0.1.87.gtf\" />
  <param name=\"fastaFile\" value=\"${targetDir}/Macaca_mulatta.Mmul_8.0.1.dna.toplevel.fa\" />
  <param name=\"outputFile\" value=\"rheMac8_miRBase21_GtRNAdb2_ensembl87.bed\" />
</Root>
" > rheMac8_miRBase21_GtRNAdb2_ensembl87.bed.param
  cqstools smallrna_database -f rheMac8_miRBase21_GtRNAdb2_ensembl87.bed.param
fi

buildindex.pl -f ${genomeName}.fa -b

if [ ! -d Macaca_fascicularis ]; then
  mkdir Macaca_fascicularis
fi

cd Macaca_fascicularis

if [ ! -s Macaca_fascicularis.MacFas_5.0.76.dna.toplevel.fa ]; then
  wget ftp://ftp.ensembl.org/pub/pre/fasta/dna/macaca_fascicularis/Macaca_fascicularis.MacFas_5.0.76.dna.toplevel.fa.gz
  gunzip Macaca_fascicularis.MacFas_5.0.76.dna.toplevel.fa.gz
fi

buildindex.pl -f Macaca_fascicularis.MacFas_5.0.76.dna.toplevel.fa -b