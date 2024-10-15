#!/bin/bash

# Define the list of ratios
ratios=(1 0.5985286779 1 0.9528464111 1 0.9393906891 0.9554847107 0.6163466378 0.8779541852 0.7916825307 0.6128448972 0.3793421278 1 1 1)

# Define the list of BAM files
bam_files=(
"23022FL-11-01-12_S12_L002_hg38_sort.rmdup_mapped.bam"
"23022FL-11-01-13_S13_L002_hg38_sort.rmdup_mapped.bam"
"23022FL-11-01-14_S14_L002_hg38_sort.rmdup_mapped.bam"
"23022FL-11-01-15_S15_L002_hg38_sort.rmdup_mapped.bam"
"23022FL-11-01-16_S16_L002_hg38_sort.rmdup_mapped.bam"
"23022FL-11-01-17_S17_L002_hg38_sort.rmdup_mapped.bam"
"23022FL-11-01-18_S18_L002_hg38_sort.rmdup_mapped.bam"
"23022FL-11-01-19_S19_L002_hg38_sort.rmdup_mapped.bam"
"23022FL-11-01-20_S20_L002_hg38_sort.rmdup_mapped.bam"
"23022FL-11-01-21_S21_L002_hg38_sort.rmdup_mapped.bam"
"23022FL-11-01-22_S22_L002_hg38_sort.rmdup_mapped.bam"
"23022FL-11-01-23_S23_L002_hg38_sort.rmdup_mapped.bam"
"23022FL-11-01-24_S24_L002_hg38_sort.rmdup_mapped.bam"
"23022FL-11-01-25_S25_L002_hg38_sort.rmdup_mapped.bam"
"23022FL-11-01-26_S26_L002_hg38_sort.rmdup_mapped.bam"
)

# Create output directory if it does not exist
mkdir -p downsample

# Loop through each BAM file and corresponding ratio
for i in "${!bam_files[@]}"; do
    bam_file="${bam_files[$i]}"
    ratio="${ratios[$i]}"
    
    # Change ratio to 0.999999 if it is 1
    if [[ "$ratio" == "1" ]]; then
        ratio="0.999999"
    fi
    
    prefix=$(basename "$bam_file" "_hg38_sort.rmdup_mapped.bam")

    # Downsample the BAM file
    echo "samtools view -b -s $ratio \"$bam_file\" > \"downsample/${prefix}_hg38_downsample.bam\""
    samtools index -@ 48 "$bam_file"
    samtools view -b -s "$ratio" "$bam_file" > "downsample/${prefix}_hg38_downsample.bam"

    # Index the downsampled BAM file
    echo "samtools index -@ 48 \"downsample/${prefix}_hg38_downsample.bam\""
    samtools index -@ 48 "downsample/${prefix}_hg38_downsample.bam"

    # Generate the bigWig file
    echo "bamCoverage --bam \"downsample/${prefix}_hg38_downsample.bam\" -o \"downsample/${prefix}_hg38_downsample.bw\" --binSize 25 --smoothLength 75 --numberOfProcessors 48 --centerReads --extendReads --ignoreForNormalization chrM"
    bamCoverage --bam "downsample/${prefix}_hg38_downsample.bam" -o "downsample/${prefix}_hg38_downsample.bw" --binSize 25 --smoothLength 75 --numberOfProcessors 48 --centerReads --extendReads --ignoreForNormalization chrM
done
