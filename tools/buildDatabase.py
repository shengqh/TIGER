import argparse
import statistics
import logging
import os.path

def is_valid_file(parser, arg):
    if not os.path.isfile(arg):
        parser.error("The file %s does not exist!" % arg)
    else:
        return arg  # return an open file handle

parser = argparse.ArgumentParser(description="Build smallRNA host genome database",
                                 formatter_class=argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument('-g', dest="genomeFasta", required=True, metavar="GENOME_FASTA_FILE", type=lambda x: is_valid_file(parser, x), help='Input host genome file in FASTA format')
parser.add_argument('-m', dest="mirbase", required=True, metavar="miRBase_GFF_FILE",help="Input host miRBase file in gff/bed format")
parser.add_argument('--mirbase_key', dest="mirbaseKey", required=True, metavar="STRING",default="miRNA", help="Input miRBase category(miRNA or miRNA_primary_transcript)")
parser.add_argument('-t', dest="tRNA", required=True, metavar="tRNA_BED_FILE",help="Input ucsc host tRNA file in bed format")
parser.add_argument('--trna_mature', required=True, dest="tRNAMatureFasta", metavar="MATURE_tRNA_FASTA_FILE",help="Input ucsc host tRNA mature sequence file in FASTA format")
parser.add_argument('-e', dest="ensemblGTF", required=True, metavar="ENSEMBL_GTF_FILE",help="Input Ensembl host genome annotation file in GTF format")
parser.add_argument('-r', dest="rRNAFasta", required=True, metavar="SILVA_rRNA_FASTA_FILE",help="Input SILVA host rRNA sequence file in FASTA format")
parser.add_argument('-o', dest="outputPrefix", required=True, metavar="OUTPUT_PREFIX",help="Output file prefix")

args = parser.parse_args()

logger = logging.getLogger('calculateDistance')
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)-8s - %(message)s')

print("args=%s" % args)
