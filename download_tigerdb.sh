
mkdir bowtie_index
cd bowtie_index

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

cd ..
mkdir annotation
cd annotation

wget https://cqsweb.app.vumc.org/download1/annotation/hg19_miRBase21_GtRNAdb2_gencode19_ncbi.bed
wget https://cqsweb.app.vumc.org/download1/annotation/hg19_miRBase21_GtRNAdb2_gencode19_ncbi.bed.fa
wget https://cqsweb.app.vumc.org/download1/annotation/hg19_miRBase21_GtRNAdb2_gencode19_ncbi.bed.info

wget https://cqsweb.app.vumc.org/download1/annotation/hg38_miRBase21_GtRNAdb2_gencode25_ncbi.bed
wget https://cqsweb.app.vumc.org/download1/annotation/hg38_miRBase21_GtRNAdb2_gencode25_ncbi.bed.fa
wget https://cqsweb.app.vumc.org/download1/annotation/hg38_miRBase21_GtRNAdb2_gencode25_ncbi.bed.info

wget https://cqsweb.app.vumc.org/download1/annotation/mm10_miRBase21_GtRNAdb2_gencode12_ncbi.bed
wget https://cqsweb.app.vumc.org/download1/annotation/mm10_miRBase21_GtRNAdb2_gencode12_ncbi.bed.fa
wget https://cqsweb.app.vumc.org/download1/annotation/mm10_miRBase21_GtRNAdb2_gencode12_ncbi.bed.info

wget https://cqsweb.app.vumc.org/download1/annotation/rn5_miRBase21_GtRNAdb2_ensembl79_ncbi.bed
wget https://cqsweb.app.vumc.org/download1/annotation/rn5_miRBase21_GtRNAdb2_ensembl79_ncbi.bed.fa
wget https://cqsweb.app.vumc.org/download1/annotation/rn5_miRBase21_GtRNAdb2_ensembl79_ncbi.bed.info

