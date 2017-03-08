#!/bin/sh
source /opt/asn/etc/asn-bash-profiles-special/modules.sh
module load fastqc/0.10.1
module load trimmomatic/0.35
module load gnu_parallel/201612222

## Recommended submission:
        # 10 cores
        # 2 hours
        # 20gb
       
       
### Change directory to the scratch directory
cd /scratch/aubcls05/DaphniaPunk

##################  Now for the Cleaning ################################
# copy over the fasta file with the adapter file to use for screening
cp /home/aubcls05/class_shared/code/AdaptersToTrim_All.fa .

#### Create list of names:
# ls (list) contents of directory with fastq files, cut the names of the files at 
        #underscore characters and keep the first three chunks (i.e. fields; -f 1,2,3), 
        #sort names and keep only the unique ones (there will be duplicates of all 
        #file base names because of PE reads), then send the last 6 lines to a file 
        #called list with tail
                        # HS03_TTAGGC_L005_R1_001.fastq.gz 
                # 1 = C2
                # 2 = CCAGTT
                # 3 = All
                # 4 = R1
                # 5 = 001

ls | grep ".fastq" |cut -d "_" -f 1,2 | sort | uniq > list

### while loop to process through the names in the list
while read i
do

############ Trimmomatic #############
############  Trim read for quality when quality drops below Q30 and remove sequences shorter than 36 bp
#MINLEN:<length> #length: Specifies the minimum length of reads to be kept.
#SLIDINGWINDOW:<windowSize>:<requiredQuality>  #windowSize: specifies the number of bases to average across
#requiredQuality: specifies the average quality required.
# -threads  is the option to define the number of threads (cores) to use. For this to be effective you need to request those cores at submission
#  ON HOPPER: trimmomatic-0.36

java -jar /opt/asn/apps/trimmomatic_0.35/Trimmomatic-0.35/trimmomatic-0.35.jar PE -threads 10 -phred33 "$i"_All_R1.fastq "$i"_All_R2.fastq "$i"_All_R1_paired_threads.fastq "$i"_All_R1_unpaired_threads.fastq "$i"_All_R2_paired_threads.fastq "$i"_All_R2_unpaired_threads.fastq ILLUMINACLIP:AdaptersToTrim_All.fa:2:30:10 HEADCROP:10 LEADING:30 TRAILING:30 SLIDINGWINDOW:6:30 MINLEN:36 

done<list

############### Now assess Quality again
#fastqc on the cleaned paired fastq files in parallel
ls *_R1_paired_threads.fastq | parallel -j+0  --eta 'fastqc {}'
ls *_R2_paired_threads.fastq | parallel -j+0  --eta 'fastqc {}'
