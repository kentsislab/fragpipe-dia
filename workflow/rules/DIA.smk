"""
rules for running Fragpipe's DIA_SpecLib_Quant workflow
"""

## create manifest and a temp directory for fragpipe
rule create_manifest:
    input:
        samplesheet=samplesheet
    params:
        workflow_dir=config["workflow_dir"],
        out_dir=out_dir
    output:
        manifest= expand(os.path.join(config["workflow_dir"],
            "{sample}.fp-manifest"), sample=samples),
    resources:
        mem_mb = 4000,
        time = 20,
    singularity:
        "docker://quay.io/preskaa/proteomics:v240915"
    script:
        "../scripts/write_dia_manifest.py"

# fix PG2 headers for fragpipe analysis
rule fix_PG2_headers:
    input:
        proteome = os.path.join(PG2_dir, "{sample}", "experiment/combined.proteome.unique.fasta")
    output:
        proteome = os.path.join(out_dir, "{sample}", "PG2_permissive", "proteome.fasta"),
        index_table = os.path.join(out_dir, "{sample}", "PG2_permissive", "fasta_header_index.tsv")
    resources:
        mem_mb = 4000,
        time = 20,
    threads: 1,
    singularity:
        "docker://quay.io/preskaa/proteomics:v240915"
    script:
        "../scripts/fix_pg2_headers.py"

# add decoys and contaminants to
rule add_decoys_contams:
    input:
        proteome = os.path.join(out_dir,"{sample}","PG2_permissive","proteome.fasta")
    output:
        proteome = os.path.join(out_dir, "{sample}", "PG2_permissive", date + "-decoys-contam-proteome.fasta.fas")
    params:
        philosopher="/fragpipe_bin/fragPipe-22.0/fragpipe/tools/Philosopher/philosopher-v5.1.1"
    resources:
        mem_mb = 8000,
        time = 20,
    threads: 1,
    singularity:
        "/data1/shahs3/users/preskaa/singularity/fragpipe_22.0.sif"
    shell:
        """
    {params.philosopher} workspace --init --nocheck
    {params.philosopher} database --custom {input.proteome} --contam --contamprefix
    {params.philosopher} workspace --clean --nocheck
        """





