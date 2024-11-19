#!/usr/bin/env python3

import os
from Bio import SeqIO

def filter_fasta_files(input_folder, min_sequences=3):
    """
    Filter FASTA files in a folder to only keep those with at least a certain number of sequences.
    Returns a set of sequence IDs from these valid files.
    """
    valid_sequence_ids = set()

    # Loop through files that start with "cluster_"
    for filename in os.listdir(input_folder):
        if filename.startswith("cluster_"):
            fasta_path = os.path.join(input_folder, filename)

            # Read sequences from the file
            sequences = list(SeqIO.parse(fasta_path, "fasta"))

            # Check if the file has at least the specified number of sequences
            if len(sequences) >= min_sequences:
                for record in sequences:
                    valid_sequence_ids.add(record.id)

    return valid_sequence_ids


def filter_main_fasta(main_fasta_path, output_fasta_path, valid_sequence_ids):
    """
    Filter sequences from the main FASTA file based on a set of valid sequence IDs.
    """
    with open(output_fasta_path, "w") as output_handle:
        for record in SeqIO.parse(main_fasta_path, "fasta"):
            if record.id in valid_sequence_ids:
                SeqIO.write(record, output_handle, "fasta")


# Define paths
input_folder = "clusters_error"  # Folder containing multiple FASTA files starting with "cluster_"
main_fasta_file = "centroids_error.fasta"  # Main FASTA file to filter
filtered_fasta_output = "centroids_error_filt.fasta"  # Output for filtered sequences

# Step 1: Filter FASTA files in the folder to get valid sequence IDs
valid_ids = filter_fasta_files(input_folder, min_sequences=3)

# Step 2: Filter the main FASTA file with the valid sequence IDs
filter_main_fasta(main_fasta_file, filtered_fasta_output, valid_ids)

print(f"Filtering completed. Filtered sequences saved to: {filtered_fasta_output}")
