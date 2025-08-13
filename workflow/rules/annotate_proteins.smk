"""
rules to reannotate PG2 proteome headers to UniProt style headers
"""
localrules: chr_names
# fetch haplotyped gtfs
def _fetch_sample_gtf(wildcards):
    for PG2_dir in PG2_dirs:
        if wildcards.db in PG2_dir:
            break
    transcripts = os.path.join(
        PG2_dir,
        wildcards.sample,
        f"experiment/haplotype-{wildcards.haplotype}",
        "transcriptome",
        "transcripts.gtf")
    return transcripts
# fix chromosome names in transcript gtfs to be compatible with gffcompare
rule chr_names:
    input:
        gtf = _fetch_sample_gtf
    output:
        gtf = os.path.join(out_dir, "{sample}", "{db}", "transcriptome", "haplotype_{haplotype}", "transcripts.gtf")
    resources:
        mem_mb = 4000,
        time = 10,
    container:
        "docker://quay.io/nf-core/ubuntu:22.04"
    shell:
        "sed 's/^[0-9]*_//' {input.gtf} > {output.gtf}"

# run gffcompare so we can determine which transcripts are non-canonical
rule run_gffcompare:
    input:
        gtf = os.path.join(out_dir, "{sample}", "{db}", "transcriptome", 
        "haplotype_{haplotype}", "transcripts.gtf")
    output:
        annotated_gtf = os.path.join(out_dir, "{sample}", "{db}", "transcriptome", 
        "haplotype_{haplotype}", "transcript.gffcmp.annotated.gtf")
    params:
        ref_gtf = ref_gtf,
        out_prefix =  os.path.join(out_dir, "{sample}", "{db}", "transcriptome", 
        "haplotype_{haplotype}", "transcript.gffcmp")
    resources:
        mem_mb = 8000,
        time = 20,
        partition="cpushort"
    container:
        "docker://quay.io/biocontainers/gffcompare:0.12.6--h4ac6f70_3",
    shell:
        """
        gffcompare {input.gtf} -r {params.ref_gtf} -o {params.out_prefix}
        """





