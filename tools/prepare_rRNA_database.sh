cat SILVA_123_LSURef_tax_silva.fasta SILVA_123_SSURef_Nr99_tax_silva.fasta > SILVA_123.fasta
perl remove_duplicate_sequence.pl -i SILVA_123.fasta -o SILVA_123.rmdup.fasta
perl build_rrna_category.pl
perl buildindex.pl -f SILVA_123.rmdup.fasta -b
