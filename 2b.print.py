import pandas as pd

# Load the CSV file
file_path = 'combined_mapping_summary_with_duplication.csv'
data = pd.read_csv(file_path)

# Check if the columns exist and print them separately without the index
if 'homo_unique_reads' in data.columns:
    print("Homo Unique Reads:")
    print(data['homo_unique_reads'].to_string(index=False))
else:
    print("'homo_unique_reads' column not found in the CSV file.")

if 'droso_unique_reads' in data.columns:
    print("\nDroso Unique Reads:")
    print(data['droso_unique_reads'].to_string(index=False))
else:
    print("'droso_unique_reads' column not found in the CSV file.")
