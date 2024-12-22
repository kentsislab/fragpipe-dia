import pandas as pd
import numpy as np
import os

## create a temp directory for fragpipe
# inputs
samplesheet = snakemake.input["samplesheet"]
workflow_dir = snakemake.params["workflow_dir"]
out_dir = snakemake.params["out_dir"]
condition = snakemake.params["condition"]

# samplesheet = "/Users/asherpreskasteinberg/PycharmProjects/fragpipe-dia/config/PG2_Frankfurt_AML_proteomics.tsv"
# workflow_dir = "workflow"
# out_dir = "test_out"

# read in samplesheet
df = pd.read_csv(samplesheet, sep="\t")

for _, row in df.iterrows():
    sample = row["individual_id"]
    directory = row["directory"]
    DIA_file = row["DIA_file"]
    # make symlink directory if it doesn't exist
    symlink_dir = os.path.join(out_dir, condition, sample, "temp")
    os.makedirs(symlink_dir, exist_ok=True)
    # get path to original file
    _, DIA_file = DIA_file.split(" ")
    DIA_filepath = os.path.join(directory, DIA_file)
    # generate symlink path
    symlink_path = os.path.join(symlink_dir, DIA_file)
    # symlink
    os.symlink(DIA_filepath, symlink_path)
    # generate manifest
    manifest_path = os.path.join(workflow_dir, sample + ".fp-manifest")
    manifest = pd.DataFrame(zip([symlink_path], ["DIA"]))
    manifest.to_csv(manifest_path, sep="\t", index=None, header=None)
