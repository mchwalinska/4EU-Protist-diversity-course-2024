#!/usr/bin/env python3

from argparse import ArgumentParser
from Bio import SeqIO



def parse_options():
	parser = ArgumentParser(description = 'extracting 18S sequences')
	parser.add_argument('-i', '--input', required = True, help = 'path to input FASTA file')
	parser.add_argument('-o', '--output', required = True, help = 'name of output file')
	return parser.parse_args()


def extracting(file):
	seqs_18S = []
	for seq in SeqIO.parse(file, 'fasta'):
		if seq.id.startswith('18S') and len(seq.seq) > 1000:
			seqs_18S.append(seq)
	return seqs_18S


def saving_output(final_file, output_file):
	with open(output_file, 'w') as output:
   		SeqIO.write(final_file, output, 'fasta')



def main():
	options = parse_options()
	extracted_18S = extracting(options.input)
	saving = saving_output(extracted_18S, options.output)



if __name__ == '__main__':
	main()