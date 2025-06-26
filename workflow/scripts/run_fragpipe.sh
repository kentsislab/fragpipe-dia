#!/bin/bash
#####
workflow=${snakemake_input[workflow]}
manifest=${snakemake_input[manifest]}
outdir=${snakemake_params[outdir]}
threads=${snakemake[threads]}
memory=${snakemake_params[memory]} #in GB
tempdir=${snakemake_params[tempdir]}
config_tools=${snakemake_params[config_tools]}
# fragpipe config tools
fragpipe=/fragpipe_bin/fragpipe-23.0/fragpipe-23.0/bin/fragpipe
config_diann=/usr/bin/diann
########
mkdir -p ${outdir}
cd ${outdir}
# make outdir for dia-nn as this appeared to be the issue before ....
mkdir -p ${outdir}/diann-output
#########
${fragpipe} --headless \
  --workflow ${workflow} \
  --manifest ${manifest} \
  --config-tools-folder /usr/bin/fragpipe_config_tools \
  --workdir ${outdir} \
  --threads ${threads} \
  --config-diann ${config_diann} \
  --ram ${memory}
#  --dry-run
# remove temporary directory upon completion
rm -r ${tempdir}