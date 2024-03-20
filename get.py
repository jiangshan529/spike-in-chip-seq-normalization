import pandas as pd
from io import StringIO
df = pd.read_csv('extracted_data.csv')

# Convert percentage strings to float and calculate unique reads
df['homo_uniq_map_ratio'] = df['homo_uniq_map_ratio'].str.rstrip('%').astype('float') / 100
df['droso_uniq_map_ratio'] = df['droso_uniq_map_ratio'].str.rstrip('%').astype('float') / 100

# Calculate new columns for human and droso unique reads
df['human_uniq_reads'] = df['homo_paired_reads'] * df['homo_uniq_map_ratio'] * (1 - df['human_duplicate_rate'])
df['droso_uniq_reads'] = df['droso_paired_reads'] * df['droso_uniq_map_ratio'] * (1 - df['drosophila_duplicate_rate'])

df['human_uniq_reads'] = df['human_uniq_reads'].round().astype(int)
df['droso_uniq_reads'] = df['droso_uniq_reads'].round().astype(int)

# Check the dataframe
df.to_csv('extracted_data.csv')
