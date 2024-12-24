#!/bin/bash
#####
workflow=${snakemake_input[workflow]}
manifest=${snakemake_input[manifest]}
outdir=${snakemake_params[outdir]}
threads=${snakemake[threads]}
memory=${snakemake_params[memory]} #in GB
tempdir=${snakemake_params[tempdir]}
# fragpipe config tools
fragpipe=/fragpipe_bin/fragPipe-22.0/fragpipe/bin/fragpipe
config_tools=/fragpipe_bin/fragpipe_config_tools
config_python=/usr/bin/python3.10
config_diann=/fragpipe_bin/diann-1.9.1/diann-linux
########
mkdir -p ${outdir}
cd ${outdir}
# make outdir for dia-nn as this appeared to be the issue before ....
mkdir -p ${outdir}/diann-output
#########
${fragpipe} --headless \
  --workflow ${workflow} \
  --manifest ${manifest} \
  --config-tools-folder ${config_tools} \
  --workdir ${outdir} \
  --threads ${threads} \
  --config-diann ${config_diann} \
  --config-python ${config_python} \
  --ram ${memory}
#  --dry-run
# remove temporary directory upon completion
rm -r ${tempdir}