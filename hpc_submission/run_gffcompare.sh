#!/bin/bash
# iput gtf
input_gtf=$HOME/Library/CloudStorage/OneDrive-MemorialSloanKetteringCancerCenter/AMLproteogenomics/APS028_AML_PG2_analysis/pg2_reannotation/haplotype1.transcripts.gtf
# reference gtf
ref_gtf=$HOME/Library/CloudStorage/OneDrive-MemorialSloanKetteringCancerCenter/code/ref_genomes/hg38p14/gencode.v45.primary_assembly.annotation.gtf
#output directory
outdir=$HOME/Library/CloudStorage/OneDrive-MemorialSloanKetteringCancerCenter/AMLproteogenomics/APS028_AML_PG2_analysis/pg2_reannotation
prefix=${outdir}/haplotype1.gffcmp
# run gffcompare
gffcompare ${input_gtf} -r ${ref_gtf} -o ${prefix}