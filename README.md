# 2018_spring_SEM
NGS-based metagenomic pathogen viruses and bacteria identification system

# Description
Most of methods of microbial diagnostics take significant amount of time. Also, they render themselves useless in the case of unculturable forms of pathogen agents. It is proposed to use Illumina sequencing of mixed samples to improve the identification of infectious agents.

# Goal
Build an Illumina sequencing-based pathogen agents identification system

# Targets
- Download and organize reference sequences of viruses and bacteria.
- State pathogenicity group (BCL-like) for each tax_id and sequence.
- Set up the pipeline for mixed sample pathogen agents identification and annotation.

# Results
Kraken and HUMAnN2 pipeline scripts parse paired Illumina-like (<i>name<\i>_S<NUM>_L<NUM>_R<NUM>_001.fastq.gz) names specified by user by means of zenity GUI.
Output folder will contain folders named by sample numbers (S<NUM>) with pipeline output files.
  
# Kraken pipeline
Outputs <name>.kraken.report.BSL.tsv with fields
1.Percentage of reads covered by the clade rooted at this taxon
2.Number of reads covered by the clade rooted at this taxon
3.Number of reads assigned directly to this taxon
4.A rank code, indicating (U)nclassified, (D)omain, (K)ingdom, (P)hylum, (C)lass, (O)rder, (F)amily, (G)enus, or (S)pecies. All other ranks are simply '-'.
5.NCBI taxonomy ID
6.Pathogenicity group
7.Indented scientific name
Requirements
- kraken with MiniKraken DB (https://ccb.jhu.edu/software/kraken/)
Config
- threads - number of threads to use
- threshold - kraken-filter threshold (0.01 to 0.15 float) improves precision by setting labels of higher level
- KRAKEN_DIR - Kraken installation directory
- DB_DIR - directory containing kraken databases
- DB - name of MiniKraken database (an directory inside DB_DIR directory)
- WORK_DIR - default input-output folder
  
# HUMAnN2 pipeline
Outputs (view HUMAnN2 manual: https://bitbucket.org/biobakery/humann2/wiki/Home)
- <name>_genefamilies.tsv
- <name>_pathabundance.tsv
- <name>_pathcoverage.tsv
Requirements
- Python (version >= 2.7)
- Java Runtime Environment
- Bowtie2 (version >= 2.2)
- perl
- KneadData (https://bitbucket.org/biobakery/kneaddata/wiki/Home)
- MetaPhlAn2 (https://bitbucket.org/biobakery/metaphlan2/)
- HUMAnN2 (https://bitbucket.org/biobakery/humann2/wiki/Home) and ChocoPhlAn database and uniref90_ec_filtered_diamond database
Config
- threads - number of threads to use
- METAPHLAN_DIR - MetaPhlAn2 installation directory
- WORK_DIR - default input-output folder
