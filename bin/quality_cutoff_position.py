#!/usr/bin/env python3

import sys
import pandas as pd

# Set quality score cutoff
if len(sys.argv) > 1:
    q_cutoff = int(sys.argv[1])
    #print(f"Quality cutoff specified as {q_cutoff}")
else:
    print("No argument was provided.")

# Load the seven-number summary file
forward_df = pd.read_csv('extracted_demux/forward-seven-number-summaries.tsv', sep='\t')
reverse_df = pd.read_csv('extracted_demux/reverse-seven-number-summaries.tsv', sep='\t')

# Find row with median quality
forward_median = forward_df[forward_df.iloc[:, 0] == "50%"].iloc[0, 1:]
reverse_median = reverse_df[forward_df.iloc[:, 0] == "50%"].iloc[0, 1:]

# Find the first position where the median (50th percentile) is < cutoff
forward_below_cutoff = forward_median[forward_median.astype(int) < q_cutoff]
reverse_below_cutoff = reverse_median[reverse_median.astype(int) < q_cutoff]

if not forward_below_cutoff.empty:
    forward_position = forward_below_cutoff.index[0]
    trunc_f = int(forward_position) - 1
    #print(f"Forward reads: Median quality falls below {q_cutoff} at base position {forward_position}. Setting DADA2 trunc-f at {trunc_f}.")
else:
    forward_position = forward_df.columns[-1]
    trunc_f = int(forward_position)
    #print("Forward reads: Median quality never falls below {q_cutoff}.")

if not reverse_below_cutoff.empty:
    reverse_position = reverse_below_cutoff.index[0]
    trunc_r = int(reverse_position) - 1
    #print(f"Reverse reads: Median quality falls below {q_cutoff} at base position {reverse_position}. Setting DADA2 trunc-r at {trunc_r}.")
else:
    reverse_position = reverse_df.columns[-1]
    trunc_r = int(reverse_position)
    #print("Reverse reads: Median quality never falls below {q_cutoff}.")

print(trunc_f, trunc_r)
