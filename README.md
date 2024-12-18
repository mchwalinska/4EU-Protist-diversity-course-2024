# 4EU+ Protist diversity course 2024

This is a step-by-step instruction for the bioinformatic part of the course. 


<!--- TOC START -->
Table of Contents
-----------------
- [Day-1-From-Reads-to-Taxa](#Day-1-From-Reads-to-Taxa)
  - [Introduction](#Introduction)
  - [Illumina](#Illumina)
  - [Nanopore](#Nanopore)
- [Day-2-From-Taxa-to-Diversity](#Day-2-From-Taxa-to-Diversity)
  - [Introduction](#Introduction)
  - [RStudio-and-libraries-installation](#RStudio-and-libraries-installation)
  - [Analysis](#Analysis)
<!--- TOC END -->




## DAY 1 - From Reads to Taxa


### Introduction

On the first day of the data analysis part of the **Practical course on analysing the diversity of microbial eukaryotes** in environments, you'll primarily work in the terminal. You will use bioinformatic software installed in [conda](https://anaconda.org/anaconda/conda) package management system. Certain steps will require you to activate conda environment with the command `conda activate environment_name`. To exit the environment, simply type `conda deactivate`.

To analyse Illumina data you will use the [QIIME2](https://qiime2.org) platform with special plugins.



### Illumina


#### 1. Downloading scripts and preparing the working environment

First, download the repository from GitHub to your computer, unzip and then navigate to the unzipped directory. Next, upload the folder 'scripts' to your home folder on the server using the command below (or another solution that works on your system)

```
scp -r scripts studentX@212.87.6.113:~
```

Make all the Python scripts executable.

```
chmod a+x ./scripts/*.py
```

In the next step create two folders and enter the folder illumina for the first part of the analysis:

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

First, check read quality using [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/). The Illumina sequencing reads from the experiment are available on the server.

```
for file in ../../4UProtistDiversity/raw_illumina/*; do fastqc "$file" -o ./; done
```

Download `.html` files on your computer and open them in the browser.

Please take a look at the command below that you will run using a terminal window on your local machine)

```
scp studentX@212.87.6.113:~/illumina/*.html localdirectory
``` 

***Is the quality good or bad? What else did you notice?***


#### 3. Activating the QIIME 2 environment

Now you will start working in the QIIME 2 environment.

```
conda activate qiime2
```


#### 4. Importing data

The first step is to import your `.fastq` files to a special `.qza` artifacts file. To do that you will use `manifest.tsv` file, which contains locations of the raw reads.

```
qiime tools import --type "SampleData[PairedEndSequencesWithQuality]" --input-format PairedEndFastqManifestPhred33V2 --input-path ../scripts/manifest.tsv --output-path ./demultiplexed-seqs.qza
```

#### 5. Primer trimming

To cut amplification primers you will use the [Cutadapt](https://cutadapt.readthedocs.io/en/stable/) plugin. In this step, you will remove the amplification primers from the file imported in previous step `demultiplexed-seqs.gza`.

```
qiime cutadapt trim-paired --i-demultiplexed-sequences ./demultiplexed-seqs.qza --p-cores 4 --p-front-f CCAGCASCYGCGGTAATTCC --p-front-r ACTTTCGTTCTTGATYRA --o-trimmed-sequences trimmed_demux.qza
```

#### 6. Visualisation of trimmed data quality

In this step, you will create QIIME 2 artifact .qzv which allows data visualisation. 

```
qiime demux summarize --i-data trimmed_demux.qza --o-visualization trimmed_demux.qzv
```

Download `trimmed_demux.qzv` on your computer and upload the file on the [QIIME2View](https://view.qiime2.org) website.

***Investigate both tabs***.


#### 7. Quality filtering, denoising, merging and chimera removal

You will use the [DADA2](https://benjjneb.github.io/dada2/) software to create Amplicon Sequence Variants (ASVs).

This step inculdes length trimming. ***How much would you trim forward and reverse reads, to find balance between quality and merging?*** Use `trimmed_demux.qzv` quality plots as a clue.

```
qiime dada2 denoise-paired --p-n-threads 4 --i-demultiplexed-seqs trimmed_demux.qza --p-trunc-len-f ? --p-trunc-len-r ?  --output-dir dada2
```

<details>
  <summary>Suggested command</summary>
  
  ```
  qiime dada2 denoise-paired --p-n-threads 4 --i-demultiplexed-seqs trimmed_demux.qza --p-trunc-len-f 205 --p-trunc-len-r 200  --output-dir dada2
  ```
</details> 


#### 8. Visualisation of DADA2 outputs

Create `.qzv` for all the outputs.

```
qiime metadata tabulate --m-input-file dada2/denoising_stats.qza --o-visualization denoising_stats.qzv
qiime feature-table summarize --i-table dada2/table.qza --o-visualization table.qzv
qiime feature-table tabulate-seqs --i-data dada2/representative_sequences.qza --o-visualization representative_sequences.qzv
```

Again upload files on the [QIIME2View](https://view.qiime2.org) website and ivestigate them.

***What % of your reads merged successfully?***

Additionally, when reviewing the representative sequences (your ASVs) you have obtained (`representative_sequences.qzv`), download them from the QIIME2View website in FASTA format. 

<details>
  <summary>Help here</summary>

  ![Description of the image](imgs/rep_seq.png)
</details>

 
 And finally upload raw representative sequences (fasta format) to your working directory on the server (folder `illumina`).


#### 9. Exporting files

To assign taxonomy for further diversity analysis, you need to download two files: `ASV table` (table.qza) and `representative sequences` in a fasta format.

To read the feature table, which represents your ASVs table, you need to export it using QIIME2:

```
qiime tools export --input-path dada2/table.qza --output-path exported
biom convert --to-tsv -i exported/feature-table.biom -o exported/feature-table.tsv
```

Created files you will find in the folder 'exported'

Download `feature-table.tsv` to your computer.


#### 10. Taxonomic annotation

You will assign taxonomy using the [VSEARCH](https://github.com/torognes/vsearch) software, which uses the global alignment method. For reference, you will use the [PR2](https://pr2-database.org) database.

```
vsearch --usearch_global sequences.fasta --db /mnt/databases/pr2_db/pr2_database-5.0.0.fasta --blast6out taxonomy.tsv --id 0.70
```

***Which other databases and methods of assigning taxonomy do you know?***


#### 11. Modifying outputs for diversity analyses 

Open the downloaded `feature-table.tsv` in Excel, remove the first raw, and change the name in cell A2 from `#OTU ID` to `ASV` and save the changes.

<details>
  <summary>Help here</summary>

  ![Description of the image](imgs/table.png)
</details>

***What information does this file contain?***


Using Python script you will modify `taxonomy.tsv`

```
../scripts/modify_taxonomy_illumina.py -i taxonomy.tsv -o taxonomy_table.tsv
```

<details>
  <summary>In the case of permission denied error</summary>

  In some cases, scripts will run, only after changing their permission rules.

  You can easily fix it by navigating to the 'scripts' folder and setting new permissions.

  ```
chmod 777 *
```
</details>


Download taxonomy_table.tsv to your computer and open it in Excel. Take a look at the data to determine which taxa are present.

***Which taxa are most represented in your samples?***

#### !!! <ins>FINAL OUTCOMES</ins> !!!

Congratulations! You've just finished the first part of today's data analysis!
As a final outputs, you obtained:
* `feature-table.tsv` - table of ASV abundances
* `taxonomy_table.tsv` - table of taxonomy for each ASV





### Nanopore

#### 1. Copying data

For the second part of the day, set the nanopore folder as your working directory.

Start by copying your two sample files into the working directory. To check the sample names, refer to the Excel spreadsheet shared on Slack.

```
cp ../../4UProtistDiversity/raw_nanopore/sample_name .
```


#### 2. Quality check

For nanopore data we will use two softwares to check the quality, already known FastQC and [NanoPlot](https://github.com/wdecoster/NanoPlot). 

The first command puts your samples in separate folders. Following comands will be run over the folders in a [loop](https://runcloud.io/blog/bash-for-loop) executing fastqc or NanoPlot tools.

```
for file in *.fastq; do folder_name="${file%.fastq}"; mkdir -p "$folder_name"; mv "$file" "$folder_name"; done
for folder in *; do fastqc "$folder"/*.fastq; done
conda activate nanopore
for folder in *; do NanoPlot --fastq "$folder"/*.fastq --tsv_stats --info_in_report -o "$folder"/nanoplot_raw ; done
```

Again download the `.html` fastqc outputs located in folders to your computer and open it in the browser. 

***Do you see the difference with Illumina data?***

NanoPlot produces a lot of outputs! One of them is general statistics `NanoStats.txt`. The other ones are plots. Download to your computer two of them `LengthvsQualityScatterPlot_dot.png` and `Non_weightedHistogramReadlength.png` and inspect.

***Which of those two software is better for nanopore data and why?*** 


#### 3. Length and quality filtering

We will use [Filtlong](https://github.com/rrwick/Filtlong) to filter reads by length and quality.

```
for folder in *; do filtlong --min_length 2000 --max_length 6000  --min_mean_q 90  "$folder"/*.fastq > "$folder"/filtlong.fastq; done
```

#### 4. Comparing quality after filtering

Again perform a quality check after filtering.

```
for folder in *; do fastqc "$folder"/filtlong.fastq; done
for folder in *; do NanoPlot --fastq "$folder"/filtlong.fastq --tsv_stats --info_in_report -o "$folder"/nanoplot_filtered ; done
```
***Compare the obtained results with the non-filtered reads from step 2. What differences can you observe?***


#### 5. Extracting 18S rDNA sequences

[Barrnap](https://github.com/tseemann/barrnap) software extracts rDNA fragments from the reads. Unfortunately, it runs very slowly considering the massive amount of data that you got, so to save time, we ran it beforehand. You will simply copy the barrnap output to the appropriate folders.

```
# Copy barrnap.fasta separately for your two samples 
cp ../../4UProtistDiversity/barrnap/yoursamplename/barrnap.fasta ./yoursamplename
```

<details>
  <summary>Here is what command to use if you want to run it yourself</summary>

  Before running it change `filtlong.fastq` to `filtlong.fasta` using `sed` command.

  ```
  for folder in *; do sed -n '1~4s/^@/>/p;2~4p' "$folder"/filtlong.fastq > "$folder"/filtlong.fasta; done
  for folder in *; do barrnap --kingdom euk --reject 0.1 --outseq "$folder"/barrnap.fasta "$folder"/filtlong.fasta --threads 4; done
  ```
</details>

***How many different rDNA parts did you obtain?***

Using Python script you will keep only 18S rDNA for further analysis.

```
for folder in *; do ../scripts/extracting_18S.py -i "$folder"/barrnap.fasta -o "$folder"/18S_extracted.fasta; done
```

***Do you know why we decided to focus solely on the 18S rDNA?***


#### 6. Getting average read quality

For the next step, you need to calculate the average read quality for each sample. Python script recalculates the Phred scale quality provided by NanoPlot to quality in percentage values.

```
for folder in *; do echo "$folder"; ../scripts/clustering_treshold_calculations.py -s "$folder"/nanoplot_filtered/NanoStats.txt -e ../scripts/P_error_table.tsv; done
```


#### 7. Clustering

Previously analyzing Ilumina data, you used VSEARCH to assign the taxonomy. However, this software offers many additional functions! Now, we are gonna use it for clustering the reads.

```
for folder in *; do mkdir "$folder"/clusters_error; done

# Run the command below separately for your two samples. Remember to set your folder name and clustering value from the previous step -id (eg. -id 0.975)

vsearch --cluster_fast <folder>/18S_extracted.fasta -id <clustering value> --clusters <folder>/clusters_error/cluster_ --centroids <folder>/centroids_error.fasta 
```


#### 8. Clusters filtering

VSEARCH gave big number of clusters which contain only one sequence (singletons), which will become computational problem in the next steps. So, in the next step you will get rid of clusters which don't have minimum 3 sequences.

```
for folder in *; do cp ../scripts/reduce_abundance.py "$folder"; cd "$folder"; ./reduce_abundance.py; cd ../; done
```


#### 9. Polishing

Polishing is an important step of working with nanopore data, as it improves read quality. You will use two softwares [Minimap2](https://github.com/lh3/minimap2) for mapping centroids to sequences before clustering and [Racon](https://github.com/isovic/racon) which performs the sequence correction.

```
for folder in *; do minimap2 "$folder"/centroids_error_filt.fasta "$folder"/18S_extracted.fasta > "$folder"/minimap2.paf; done
for folder in *; do racon "$folder"/18S_extracted.fasta -q 20 -w 500 "$folder"/minimap2.paf "$folder"/centroids_error_filt.fasta > "$folder"/racon.fasta; done
```


#### 10. Merging samples

For next step you will need to work on all the samples.
First using Python script add sample names to the headers of your polished sequences.

```
for folder in *; do ../scripts/add_names.py -i "$folder"/racon.fasta -b "$folder" -o "$folder"/"racon_${folder%.*}.fasta"; done
```

Next copy your whole sample folder to the folder `../../4UProtistDiversity/merging_nanopore`.
Finally merge polished and renamed sequences together.

```
cat ../../4UProtistDiversity/merging_nanopore/*/racon_* > merged_seqs.fasta
```


#### 11. Chimeras removal

Here you will again use VSEARCH, but this time to remove chimeric sequences.

```
vsearch --uchime_ref merged_seqs.fasta --db /mnt/databases/pr2_db/pr2_database-5.0.0.fasta --nonchimeras merged_nonchim_seqs.fasta
```

***What % of sequences turned out to be chimeric? Is it more or less than in case of illumina?***


#### 12. Final clustering

To obtain your final Operational Taxonomic Units (OTUs) you need to cluster together nearly identital sequences from all the samples.

```
mkdir clusters_final
vsearch --cluster_fast merged_nonchim_seqs.fasta  -id 0.99 --clusters clusters_final/cluster_ --centroids otus.fasta
```


#### 13. Taxonomic annotation

You will assign the taxonomy and modify the output in the same way you did for illumina data. 

```
vsearch --usearch_global otus.fasta --db /mnt/databases/pr2_db/pr2_database-5.0.0.fasta --blast6out taxonomy.tsv --id 0.70
../scripts/modify_taxonomy_nanopore.py -i taxonomy.tsv -o taxonomy_table.tsv
```
Download `taxonomy_table.tsv` to your computer.


#### 14. Abundance calculations

In this step you will use Python scripts to calculate OTUs abundance (based on the number of reads in clusters) and create final OTU table.

```
for folder in ../../4UProtistDiversity/merging_nanopore/*; do folder_name=$(basename "$folder"); ../scripts/abundance.py -otu otus.fasta -fclu clusters_final -bclu ../../4UProtistDiversity/merging_nanopore/${folder_name}/clusters_error -b "$folder" -o "abundance_${folder_name}.tsv"; done
../scripts/create_nanopore_otu_table.py -t taxonomy.tsv -i ./ -o otu_table.tsv
```

Download `otu_table.tsv` to your computer and take a look!.


#### !!! <ins>FINAL OUTCOMES</ins> !!!

Congratulations! You've just finished the first day of data analysis!
As a final outputs you obtained:
* `otu_table.tsv` - table of OTUs abundances
* `taxonomy_table.tsv` - table of taxonomy for each OTU


$${\color{red}If \space you \space \space want \space to \space use \space our \space scripts \space or \space pipeline, \space please \space cite \space this \space repository. \space Also \space the \space paper \space is \space on \space the \space way! \space :)}$$



## DAY 2 - From Taxa to Diversity


### Introduction

During this part you will use your OTU and taxonomy tables and metadata table to perform different statistical analysis. You will work in [RStudio](https://posit.co/download/rstudio-desktop/) and use R programming language to analyse your data.


### RStudio and libraries installation

#### 1. RStudio

[Here](https://swirlstats.com/students.html), you will find the instruction to install R and RStudio.


#### 2. Libraries

Download the listed libraries.

* vegan
* readxl
* dplyr
* FactoMineR
* factoextra
* ggplot2
* tidyverse
* bestNormalize
* psych
* rstatix
* corrplot
* readr


### Analysis

Open file `20241119.09.07.Praha.Rmd.R` in RStudio.







