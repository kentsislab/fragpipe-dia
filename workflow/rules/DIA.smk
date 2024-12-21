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
        proteome = os.path.join(outdir, "{sample}", "proteome.fasta"),
        index_table = os.path.join(outdir, "{sample}", "fasta_header_index.tsv")
    singularity:
        "docker://quay.io/preskaa/proteomics:v240915"
    script:
        "../scripts/fix_pg2_headers.py"

