import sys
import pandas as pd

input_file= snakemake.input["proteome"]
output_file = snakemake.output["proteome"]
header_table = snakemake.output["index_table"]
# input_file= sys.argv[1]
# output_file = sys.argv[2]
# header_table = sys.argv[3]

old_headers = []
new_headers = []
i = 1

with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
    for line in infile:
        if line.startswith(">"):
            new_header = f"PG{i}"
            new_headers.append(new_header)
            old_headers.append(line.strip())
            outfile.write(">" + new_header + "\n")
            i += 1
        else:
            outfile.write(line)

# save index table
df = pd.DataFrame(zip(new_headers, old_headers), columns=["ID", "original PG2 header"])
df.to_csv(header_table, sep="\t", index=False)

