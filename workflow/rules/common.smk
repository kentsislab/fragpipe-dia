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
    # permissive PG2 rules
    target1 = expand(os.path.join(workflow_dir, "PG2_permissive",
        "{sample}.fp-manifest"), sample=samples)
    target2 = expand(os.path.join(out_dir, "{sample}",
        "PG2_permissive","proteome.fasta"),
        sample=samples)
    target3 = expand(os.path.join(out_dir, "{sample}",
        "PG2_permissive", "decoys-contam-proteome.fasta.fas"),
    sample=samples)
    target4 = expand(os.path.join(workflow_dir, "PG2_permissive",
            "{sample}.workflow"),
        sample=samples)
    target5 = expand(os.path.join(out_dir,"{sample}","PG2_permissive",
            "protein.tsv"),
        sample=samples)
    # target6 = expand(os.path.join(out_dir, "{sample}",
    #         "PG2_permissive", "temp", "{sample}.raw"),
    #    sample=samples)
    output.extend(target1)
    output.extend(target2)
    output.extend(target3)
    output.extend(target4)
    output.extend(target5)
    # output.extend(target6)
    return output