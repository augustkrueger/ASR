# ASR workflow
This repository contains scripts for amino acid ASR.
This document is meant to give step-by-step workflow.

# multiblast
Begin with sequences of interest in separate fasta (ends with .fasta) files. 
Run multiblast.sh to iteratively blast each .fasta files in directory.

Usage: ./multiblast.sh
Output: _querydump.txt file for each input fasta file.

# parse
Concats all _querydump.txt sequences without repeats.

Usage: ./parse_blastp_tab.py
Output: concat_seqdump.fasta, concat_accnum.txt, and concat_key.txt

At this point I like to make a copy of the directory and name it something like "pre-explode"

# explode
Explodes concatted fasta file into individual fastas.

Usage: seqcon -E concat_seqdump.fasta

# rename sequences
First, modify acckeygen.sh to rename proteins to correct protein family name.
If it gives a warning it can't find the acckey.txt file, its working, so don't cancel the job.

Usage: ./acckeygen.sh

Next, run the rename.sh script to apply the names from the acckey.txt file to the sequences in the concat dump file.

Usage: ./rename.sh acckey.txt concat_seqdump.fasta

# review sequences
To trim by sequence length:
seqcon -k 200:300

Copy the renamed headers fasta to your computer and open it in an alignment.
If the dataset is small enough, align the sequences with the auto aligner in your MSA viewer. If not don't worry about it.
Look for and delete sequences:
  - Poor or incomplete sequencing
  - Non-homologous
  - Repeats
If able, realign sequences often for more obvious outliers.

# align sequences
Align the reviewed sequence dataset.
I prefer to use MAFFT to start:

Usage: mafft unaligned.fasta > aligned.fasta

Review the sequence alignment and delete suspicious sequences.
Realign after deleting sequences.

# trim by sequence identity
Only trim by identity after the sequences are aligned.

Usage: seqcon -u 0.95

Realign, review, and repeat.
Make sure your alignment still has your sequences of interest.

# generate a tree
Use IQTree to generate a tree from the multiple sequence alignment.

Usage: ./run_iqtree2
























  
