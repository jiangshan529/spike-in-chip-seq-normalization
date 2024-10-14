data_dir=/home/gcpuser/sky_workdir/chip
out_put=gs://xialab_walkupseq/output/ChIP-seq/
size=/home/gcpuser/sky_workdir/hg38.chrXYM.chrom.sizes
ref_seq=/home/gcpuser/sky_workdir/hg38.chrXYM
java=/data/WALKUP-15628/231008_SL-EXB_0084_A227CVTLT3/1697061146/juicer/scripts/common/juicer_tools.jar
cpu=48
mem=48G

if [[ ! -d "1.trim" ]]; then
        mkdir 1.trim
fi

if [[ ! -d "2.mapping" ]]
then
                mkdir 2.mapping
fi
if [[ ! -d "3.track_peak" ]]
then
                mkdir 3.track_peak
fi

# Directory containing your files
        input_dir="./"

# Loop through each file with _R1_001.fastq.gz in the directory
for file in "$input_dir"/*_R1_001.fastq.gz; do
    # Extract the prefix
    sample=$(basename "$file" _R1_001.fastq.gz)
    
    # Perform operations using the prefix
    echo "Processing file with prefix: $sample"
    
    R1_file="${sample}_R1_001.fastq.gz"
    R2_file="${sample}_R2_001.fastq.gz"

    # Print the R1 file path
    echo "R1_file: $sample"

    # Check if R1 file exists to ensure we have files to work on
    if [ -f "$R1_file" ]; then
        # Get the base name of the file without the directory path
        filename=$(basename "$file")
        # Remove the shortest match of _R1* from the end of the filename
        sample="${filename%%_R1*}"
        #echo "$prefix"
        trim_galore -q 25 --paired --phred33 -e 0.1 --fastqc --clip_R1 10 --clip_R2 10 --length 36 --stringency 3 -j 48 -o 1.trim ${sample}_R1_001.fastq.gz ${sample}_R2_001.fastq.gz
        bowtie2 -p 48 -x $ref_seq -1 ./1.trim/${sample}_R1_001_val_1.fq.gz -2 ./1.trim/${sample}_R2_001_val_2.fq.gz --un-conc-gz ./1.trim/${sample}.Unmapped.gz 2>./2.mapping/${sample}.homo.log | samtools view -@ 48 -Sb -o ./2.mapp
ing/${sample}_hg38_aligned.bam
        bowtie2 -p 48 -x /home/gcpuser/sky_workdir/droso_genome/dm6 -1 ./1.trim/${sample}.Unmapped.1.gz -2 ./1.trim/${sample}.Unmapped.2.gz  2>./2.mapping/${sample}.droso.log | samtools view -@ 48 -Sb -o ./2.mapping/${sample}_dros
o_aligned.bam
        samtools sort -@ 48 ./2.mapping/${sample}_hg38_aligned.bam > ./2.mapping/${sample}_hg38_sort.bam
        rm ./2.mapping/${sample}_hg38_aligned.bam
        java -jar /root/picard.jar MarkDuplicates I=./2.mapping/${sample}_hg38_sort.bam O=./2.mapping/${sample}_hg38_sort.rmdup.bam M=./2.mapping/${sample}_hg38_sort.txt REMOVE_DUPLICATES=true TMP_DIR=./
        rm ./2.mapping/${sample}_hg38_sort.bam
        samtools index -@ 48 ./2.mapping/${sample}_hg38_sort.rmdup.bam
#        bamCoverage --bam ./2.mapping/${sample}_hg38_sort.rmdup.bam -o ./3.track_peak/${sample}_hg38_sort.rmdup_CPM.bw --binSize 25 --smoothLength 75 --numberOfProcessors 48 --normalizeUsing CPM --effectiveGenomeSize 2913022398 -
-centerReads --extendReads --ignoreForNormalization chrM
        macs2 callpeak -t ./2.mapping/${sample}_hg38_sort.rmdup.bam -g hs -n ${sample}_hg38_sort.rmdup_q001 -q 0.01 --keep-dup="all" -f "BAMPE" --outdir ./3.track_peak/
#        macs2 callpeak -t ./2.mapping/${sample}_hg38_sort.rmdup.bam -g hs -n ${sample}_hg38_sort.rmdup_q005 -q 0.05 --keep-dup="all" -f "BAMPE" --outdir ./3.track_peak/
        samtools sort -@ 48 ./2.mapping/${sample}_droso_aligned.bam > ./2.mapping/${sample}_droso_sort.bam
        java -jar /root/picard.jar MarkDuplicates I=./2.mapping/${sample}_droso_sort.bam O=./2.mapping/${sample}_droso_sort.rmdup.bam M=./2.mapping/${sample}_droso_sort.txt REMOVE_DUPLICATES=true TMP_DIR=./
#       amtools view -@ 48 -F 4 -b ${sample}_hg38_sort.rmdup.bam > ${sample}_hg38_sort.rmdup_mapped.bam 
#       amtools view -@ 48 -F 4 -b ${sample}_droso_hg38_sort.rmdup.bam > ${sample}_droso_hg38_sort.rmdup_mapped.bam
        #hg38_bam="${sample}_hg38_sort.rmdup.bam"
        #droso_bam="${sample}_droso_hg38_sort.rmdup.bam"

    # Check if the BAM file exists to ensure we have files to work on
        if [ -f "$hg38_bam" ] && [ -f "$droso_bam" ]; then
        # Extract mapped reads
                samtools view -@ 48 -F 4 -b "$hg38_bam" > "${sample}_hg38_sort.rmdup_mapped.bam"
                samtools view -@ 48 -F 4 -b "$droso_bam" > "${sample}_droso_hg38_sort.rmdup_mapped.bam"
        
        # Append the sample name to the output file
                echo "$sample" >> "$output_file"
        
        # Run samtools flagstat and append the output to the text file
                samtools flagstat -@ 48 "${sample}_hg38_sort.rmdup_mapped.bam" >> "$output_file"
                samtools flagstat -@ 48 "${sample}_droso_hg38_sort.rmdup_mapped.bam" >> "$output_file"
        else
                echo "BAM files for sample $sample not found."
        #rm ./2.mapping/${sample}_hg38_sort.rmdup.bam
        fi
   # fi
done
