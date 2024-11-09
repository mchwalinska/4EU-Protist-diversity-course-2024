# 4EU+ Protist diversity course 2024

This is a step-by-step instruction for the bioinformatic part of the course. 


<!--- TOC START -->
Table of Contents
-----------------
- [Introduction](#Introduction)
- [Illumina](#Illumina)
- [Nanopore](#Nanopore)
<!--- TOC END -->



## Introduction

Introduction about conda and qiime.




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

```
fastqc *.fastq
for file in  *.fastq ; do NanoPlot --fastq $file --tsv_stats --info_in_report -o "np_${file%.*}" ; done
```

#### 2. Length and quality filtering

```
filtlong --min_length 2000 --max_length 6000  --min_mean_q 90 $file > "filtlong_${file%.*}.fastq"
```

#### 3. Comparing quality after filtering

```
fastqc *.fastq
for file in  filtlong_*.fastq ; do NanoPlot --fastq $file --tsv_stats --info_in_report -o "np_${file%.*}" ; done
```

#### 4. Extracting 18S

```
barrnap --kingdom euk --reject 0.1 --outseq "barrnap_${file%.*}.fasta" $file --threads 8
```

#### 5. Getting quality from nanoplot

```
for file in  np_filtlong_* ; do python3 clustering_treshold_calculations.py -s "${file%.*}/NanoStats.txt" -e P_error_table.tsv ; done
```

#### 6. Clustering

```
mkdir "0.${id%.*}_${file%.*}_clusters"
vsearch --cluster_fast $file -id "0.${id%.*}" --clusters "0.${id%.*}_${file%.*}_clusters"/"0.${id%.*}_clust" &>> "out.${file%.*}_0.${id%.*}_clust"
vsearch --cluster_fast nonchim_b_racon_0.8.fasta  -id 0.99 --clusters 99_clusters_80/clust --centroids 99_centroidy_80
```

#### 7. Polishing

```
python3 minimap.py -c consen_0.975_18S_barrnap_filtlong_BAB10_clusters.fasta -cf 0.975_18S_barrnap_filtlong_BAB10_clusters -of minimap_out_BAB10
for folder in minimap_out* ; do cat $folder/* > "${folder%.*}.paf" ; done
racon BAB10_clusters.fasta  -q 20 -w 500  minimap_out_BAB10.paf consen_0.975_18S_barrnap_filtlong_BAB10_clusters.fasta > racon_0.8_BAB10.fasta
```

#### 8. Add bar

```
python3 add_bar_to_id.py -i ../racon_0.8_KRA3.fasta -b KRA3 -o b_racon_0.8_KRA3.fasta
cat b_racon_0.8_* > b_racon_0.8.fasta
```

#### 9. Chimeras removal

```
vsearch --uchime_ref b_racon_0.8.fasta --db /home/users/mchwalinska/nano/pr2_database-5.0.0.fasta --nonchimeras nonchim_b_racon_0.8.fasta --chimeras chim_b_racon_0.8.fasta
```

#### 10. Final clustering

```
vsearch --cluster_fast nonchim_b_racon_0.8.fasta  -id 0.99 --clusters 99_clusters_80/clust --centroids 99_centroidy_80
```

#### 11. Abundance calculations

```
python3 abundance.py -otu 99_centroidy_80 -bclu ../0.975_18S_barrnap_filtlong_KRA3_clusters -fclu 99_clusters_80 -b KRA3 -o 99_centroidy_80_KRA3
```

#### 12. Taxonomic annotation

```
vsearch --usearch_global 99_centroidy_80 --db /home/users/mchwalinska/nano/pr2_database-5.0.0.fasta --id 0.7 --blast6out tax_99_centroidy_80  --query_cov 0.9
```

