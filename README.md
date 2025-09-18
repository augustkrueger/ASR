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
