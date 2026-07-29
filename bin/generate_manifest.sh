#!/bin/bash

# Configuration
# Define the filepath
FILEPATH="$1"
# Define the suffix for your forward reads (e.g., _R1.fastq.gz or _1.fastq.gz)
FWD_SUFFIX="_R1_001.fastq.gz"
# Output file name
MANIFEST_FILE="manifest.tsv"

# Create/Overwrite the manifest file with the required QIIME 2 header
echo -e "sample-id\tforward-absolute-filepath\treverse-absolute-filepath" > "$MANIFEST_FILE"

# Loop through all forward reads in the current directory
for fwd_file in $FILEPATH/*$FWD_SUFFIX;
    do
    # Extract the sample ID by stripping the filepath and fastq file details
    fwd_name=$(basename "$fwd_file")
    sample_id="${fwd_name%_S*}"

    # Construct the corresponding reverse read filename
    rev_file="${fwd_file/_R1/_R2}"

    # Check if the reverse read exists before adding to the manifest
    if [[ -f "$rev_file" ]]; then
        # Get the absolute file paths
        fwd_path="$(pwd)/$fwd_file"
        rev_path="$(pwd)/$rev_file"

        # Append to the manifest file
        echo -e "$sample_id\t$fwd_path\t$rev_path" >> "$MANIFEST_FILE"
        echo "Added $sample_id to manifest."
    else
        echo "Warning: Reverse read for $sample_id not found. Skipping."
    fi
done

echo "Manifest generation complete. Saved as $MANIFEST_FILE"