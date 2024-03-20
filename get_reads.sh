#!/bin/bash

# Print header to CSV file including new columns for duplicate rates
echo "sample_prefix,homo_paired_reads,homo_uniq_map_ratio,human_duplicate_rate,droso_paired_reads,droso_uniq_map_ratio,drosophila_duplicate_rate" > extracted_data.csv

# Loop through homo log files to extract and append data to CSV
for homo_log_file in *.homo.log; do
    sample_prefix=$(echo "$homo_log_file" | sed 's/.homo.log//')
    
    # Corresponding files
    droso_log_file="${sample_prefix}.droso.log"
    human_txt_file="${sample_prefix}_hg38_sort.txt"
    drosophila_txt_file="${sample_prefix}_droso_hg38_sort.txt"

    # Extracting information from log files
    homo_total_reads_paired=$(grep -P 'were paired;' "$homo_log_file" | awk '{print $1}')
    homo_reads_aligned_concordantly_1_ratio=$(grep -P 'aligned concordantly exactly 1 time' "$homo_log_file" | head -1 | sed -n 's/.*(\(.*%\)).*/\1/p')
    droso_total_reads_paired=$(grep -P 'were paired;' "$droso_log_file" | awk '{print $1}')
    droso_reads_aligned_concordantly_1_ratio=$(grep -P 'aligned concordantly exactly 1 time' "$droso_log_file" | head -1 | sed -n 's/.*(\(.*%\)).*/\1/p')
    

    human_txt_file="${sample_prefix}_hg38_sort.txt"
    drosophila_txt_file="${sample_prefix}_droso_hg38_sort.txt"

    # Extract the PERCENT_DUPLICATION values from each file
    if [[ -f "$human_txt_file" ]]; then
        human_dup_rate=$(grep "^Unknown Library" "$human_txt_file" | awk '{print $(NF-1)}')
    else
        human_dup_rate="N/A"
    fi

    if [[ -f "$drosophila_txt_file" ]]; then
        drosophila_dup_rate=$(grep "^Unknown Library" "$drosophila_txt_file" | awk '{print $(NF-1)}')
    else
        drosophila_dup_rate="N/A"
    fi


    #homo_uniq_reads=$(awk 'BEGIN {print ($homo_total_reads_paired * $homo_reads_aligned_concordantly_1_ratio * (1 - $human_dup_rate))}')
    # Extracting duplicate rates from TXT files
    #human_dup_rate=$(grep "PERCENT_DUPLICATION" "$human_txt_file" | tail -1 | awk '{print $(NF-1)}')
    #drosophila_dup_rate=$(grep "PERCENT_DUPLICATION" "$drosophila_txt_file" | tail -1 | awk '{print $(NF-1)}')

    # Append all extracted data to CSV
    echo "$sample_prefix,$homo_total_reads_paired,$homo_reads_aligned_concordantly_1_ratio,$human_dup_rate,$droso_total_reads_paired,$droso_reads_aligned_concordantly_1_ratio,$drosophila_dup_rate" >> extracted_data.csv
done


python get.py
