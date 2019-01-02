import sys
import os
import logging
import argparse
import re

DEBUG = True

if DEBUG:
  inputFile="/scratch/cqs/references/mirbase/v22/mature.fa"
  outputFile="/scratch/cqs/references/mirbase/v22/mature.dna.fa"
else:
  parser = argparse.ArgumentParser(description="Convert rna to dna fasta",
                                   formatter_class=argparse.ArgumentDefaultsHelpFormatter)

  parser.add_argument('-i', '--input', action='store', nargs='?', help='Input rna fasta file')
  parser.add_argument('-o', '--output', action='store', nargs='?', help="Output dna fasta file")

  args = parser.parse_args()
  
  print(args)
  
  inputFile=args.input
  outputFile=args.output

logger = logging.getLogger('rna2dna')
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)-8s - %(message)s')

with open(outputFile, "w") as sw:
  with open(inputFile, "r") as sr:
    for line in sr:
      if '>' in line:
        sw.write(line)
      else:
        sw.write(line.replace("U", "T"))
 
logger.info("Result has been saved to %s" % outputFile)
