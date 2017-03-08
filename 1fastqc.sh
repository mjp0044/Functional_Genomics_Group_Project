#!/bin/sh
source /opt/asn/etc/asn-bash-profiles-special/modules.sh
module load fastqc/0.10.1
module load gnu_parallel/201612222

###########  This is example code to move your files from our class shared to scratch, unzip them, concatenated the R1 and R2 files for each individual, and run fastqc the concatenated files 
## Recommended submission to ASC:
        # 10 cores
        # 2 hours
        # 20gb

######  remove any the targeted scratch directory and any files within
rm -r /scratch/aubcls05/DaphniaPunk
mkdir /scratch/aubcls05/DaphniaPunk

### Change directory to the scratch directory
cd /scratch/aubcls05/DaphniaPunk

#####   copy all .fastq.gz to  scratch directory in parallel using GNU parallel  

ls /home/aubcls05/class_shared/Exp1_DaphniaDataset/*.fastq.gz | time parallel -j+0 --eta 'cp {} .'

## unzip in parallel. List all the * .gz files and run on as many jobs as cores (-j) as and don't add any more files (0)
ls *fastq.gz |time parallel -j+0 'gunzip {}'

#### Make the list then use that list to Concatenate Forward Read (R1)files in parallel (Thanks Steven Sephic for this solution!)
ls | grep ".fastq" |cut -d "_" -f 1,2 | sort | uniq | parallel cat {1}_L00*_R1_*.fastq '>' {1}_All_R1.fastq ::: ${i}
##### Concatenate Reverse Reads (R2) files
ls | grep ".fastq" |cut -d "_" -f 1,2 | sort | uniq | parallel cat {1}_L00*_R2_*.fastq '>' {1}_All_R2.fastq ::: ${i}

##  Run fastqc on the All files in parallel
ls *_All_R1.fastq | time parallel -j+0 --eta 'fastqc {}'
ls *_All_R2.fastq | time parallel -j+0 --eta 'fastqc {}'
