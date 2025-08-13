import pandas as pd

# inputs
samplesheet=config["samplesheet"]
out_dir = config["out_dir"]
workflow_dir = config["workflow_dir"]
PG2_dirs = config["PG2_dirs"]
pg_dbs = config["pg_dbs"]
swissprot_fasta = config["swissprot"]["fasta"]
norm_samplesheet=config["swissprot"]["normal_samplesheet"]
fragpipe_config_tools = config["fragpipe_config_tools"]
haplotypes = config["reannotate"]["haplotypes"]
ref_gtf = config["reannotate"]["ref_gtf"]

# create sample list
def create_sample_list(samplesheet):
    df = pd.read_csv(samplesheet, sep="\t")
    return list(df["individual_id"])

# create sample list for outputs
samples = create_sample_list(samplesheet)

# get outputs
def get_output():
    output = []
    # reannotate PG2 proteomes
    if config["reannotate"]["activate"]:
        target9 = expand(os.path.join(out_dir, "{sample}", "{db}", 
        "transcriptome", "haplotype_{haplotype}", "transcripts.gtf"),
            haplotype=haplotypes, sample=samples, db=pg_dbs)
        target10 = expand(os.path.join(out_dir, "{sample}", "{db}", 
        "transcriptome", "haplotype_{haplotype}", "transcript.gffcmp.annotated.gtf"),
            haplotype=haplotypes, sample=samples, db=pg_dbs)
        output.extend(target10)
    # run fragpipe
    if config["fragpipe"]["activate"]:
        target1 = expand(os.path.join(workflow_dir, "{db}",
            "{sample}.fp-manifest"), sample=samples, db=pg_dbs)
        target2 = expand(os.path.join(out_dir, "{sample}",
            "{db}","proteome.fasta"),
            sample=samples, db=pg_dbs)
        target3 = expand(os.path.join(out_dir, "{sample}",
            "{db}", "decoys-contam-proteome.fasta.fas"),
        sample=samples, db=pg_dbs)
        target4 = expand(os.path.join(workflow_dir, "{db}",
                "{sample}.workflow"),
            sample=samples, db=pg_dbs)
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
        norm_samples = create_sample_list(norm_samplesheet)
        all_samples = samples + norm_samples
        target6 = expand(os.path.join(workflow_dir, "swissprot",
        "{sample}.fp-manifest"), sample=all_samples)
        target7 = expand(os.path.join(workflow_dir, "swissprot",
            "trypsin_dia_speclib_quant.workflow"), sample=all_samples)
        target8 = expand(os.path.join(out_dir,"{sample}","swissprot",
            "protein.tsv"), sample=all_samples)
        output.extend(target6)
        output.extend(target7)
        output.extend(target8)
    return output