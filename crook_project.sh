#! /bin/bash

#Move to folder containing files
cd Desktop
cd bio_project

#Trim adapter sequences and low quality reads using Trimmomatic
for file in *.gz
do
	output_file=${file%.fastq.gz}_trimmed.fastq.gz
	java -jar Trimmomatic-0.39/trimmomatic-0.39.jar SE -phred33 $file $output_file ILLUMINACLIP:Trimmomatic-0.39/adapters/TruSeq3-SE.fa:2:30:10 LEADING:3 TRAILING:3
done

#Generate genome index using trypanosome fasta file
./STAR/STAR-2.7.0f/bin/MacOSX_x86_64/STAR --runThreadN 2 --runMode genomeGenerate --genomeDir /Users/lewislab/Desktop/biol5153/STAR/genomeDir --genomeFastaFiles /Users/lewislab/Desktop/biol5153/STAR/genomeDir/trypanosome_GCF_000002445.2_ASM244v1_genomic.fna --sjdbGTFfile /Users/lewislab/Desktop/biol5153/STAR/trypanosome.gtf --sjdbOverhang 50

#map reads to genome
for file in *trimmed.fastq.gz
do
	trimmed_read=$file
	./STAR/STAR-2.7.0f/bin/MacOSX_x86_64/STAR --runThreadN 2 --runMode alignReads --genomeDir /Users/lewislab/Desktop/biol5153/STAR/genomeDir --readFilesCommand gunzip -c --quantMode TranscriptomeSAM --readFilesIn $trimmed_read --outFileNamePrefix /Users/lewislab/Desktop/biol5153/${trimmed_read%.fastq.gz}
done

#Prepare reference sequences for RSEM by running rsem-prepare-reference
./RSEM-1.3.1/rsem-prepare-reference --gtf /Users/lewislab/Desktop/biol5153/STAR/trypanosome.gtf /Users/lewislab/Desktop/biol5153/STAR/genomeDir/trypanosome_GCF_000002445.2_ASM244v1_genomic.fna /Users/lewislab/Desktop/biol5153/RSEM_output

#Calculate expression values with RSEM by running rsem-calculate-expression
for file in *.bam
do
	./RSEM-1.3.1/rsem-calculate-expression --bam $file  RSEM_output $file
done
