#!/bin/bash

# remove any modules that were loaded previously
module purge
# load fragpipe
module load fragpipe/22.0
module load java/20.0.1
#####
workflow=${snakemake_input[workflow]}
manifest=${snakemake_input[manifest]}
config_tools=/home/preskaa/fragpipe_config_tools
outdir=${snakemake_params[outdir]}
config_python=/home/preskaa/miniconda3/envs/fragpipe/bin/python3.9
config_diann=/admin/software/fragpipe/fragpipe-22.0/tools/diann/1.8.2_beta_8/linux/diann-1.8.1.8
threads=${snakemake[threads]}
memory=${snakemake_params[memory]} #in GB
########
mkdir -p ${outdir}
cd ${outdir}
# make outdir for dia-nn as this appeared to be the issue before ....
mkdir -p ${outdir}/diann-output
# need to activate for mono
source activate /data1/kentsisa/fragpipe_ondemand/fragpipe_env
#########
fragpipe --headless \
  --workflow ${workflow} \
  --manifest ${manifest} \
  --config-tools-folder ${config_tools} \
  --workdir ${outdir} \
  --threads ${threads} \
  --config-diann ${config_diann} \
  --config-python ${config_python} \
  --ram ${memory}
#  --dry-run