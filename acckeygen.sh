#!/bin/bash

# Searches FASTA title to construct a human readable label
function readable()
{
    local FSTFILE=${1};
    local ANNOTATION;
    local ACC;
    local NAME;
    local LABEL;
    local COUNT;
    local TEMP;

    #Pull out the FASTA annotation line
    ANNOTATION=$(egrep '^>' ${FSTFILE});

#Pull out & save the Accesion # from the annotation line
    ACC=$(echo ${ANNOTATION} |perl -pe 's/[^\S\n]+/\|/' | perl -pe 's/^>(.*)\|.*\n/$1\n/');

#Creates a variable (NAME) that is made of the first 2 letters of the first words within
    #brackets on the FASTA title line, if no brackets NAME is assigned as UNKN
    if echo ${ANNOTATION} | egrep -q '\['
    then
        NAME=$(echo ${ANNOTATION} | perl -pe 's/^>.*\[([[:alnum:]][[:alnum:]])[^ ]* ([[:alnum:]][[:alnum:]])[^]]*\]/\U$1$2/');
    else
        NAME="UNKN";
    fi
#Test if NAME is 4 characters long and if not assign as UNKN
    if [ ${#NAME} -ne 4 ]
    then
        NAME="UNKN";
    fi

 #The following if loops are used to assign the variable LABEL. The first if checks to
    #see if the FASTA has a sp ID and uses that as the name. If no sp ID exists, then the
    #if loops go about generating a sp-styled ID for the gi #.
    if echo ${ANNOTATION} | egrep -q '\|sp\|'
    then
        LABEL=$(echo $ANNOTATION | perl -pe 's/^>.*\|sp\|[^|]*\|([^ ]*) .*\n/$1/');
    elif echo ${ANNOTATION} | egrep -qi 'hypothetical protein'
    then
        LABEL="HYPO_${NAME}";
    elif echo ${ANNOTATION} | egrep -q 'NAD(P)-binding domain-containing protein'
    then
        LABEL="NADP_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'tryptophan dimethylallyltransferase family protein'
    then
        LABEL="DMET_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'uncharacterized protein'
    then
        LABEL="UNCH_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'DMATS family aromatic prenyltransferase'
    then
        LABEL="PREN_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'Aromatic prenyltransferase'
    then
        LABEL="PREN_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'iron-containing redox enzyme family protein'
    then
        LABEL="FE_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'tryptophanase'
    then
        LABEL="TRP_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'beta-eliminating lyase'
    then
        LABEL="LY_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'pyridoxal phosphate-dependent transferase'
    then
        LABEL="TRANS_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'isopentenyl-diphosphate Delta-isomerase'
    then
        LABEL="ISO_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi '2-amino-4-hydroxy-6-hydroxymethyldihydropteridine diphosphokinase'
    then
        LABEL="KIN_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi '4-chloro-allylglycine synthase BesC'
    then
        LABEL="BESC_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'peptide synthetase'
    then
        LABEL="PEP_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'AraC family ligand binding domain-containing protein'
    then
        LABEL="ARAC_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'amino acid adenylation domain-containing protein'
    then
        LABEL="AAAD_${NAME}"
    elif echo ${ANNOTATION} | egrep -qi 'cupin domain-containing protein'
    then
        LABEL="CUP_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'tripartite tricarboxylate transporter substrate-binding protein'
    then
        LABEL="TPT_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'alpha/beta fold hydrolase'
    then
      LABEL="HYD_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'LodA/GoxA family CTQ-dependent oxidase'
    then
      LABEL="CTQ_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'ABC transporter'
    then
      LABEL="ABC_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'Putative hem oxygenase-like, multi-helical'
    then
      LABEL="HDO_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'AMP-binding protein'
    then
      LABEL="AMP_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'EamA family transporter'
    then
      LABEL="EAMA_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'DUF3865 domain-containing protein'
    then
      LABEL="DUF_${NAME}";
    elif echo ${ANNOTATION} | egrep -qi 'CBU_0637 family Dot/Icm type IV secretion system effector'
    then
      LABEL="CBU_${NAME}";
    else
        LABEL="UNK_${NAME}";
    fi
 #Creates variable COUNT which is used to ensure that each LABEL is unique by appending
    #COUNT to the LABEL if there is another LABEL with that id
    COUNT=$(awk '{print $2}' acckey.txt | egrep ${LABEL} | wc -l)

    if [ ${COUNT} -ge 1 ] && [ ${COUNT} -lt 100 ]
    then
        TEMP=$(echo ${LABEL} | perl -pe 's/(.{8}).*/$1/');
        printf "%15s %15s %s%d\n" ${ACC} ${LABEL} ${TEMP} ${COUNT} >> acckey.txt;
    elif [ ${COUNT} -ge 100 ]
    then
        TEMP=$(echo ${LABEL} | perl -pe 's/(.{7}).*/$1/');
        printf "%15s %15s %s%d\n" ${ACC} ${LABEL} ${TEMP} ${COUNT} >> acckey.txt;
    else
        TEMP=$(echo ${LABEL} | perl -pe 's/(.{10}).*/$1/');
        printf "%15s %15s %s\n" ${ACC} ${LABEL} ${TEMP} >> acckey.txt;
    fi
}

#This for loop runs through all .fst files in the current directory. Make sure that the
#only .fst files in the directory are those exploded using seqcon

rm -f acckey.txt;

for FSTFILE in *.fst
do
    readable ${FSTFILE};
done
