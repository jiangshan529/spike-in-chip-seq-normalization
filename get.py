import os
import pandas as pd

# Define the directory containing the log files
log_dir = "./"

# Initialize a dictionary to store the data
data = {}

# Process log files
for filename in os.listdir(log_dir):
    if filename.endswith(".log"):
        file_path = os.path.join(log_dir, filename)
        with open(file_path, 'r') as file:
            lines = file.readlines()
            prefix = filename.rsplit('.', 2)[0]  # get prefix without the last two parts
            total_reads = int(lines[0].split()[0])
            overall_alignment_rate = float(lines[-1].strip().split('%')[0]) / 100.0  # convert percentage to a fraction
            reads_number = round(total_reads * overall_alignment_rate)
            file_type = 'homo' if 'homo' in filename else 'droso'
            
            if prefix not in data:
                data[prefix] = {}
            
            data[prefix][f'{file_type}_total_reads'] = total_reads
            data[prefix][f'{file_type}_overall_alignment_rate'] = overall_alignment_rate
            data[prefix][f'{file_type}_reads_number'] = reads_number

# Process duplication rate files
for filename in os.listdir(log_dir):
    if filename.endswith("_hg38_sort.txt"):
        file_path = os.path.join(log_dir, filename)
        with open(file_path, 'r') as file:
            lines = file.readlines()
            for line in lines:
                if line.startswith("Unknown Library"):
                    parts = line.split()
                    percent_duplication = float(parts[-2])
                    unique_reads_fraction = 1 - percent_duplication
                    prefix = filename.replace('_hg38_sort.txt', '')
                    
                    if prefix in data:
                        file_type = 'homo'
                        total_reads = data[prefix].get(f'{file_type}_total_reads', 0)
                        overall_alignment_rate = data[prefix].get(f'{file_type}_overall_alignment_rate', 0)
                        unique_reads = round(total_reads * overall_alignment_rate * unique_reads_fraction)
                        data[prefix][f'{file_type}_unique_reads'] = unique_reads
                        data[prefix][f'{file_type}_percent_duplication'] = percent_duplication

    elif filename.endswith("_droso_sort.rmdup.bam"):
        file_path = os.path.join(log_dir, filename)
        with open(file_path, 'r') as file:
            lines = file.readlines()
            for line in lines:
                if line.startswith("Unknown Library"):
                    parts = line.split()
                    percent_duplication = float(parts[-2])
                    unique_reads_fraction = 1 - percent_duplication
                    prefix = filename.replace('_droso_hg38_sort.txt', '')
                    
                    if prefix in data:
                        file_type = 'droso'
                        total_reads = data[prefix].get(f'{file_type}_total_reads', 0)
                        overall_alignment_rate = data[prefix].get(f'{file_type}_overall_alignment_rate', 0)
                        unique_reads = round(total_reads * overall_alignment_rate * unique_reads_fraction)
                        data[prefix][f'{file_type}_unique_reads'] = unique_reads
                        data[prefix][f'{file_type}_percent_duplication'] = percent_duplication

# Create a DataFrame from the data dictionary
df = pd.DataFrame.from_dict(data, orient='index')

# Sort the DataFrame by the prefix
df.sort_index(inplace=True)

# Write the DataFrame to a CSV file
output_file = "combined_mapping_summary_with_duplication.csv"
df.to_csv(output_file)

# Print the DataFrame
print(df)
