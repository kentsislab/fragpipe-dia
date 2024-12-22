import pandas as pd
import os

## create a temp directory for fragpipe
DIA_filepath=snakemake.input["dia_filepath"]
symlink_dir=snakemake.params["symlink_dir"]
manifest_path = snakemake.output["manifest"]
symlink_path = snakemake.output["symlink"]
# make symlink directory if it doesn't exist
os.makedirs(symlink_dir, exist_ok=True)
# symlink
os.symlink(DIA_filepath, symlink_path)
manifest = pd.DataFrame(zip([symlink_path], ["DIA"]))
manifest.to_csv(manifest_path, sep="\t", index=None, header=None)

