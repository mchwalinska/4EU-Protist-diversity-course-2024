# 4EU+ Protist diversity course 2024

This is a step-by-step instruction for the bioinformatic part of the course. 


<!--- TOC START -->
Table of Contents
-----------------
- [Day-1-From-Reads-to-Taxa](#Day-1)
  - [Introduction](#Introduction)
  - [Illumina](#Illumina)
  - [Nanopore](#Nanopore)
- [Day-2-From-Taxa-to-Diversity](#Day-2)
<!--- TOC END -->




## DAY 1 - From Reads to Taxa


### Introduction

Introduction about conda and qiime.



### Illumina


#### 1. Downloading scripts and preparing working environment

First download repository to your computer, unzip and then upload folder `scripts` to your home folder on the server using the command below.

```
scp -r scripts student14@anthriscus:~
``` 

In the next step create two folders and enter the folder `illumina` for the first part of the analysis:

```
mkdir illumina
mkdir nanopore
cd illumina
```

<details>
  <summary>Your home folder should look like this </summary>

  ![Description of the image](imgs/folders.png)
</details> 


#### 2. Raw reads quality check

First check reads quality using [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/).

```
for folder in *; do fastqc "$folder"/*.fastq; done
```

Download `.html` file on your computer and open it in browser.
***Is the quality good or bad? What else did you notice?***


#### 3. Activating QIIME 2 environment

Now you will start working in QIIME 2 environment.

```
conda activate qiime2
```


#### 4. Importing data $${\color{red} zależy \space od \space formatu \space danych }$$

First step is to import your `.fastq` files to special `.qza` artefact file.

```
qiime tools import --type MultiplexedPairedEndBarcodeInSequence --input-path ../../4UProtistDiversity/raw_illumina/ --output-path multiplexed-seqs.qza
qiime tools import --type "SampleData[PairedEndSequencesWithQuality]" --input-format PairedEndFastqManifestPhred33V2 --input-path ./manifest.tsv --output-path ./demultiplexed-seqs.qza
```

#### 5. Primer trimming $${\color{red} czy \space osobno \space usuwać \space adaptery? }$$

To cut primers you will use [Cutadapt](https://cutadapt.readthedocs.io/en/stable/) plugin.

```
qiime cutadapt trim-paired --i-demultiplexed-sequences ./demultiplexed-seqs.qza --p-cores 4 --p-front-f CCAGCASCYGCGGTAATTCC --p-front-r ACTTTCGTTCTTGATYRA --o-trimmed-sequences trimmed_demux.qza
```

#### 6. Visualisation of trimming data quality

In this step you will create QIIME 2 artifact `.qzv` which allows data visualisation. 

```
qiime demux summarize --i-data trimmed_demux.qza --o-visualization trimmed_demux.qzv
```

Download `trimmed_demux.qzv` on you computer and upload the file on the [QIIME2View](https://view.qiime2.org) website.
***Investigate both tabs***.


#### 7. Quality filtering, denoising, merging and chimera removal $${\color{red} cay \space dawać \space im \space progi \space cięcia \space od \space razu? }$$

You will use [DADA2](https://benjjneb.github.io/dada2/) software to create Amplicon Sequence Variants (ASVs).

This step inculdes lenght trimming. ***How much would you trim forward and reverse reads, to find balance between quality and merging?*** Use `trimmed_demux.qzv` quality plots as a clue.

```
qiime dada2 denoise-paired --p-n-threads 8 --i-demultiplexed-seqs trimmed_demux.qza --p-trunc-len-f ? --p-trunc-len-r ?  --output-dir dada2
```

<details>
  <summary>Suggested command</summary>
  
  ```
  qiime dada2 denoise-paired --p-n-threads 8 --i-demultiplexed-seqs trimmed_demux.qza --p-trunc-len-f 205 --p-trunc-len-r 200  --output-dir dada2
  ```
</details> 


#### 8. Visualisation of DADA2 outputs

Create `.qzv` for all the outputs.

```
qiime metadata tabulate --m-input-file dada2/denoising_stats.qza --o-visualization denoising_stats.qzv
qiime feature-table summarize --i-table dada2/table.qza --o-visualization table.qzv
qiime feature-table tabulate-seqs --i-data dada2/representative_sequences.qza --o-visualization representative_sequences.qzv
```

Again upload files on [QIIME2View](https://view.qiime2.org) website and ivestigate them.
***What % of your reads merged successfully?***


#### 9. Exporting files

To assign taxonomy and for futher diversity analysis you need to download two files: `ASV table` and `representative sequences` (your ASVs).

OTU table needs to exported using QIIME2:

```
qiime tools export --input-path dada2/table.qza --output-path exported
biom convert --to-tsv -i exported/feature-table.biom -o exported/feature-table.tsv
```

Download `feature-table.tsv` to your computer.

Download sequences from `representative_sequences.qzv` file and upload them to your working directory on the server (folder `illumina`).

<details>
  <summary>Help here</summary>

  ![Description of the image](imgs/rep_seq.png)
</details>


#### 10. Taxonomic annotation

You will assign taxonomy using [VSEARCH](https://github.com/torognes/vsearch) software, which uses global alignment method. For reference you will use [PR2](https://pr2-database.org) database.

```
vsearch --usearch_global sequences.fasta --db /mnt/databases/pr2_db/pr2_database-5.0.0.fasta --blast6out taxonomy.tsv --id 0.70
```

***Which other databases and methods of assigning taxonomy do you know?***


#### 11. Modifying outputs

Open downloaded `feature-table.tsv` in Excel, remove first raw and save changes.

<details>
  <summary>Help here</summary>

  ![Description of the image](imgs/table.png)
</details>

***What this file shows us?***


Using Python script you will modify `taxonomy.tsv`

```
../scripts/modify_taxonomy_illumina.py -i taxonomy.tsv -o taxonomy_table.tsv
```

Download taxonomy_table.tsv to your computer and open in Excel.
***Which taxa are most abundant in your samples?***


#### !!! <ins>FINAL OUTCOMES</ins> !!!

Congratulations! You've just finished the first part of today's data analysis!
As a final outputs you obtained:
* `feature-table.tsv` - table of ASVs abundances
* `taxonomy_table.tsv` - table of taxonomy for each ASV





### Nanopore $${\color{red} cały \space do \space sprawdzenia}$$

Copy raw data to your current location (folder illumina):

```
cp ../../4UProtistDiversity/raw_illumina/* .
```

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


## DAY 2 - From Taxa to Diversity



