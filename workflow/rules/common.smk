import pandas as pd

# inputs
samplesheet=config["samplesheet"]
out_dir = config["out_dir"]
workflow_dir = config["workflow_dir"]
PG2_dir = config["PG2_dir"]

# create sample list
def create_sample_list(samplesheet):
    df = pd.read_csv(samplesheet, sep="\t")
    return list(df["individual_id"])

# create sample list for outputs
samples = create_sample_list(samplesheet)

# get outputs
def get_output():
    output = []
    target1 = expand(os.path.join(workflow_dir,
        "{sample}.fp-manifest"), sample=samples)
    target2 = expand(os.path.join(outdir, sample, "proteome.fasta"),
        sample=samples)
    output.extend(target1)
    output.extend(target2)
    return output