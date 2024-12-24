import pandas as pd
import os
import shutil

## create a temp directory for fragpipe
DIA_filepath=snakemake.input["dia_filepath"]
hardlink_dir=snakemake.params["hardlink_dir"]
manifest_path = snakemake.output["manifest"]
hardlink_path = snakemake.output["hardlink"]
# make hardlink directory if it doesn't exist
os.makedirs(hardlink_dir, exist_ok=True)
# copy over the file to a new directory; hardlinks don't work
# with Thermo's filereader: https://github.com/Nesvilab/FragPipe/issues/1957
shutil.copy(DIA_filepath, hardlink_path)
with open(manifest_path, "w+") as f:
    line = f"{hardlink_path}			DIA"
    f.write(line)

