#!/bin/bash
#this script iterates through the fasta files you tell it to and blasts the refseq protein database

############### INPUT #######################
#specifiy -db (database)
#specifity the -task (method of searching seqs)
#specify -query (query sequence you're blasting)
#more help on commands using: blastp --help
#############################################

############### OUTPUT ######################
#a text file of all the aligned blasted results called {Something}dump.txt
#############################################

for SEQ in *.fasta
do

        nice blastp -query ${SEQ} -task blastp -db /mnt/data2/blast/refseq_protein -out ${SEQ%.txt}_querydump.txt -evalue 0.01 -word_size 6 -gapopen 11 -gapextend 1 -matrix BLOSUM62 -outfmt "6 delim=| saccver stitle sseq" -max_target_seqs 10000 -num_threads 28
done
