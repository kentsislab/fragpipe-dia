import pandas as pd

# inputs
samplesheet=config["samplesheet"]
out_dir = config["out_dir"]
workflow_dir = config["workflow_dir"]
PG2_dir = config["PG2_dir"]
pg_dbs = config["pg_dbs"]
swissprot_fasta = config["swissprot"]["fasta"]
norm_samplesheet=config["swissprot"]["normal_samplesheet"]

# create sample list
def create_sample_list(samplesheet):
    df = pd.read_csv(samplesheet, sep="\t")
    return list(df["individual_id"])

# create sample list for outputs
samples = create_sample_list(samplesheet)
# if swissprot option is activated:
if config["swissprot"]["activate"]:
    dbs = pg_dbs + ["swissprot"]
    norm_samples = create_sample_list(norm_samplesheet)
    all_samples = samples + norm_samples
else:
    dbs = pg_dbs

# get outputs
def get_output():
    output = []
    target1 = expand(os.path.join(workflow_dir, "{db}",
        "{sample}.fp-manifest"), sample=samples, db=dbs)
    target2 = expand(os.path.join(out_dir, "{sample}",
        "{db}","proteome.fasta"),
        sample=samples, db=pg_dbs)
    target3 = expand(os.path.join(out_dir, "{sample}",
        "{db}", "decoys-contam-proteome.fasta.fas"),
    sample=samples, db=pg_dbs)
    target4 = expand(os.path.join(workflow_dir, "{db}",
            "{sample}.workflow"),
        sample=samples, db=dbs)
    target5 = expand(os.path.join(out_dir,"{sample}","{db}",
            "protein.tsv"),
        sample=samples, db=pg_dbs)
    output.extend(target1)
    output.extend(target2)
    output.extend(target3)
    output.extend(target4)
    output.extend(target5)
    # if swissprot is activated, run fragpipe
    if config["swissprot"]["activate"]:
        target6 = expand(os.path.join(out_dir,"{sample}","swissprot",
            "protein.tsv"),
            sample=all_samples)
        output.extend(target6)
    return output