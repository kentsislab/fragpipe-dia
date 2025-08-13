"""
rules to reannotate PG2 proteome headers to UniProt style headers
"""
# fetch haplotyped gtfs
def _fetch_sample_gtf(wildcards):
    for PG2_dir in PG2_dirs:
        if wildcards.db in PG2_dir:
            break
    transcripts = os.path.join(
        PG2_dir,
        wildcards.sample,
        f"experiment/haplotype-{wildcards.haplotype}",
        "transcripts.gtf")
    return transcripts
rule chr_names:
    input:
        gtf = _fetch_sample_gtf
    output:
        gtf = os.path.join(out_dir, "{sample}", "{db}", "transcripts.haplo{haplotype}.gtf")
    shell:
        "sed 's/^[0-9]*_//' {input.gtf} > {output.gtf}"

# ## run gffcompare so we can determine which transcripts are non-canonical
# rule run_gffcompare:
#     input:
#         merged_gtf = os.path.join(out_dir,"stringtie_merge","merged.transcripts.gtf")
#     output:
#         annotated_gtf = os.path.join(out_dir,"stringtie_merge","merged.gffcmp.annotated.gtf")
#     params:
#         ref_gtf = ref_gtf,
#         out_prefix = os.path.join(out_dir,"stringtie_merge","merged.gffcmp")
#     singularity:
#         "docker://quay.io/biocontainers/gffcompare:0.12.6--h4ac6f70_3",
#     shell:
#         """
#         gffcompare {input.merged_gtf} -r {params.ref_gtf} -o {params.out_prefix}
#         """





