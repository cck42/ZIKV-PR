#!/bin/bash

#feed it a file base name
file_base=$1

#Create log of each step for each library
log=${file_base}.pipeline.log

{
	
echo "--------------------------------------------"
echo "Generating consensus for sample $file_base"
echo "--------------------------------------------"

#Variables for each of the reads
f1=${file_base}_R1_001.fastq.gz
f2=${file_base}_R2_001.fastq.gz

#Hard code paths to primer info, pair info, reference genome
zika_reference=/Users/chaneykalinich/Documents/CDC_2019/processing/References/Zika_ref_PR.fa
primer_sequence=/Users/chaneykalinich/Documents/CDC_2019/processing/zika_primers.fa
primer_locations=/Users/chaneykalinich/Documents/CDC_2019/processing/ZKV.bed
pair_information=/Users/chaneykalinich/Documents/CDC_2019/processing/pair_information.tsv

#make a directory for the library
mkdir ${file_base}_data
#move paired end read data into that library
mv $f1 $f2 ${file_base}_data
#change that directory to working directory
cd ${file_base}_data

#align reads to reference genome
#bwa mem spits out a bam file, so then make the alignment a sam file
bwa mem $zika_reference $f1 $f2 | samtools view -b -F 4 -F 2048 | samtools sort -o ${file_base}_aln.bam

#QC and soft clip primers
ivar trim -i ${file_base}_aln.bam -b $primer_locations -p ${file_base}_aln_trimmed.bam

#Sort iVar output
samtools sort ${file_base}_aln_trimmed.bam -o ${file_base}_aln_trimmed_sorted.bam

#Index iVar output
samtools index ${file_base}_aln_trimmed_sorted.bam

#Identify variants (from reference) and call a consensus
#-t option varies the threshold; .25 means that any base that exists at >75% coverage will be called
#-m option sets a lower limit for coverage. 10 means that there have to be at least 10 reads at a position.
samtools mpileup -A -d 0 -Q 0 ${file_base}_aln_trimmed_sorted.bam | ivar consensus -t 0.25 -m 10 -p ${file_base}_consensus

echo "-----------------------------------------------------"
echo "Consensus generation completed for sample $file_base"
echo "-----------------------------------------------------"

#Remove temporary files
rm ${file_base}_aln_trimmed.bam
rm ${file_base}_aln_trimmed_sorted.bam
rm ${file_base}_aln_trimmed_sorted.bam.bai
rm ${file_base}_aln.bam.bai

}

#Move log into library directory
mv $log ${file_base}_data