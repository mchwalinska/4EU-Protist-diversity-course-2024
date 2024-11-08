# 4EU+ Protist diversity course 2024

This is a step-by-step instruction for the bioinformatic part of the course. 


<!--- TOC START -->
Table of Contents
-----------------
- [Illumina](#Illumina)
- [Nanopore](#Nanopore)
<!--- TOC END -->


## Illumina


#### 1. Activating QIIME2 environment

```
conda activate qiime2
```

#### 2. Raw reads quality check

```
fastqc *.fastq
```
  
#### 3. Importing data $${\color{red} zależy \space od \space formatu \space danych }$$
```
qiime tools import --type MultiplexedPairedEndBarcodeInSequence --input-path ./raw/ --output-path multiplexed-seqs.qza
qiime tools import --type "SampleData[PairedEndSequencesWithQuality]" --input-format PairedEndFastqManifestPhred33V2 --input-path ./manifest.tsv --output-path ./demultiplexed-seqs.qza
```

#### 4. Primer trimming $${\color{red} czy \space osobno \space usuwać \space adaptery? }$$

```
qiime cutadapt trim-paired --i-demultiplexed-sequences ./demultiplexed-seqs.qza --p-cores 8 --p-front-f CCAGCASCYGCGGTAATTCC --p-front-r ACTTTCGTTCTTGATYRA --o-trimmed-sequences trimmed_demux.qza
```

#### 5. Visualisation of trimming data quality

```
qiime demux summarize --i-data trimmed_demux.qza --o-visualization trimmed_demux.qzv
```

#### 6. DADA2 $${\color{red} cay \space dawać \space im \space progi \space cięcia \space od \space razu? }$$

```
qiime dada2 denoise-paired --p-n-threads 8 --i-demultiplexed-seqs trimmed_demux.qza --p-trunc-len-f 205 --p-trunc-len-r 200  --output-dir dada2
```

#### 7. Visualisation of DADA2 outputs

```
qiime metadata tabulate --m-input-file denoising_stats.qza --o-visualization denoising_stats.qzv
qiime feature-table summarize --i-table table.qza --o-visualization table.qzv
qiime feature-table tabulate-seqs --i-data representative_sequences.qza --o-visualization representative_sequences.qzv
```

#### 8. Exporting files

Our representative sequences download from representative_sequences.qzv

OTU table needs to exported using qiime
```
qiime tools export --input-path table.qza --output-path exported
biom convert --to-tsv -i feature-table.biom -o feature-table.tsv
```

#### 9. Taxonomic annotation

```
vsearch --usearch_global dada2/rep_seqs.fasta --db ../../pr2_database-5.0.0.fasta --blast6out taxonomy.txt --id 0.70
```

#### 10. Formating output

```
python3 ../formate_vsearch_output.py -i taxonomy.txt
```


## Nanopore

#### 1. Quality check
#### 2. Length and quality filtering
#### 3. Comparing quality after filtering
#### 4. Extracting 18S
#### 5. Getting quality from nanoplot
#### 6. Clustering
#### 7. Polishing
#### 8. Add bar
#### 9. Chimeras removal
#### 10. Final clustering
#### 11. Abundance calculations
#### 12. Taxonomic annotation
