#!/usr/bin/env python3 

from argparse import ArgumentParser
from Bio import SeqIO
from pathlib import Path



def parse_options():
	parser = ArgumentParser(description = 'nanopore statistics')
	parser.add_argument('-otu', '--otu_seqs', required = True, help = 'path to otus FASTA file')
	parser.add_argument('-bclu', '--barcode_clusters', required = True, help = 'path to barcode clusters folder')
	parser.add_argument('-fclu', '--final_clusters', required = True, help = 'path to clusters')
	parser.add_argument('-b', '--barcode', required = True, help = 'barcode number')
	parser.add_argument('-o', '--output', required = True, help = 'name of output file')
	return parser.parse_args()


def listing_otus(otus):
	otu_id_list = []
	for otu in SeqIO.parse(otus, 'fasta'):
		otu_id_list.append(otu.id)
	return otu_id_list


def prep_final_clusters(final_clusters, otus):
	files = Path(final_clusters).glob('*')
	id_clust_list = {}
	for file in files:
		key = str(file).split('/')[1]
		seq_clust_list = []
		for seq in SeqIO.parse(file, 'fasta'):
			seq_clust_list.append(seq.id)
		id_clust_list[key] = seq_clust_list

	new_clust_dict = {}
	for k,v in id_clust_list.items():
		for s in otus:
			if s in v:
				new_clust_dict[s] = v

	new_bar_dict = {}
	for k,v in new_clust_dict.items():
		val_dict = {}
		for name in v:
			bar_name = '_'.join(name.split('_')[2:5])
			if bar_name not in val_dict.keys():
				val_dict[bar_name] = [name]  
			else:
				val_dict[bar_name].append(name) 
		new_bar_dict[k] = val_dict
	return new_bar_dict


def prep_error_clusters(error_clusters):
	folder = Path(error_clusters).glob('*')
	seq_list = {}
	for file in folder:
		i_list = []
		seq_in_clust = {}
		for seq in SeqIO.parse(file, 'fasta'):
			i_list.append(seq.id)
		seq_in_clust[len(i_list)] = i_list
		seq_list[str(file).split('/')[6]] = seq_in_clust
	return seq_list


def abundance(fclust_obj, bar, eclust_obj):	
	out_list = []
	for k,v1 in fclust_obj.items():
		for b,v2 in v1.items():
			if b == bar.split('/')[4]:
				sum_ab = 0
				for i in v2:
					for c,a in eclust_obj.items():
						for n,s in a.items():
							if '_'.join(i.split('_')[0:2]) in s:
								sum_ab += n							
				r = [k, sum_ab]
				out_list.append(r)
	return out_list


def saving_output(final_file, output_file):
	with open(output_file, 'w') as output:
		for line in final_file:
			body = line[0] + '\t' + str(line[1]) + '\n'
			output.write(body)



def main():
	options = parse_options()
	list_of_otu_ids = listing_otus(options.otu_seqs)
	final_clusters_obj = prep_final_clusters(options.final_clusters, list_of_otu_ids)
	error_clusters_obj = prep_error_clusters(options.barcode_clusters)
	final_abundance = abundance(final_clusters_obj, options.barcode, error_clusters_obj)
	saving = saving_output(final_abundance, options.output)

	

if __name__ == '__main__':
	main()




	






