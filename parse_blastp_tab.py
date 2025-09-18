#!/bin/python3
# Read all of the seqdump files, combine and dereplicate into new fasta format
# Outputs concat_accnum.txt and concat_key.txt
import os
import sys

def parse_seqdump(file, delim, accnum):
    new_seqdump=[]

    #open temp file to read
    tmp_file = open(file, "r")
    file_lines = tmp_file.readlines()
    tmp_file.close()


    #change the line from tabular delim to fasta
    for line in file_lines:
        line = line.split(delim)
        if line[0] not in accnum:
            new_seqdump.append('>'+str(line[0])+' '+str(line[1])+'\n'+str(line[2]))
            key.append(str(line[0])+'\t'+str(line[1]))
            accnum.append(line[0])
        else:
            pass

    #print('len of accnum: ', len(accnum))
    return(new_seqdump, accnum, key)

#define delim
delim='|'
accnum=[]
key=[]
concat_seqdump=[]

#iterate throught the direct and concat all the files without including duplicates
for file in os.listdir(os.getcwd()):
    tmp_concat_seqdump = []
    if file.endswith('querydump.txt'):
        tmp_concat_seqdump, accnum, key = parse_seqdump(file, delim, accnum) #will be list of lists
        concat_seqdump.append(tmp_concat_seqdump)
    else:
        pass

print('total len of accnum: ', len(accnum))
print('total len of key: ', len(key))

#flatten the concat_seqdump
def flatten_list(_2d_list):
    flat_list = []
    # Iterate through the outer list
    for element in _2d_list:
        if type(element) is list:
            # If the element is of type list, iterate through the sublist
            for item in element:
                flat_list.append(item)
        else:
            flat_list.append(element)
    return flat_list

concat_seqdump = flatten_list(concat_seqdump)

print('total len of seqs: ', len(concat_seqdump))

#write new files
with open('concat_seqdump.fasta', 'w') as newfile:
    for line in concat_seqdump:
        newfile.write(str(line))

#write list of accnum
with open('concat_accnum.txt', 'w') as newfile2:
    for line in accnum:
        newfile2.write(str(line)+'\n')

#write key
with open('concat_key.txt', 'w') as newfile3:
    for line in key:
        newfile3.write(str(line)+'\n')
