mkdir /scratch/cqs/shengq1/references/smallrna/v3/allnonhost
cd /scratch/cqs/shengq1/references/smallrna/v3/allnonhost
cat /scratch/cqs/zhaos/vickers/reference/bacteria/group1/bowtie_index_1.1.2/bacteriaDatabaseGroup1.fa /scratch/cqs/zhaos/vickers/reference/bacteria/group2/bowtie_index_1.1.2/bacteriaDatabaseGroup2.fa /scratch/cqs/zhaos/vickers/reference/bacteria/group4/bowtie_index_1.1.2/group4.fa /scratch/cqs/shengq1/references/smallrna/v3/GtRNAdb2/bowtie_index_1.1.2/GtRNAdb2.20161214.mature.fa /scratch/cqs/shengq1/references/smallrna/v3/SILVA/bowtie_index_1.1.2/SILVA_128.rmdup.fasta >AllNonHost.fa
cat /scratch/cqs/zhaos/vickers/reference/bacteria/group1/20160907_Group1SpeciesAll.species.map /scratch/cqs/zhaos/vickers/reference/bacteria/group2/20160907_Group2SpeciesAll.species.map /scratch/cqs/zhaos/vickers/reference/bacteria/group4/20160225_Group4SpeciesAll.species.map /scratch/cqs/shengq1/references/smallrna/v3/GtRNAdb2/GtRNAdb2.20161214.category.map /scratch/cqs/shengq1/references/smallrna/v3/SILVA/SILVA_128.rmdup.category.map > AllNonHost.map
perl /home/shengq1/program/tiger/tools/buildindex.pl -f AllNonHost.fa -b 
