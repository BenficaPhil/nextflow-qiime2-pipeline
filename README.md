# Nextflow QIIME 2 Pipeline for USDA-ARS ABBL
Automates all QIIME 2 steps typically run in ABBL's 16S rRNA amplicon analysis protocol. Can run everything from data import to producing a rarefaction curve with 1 command and 3 folders (sequencing data, metadata, and the nextflow scripts). A 2nd command completes your alpha and beta diversity analyses.

The pipeline is designed to access the QIIME 2 installations on the USDA-ARS SCINet HPC.

## Steps the pipeline runs by default
1. Generate a manifest file
2. Imports paired-end sequencing data
3. Trims V3-V4 primers with Cutadapt
4. Finds what values to set as truncation parameters in DADA2 for a Q30 cutoff
5. Runs denoising with DADA2
6. Runs taxonomic classification using a SILVA 138.2 classifier weighted to animal proximal gut
7. Filters the ASV table to remove mitochondria, chloroplasts, and Unasssigned
8. Exports a genus-level feature table
9. Produces a grouped table QZA (e.g. if plotting combined samples for each Treatment group)
10. Produces a phylogenetic tree for later diversity step
11. Produces an alpha rarefaction curve
12. Runs functional prediction with PICRUSt2

## How to run
In a directory for your project, make 2 folders named 01_data and metadata. Move your sequencing data (fastq files) to 01_data and your metadata file to metadata. The beginning of your filenames and sample IDs in the metadata should match to avoid breaking the pipeline.

Make a 3rd folder named pipelines and download the contents of the repository to this folder.

You'll have 3 folders like so:
```
01_data
metadata
pipelines
```

Load Nextflow v25.04.6 and run! (preferably on a compute node and not the login node)
```
module load nextflow/25.04.6

nextflow run pipelines/qiime2_automated.nf
```

### Alpha and beta diversity
After the pipeline completes, consult the alpha rarefaction curve and checking the number of samples that would be removed. Once you've decided on a sampling depth, simply ask the pipeline to resume and add the --run-diversity and --sampling_depth flags. For example:
```
nextflow run pipelines/qiime2_automated.nf --run_diversity --sampling_depth 10000 -resume
```

## Customizable parameters
These parameters can be changed by passing flags into the nextflow command:
* --qiime2_version, default: 2026.1
  * Replace the default with another date if available on the HPC
* --forward-primer, default: CCTACGGGNGGCWGCAG
  * Can be replaced by another primer  
* --reverse_primer, default: GACTACHVGGGTATCTAATCC
  * Can be replaced by another primer
* --quality_cutoff, default: 30
  * Any number 0-40 works
* --tax_database, default: SILVA_138.2_animal_gut
  * The other options are
    * SILVA_138.2_animal_feces
    * SILVA_138.2_human_feces
    * SILVA_138.2_unweighted
    * SILVA_138.1_unweighted
    * Greengenes2
    * GTDB_r220
  * The pipeline automatically downloads the classifier in the background, saving you time!
* --analysis_group, default: Treatment
  * This group is the metadata column input in PERMANOVA for beta diversity significance. Change if your metadata column of interest is not called Treatmnent.
* --picrust2_version, default: 2.6.1
  * Can be changed if SCINet updates to a new version

### Example of a customized pipeline command
```
nextflow run pipelines/qiime2_automated.nf --quality_cutoff 25 --tax_database SILVA_138.2_unweighted
```

## Output structure
Most of the useful outputs (the QZV files) will be placed in a folder called 03_visualizations. Alpha and beta diversity outputs are placed in 10_diversity, with separate folders for alpha diversity, beta diversity, and the rarefied table.

All outputs are made available in case you'd like to take QZA files and run other individual QIIME 2 commands. The output folder list will look like this at the end of processing:
```
02_import
03_visualizations
04_DADA2
05_taxonomy
06_filtered
07_genus_table
08_grouped_table
09_phylogeny
10_diversity
11_picrust2
```

## Local vs. slurm profile
By default, your local resources are used (e.g. your current compute node if on SCINet). The -profile flag can be changed to slurm, which will submit each step as a Slurm job.
```
nextflow run pipelines/qiime2_automated.nf -profile slurm
```

## Features in progress
Currently, the ANCOM-BC2 part of pipeline is commented out, until that section is tested further.
