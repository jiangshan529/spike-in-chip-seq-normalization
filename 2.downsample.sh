samtools index -@ 48 -M  *.rmdup_sambambafilter.bam

samtools view -b -s 0.359 23022FL-08-01-10_S10_L002_hg38_sort.rmdup_sambambafilter.bam > 23022FL-08-01-10_S10_L002_hg38_sort.rmdup_sambambafilter_downsample.bam
samtools index -@ 48 23022FL-08-01-10_S10_L002_hg38_sort.rmdup_sambambafilter_downsample.bam
bamCoverage --bam 23022FL-08-01-10_S10_L002_hg38_sort.rmdup_sambambafilter_downsample.bam -o ../4.track_peak/10_hg38_sort.rmdup.bw --binSize 25 --smoothLength 75 --numberOfProcessors 48 --centerReads --extendReads --ignoreForNormalization chrM


computeMatrix reference-point --referencePoint center -S 06_hg38_sort.rmdup.bw -R 23022FL-08-01-06_S6_L002_hg38_sort.rmdup_sambambafilter_q001_peaks.narrowPeak -a 1000 -b 1000 --skipZeros --missingDataAsZero -o hek_06R_on_06_q0.01matrix.mat.gz --sortRegions descend --outFileSortedRegions hek_06R_on_06_q0.01_descend.bed
plotHeatmap -m hek_06R_on_06_q0.01matrix.mat.gz  --colorList 'white,#0485d1' --sortRegions no -out hek_06R_on_06_q0.01.pdf



  
