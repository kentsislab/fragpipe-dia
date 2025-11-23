#!/bin/bash
# iput gtf
input_gtf=/Volumes/kentsis/Proteogenomics_Leukemia_Discovery/AML_Proteogenomic_Oellerich_PMID35245447/BIC_PG2_permissive/Proj_B-101-985/F1/experiment/haplotype-1/transcriptome/transcripts.gtf
# reference gtf
#output directory
outdir=$HOME/Library/CloudStorage/OneDrive-MemorialSloanKetteringCancerCenter/AMLproteogenomics/APS028_AML_PG2_analysis/pg2_reannotation
out_gtf=${outdir}/haplotype1.transcripts.gtf
# run gffcompare
sed 's/^[0-9]*_//' ${input_gtf} > ${out_gtf}