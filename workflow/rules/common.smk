import pandas as pd

# inputs
samplesheet=config["samplesheet"]
out_dir = config["out_dir"]
workflow_dir = config["workflow_dir"]
PG2_dirs = config["PG2_dirs"]
pg_dbs = config["pg_dbs"]
swissprot_fasta = config["swissprot"]["fasta"]
norm_samplesheet=config["normal_samplesheet"]
fragpipe_config_tools = config["fragpipe_config_tools"]
haplotypes = config["reannotate"]["haplotypes"]
ref_gtf = config["reannotate"]["ref_gtf"]
unified_proteome = config["unified_proteome"]["fasta"]

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
        "transcriptome", "haplotype_{haplotype}", "transcript.gffcmp.transcripts.gtf.tmap"),
            haplotype=haplotypes, sample=samples, db=pg_dbs),
        target11 = expand(os.path.join(out_dir, "{sample}",
            "{db}","proteome.fasta"),
            sample=samples, db=pg_dbs)
        output.extend(target9)
        output.extend(target10)
        output.extend(target11)
    # run fragpipe
    if config["fragpipe"]["activate"]:
        target1 = expand(os.path.join(workflow_dir, "{db}",
            "{sample}.fp-manifest"), sample=samples, db=pg_dbs)
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
        output.extend(target3)
        output.extend(target4)
        output.extend(target5)
    # if swissprot is activated, run fragpipe against swissprot
    if config["swissprot"]["activate"]:
        norm_samples = create_sample_list(norm_samplesheet) if norm_samplesheet else []
        all_samples = samples + norm_samples
        target6 = expand(os.path.join(workflow_dir, "swissprot",
        "{sample}.fp-manifest"), sample=all_samples)
        target7 = os.path.join(workflow_dir, "swissprot",
            "trypsin_dia_speclib_quant.workflow")
        target8 = expand(os.path.join(out_dir,"{sample}","swissprot",
            "protein.tsv"), sample=all_samples)
        output.extend(target6)
        output.append(target7)
        output.extend(target8)
    # if unified proteome is activated,
    # run fragpipe against a single unified proteome for all samples
    if config["unified_proteome"]["activate"]:
        norm_samples = create_sample_list(norm_samplesheet) if norm_samplesheet else []
        all_samples = samples + norm_samples
        target9 = os.path.join(out_dir, "unified_proteome",
            "decoys-contam-proteome.fasta.fas")
        target10 = expand(os.path.join(workflow_dir, "unified_proteome",
        "{sample}.fp-manifest"), sample=all_samples)
        target11 = os.path.join(workflow_dir, "unified_proteome",
            "trypsin_dia_speclib_quant.workflow")
        target12 = expand(os.path.join(out_dir,"{sample}","unified_proteome",
            "protein.tsv"), sample=all_samples)
        output.append(target9)
        output.extend(target10)
        output.append(target11)
        output.extend(target12)
    return output