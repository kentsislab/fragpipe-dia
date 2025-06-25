#!/bin/bash
#SBATCH --partition=cpushort
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --time=1:30:00
#SBATCH --mem=50GB
#SBATCH --job-name=fragpipe
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=preskaa@mskcc.org
#SBATCH --output=slurm%j_fragpipe.out

### example slurm submission script ###
# remove any modules that were loaded previously
module purge
#####
# provide the paths to your workflow and manifest here
workflow_dir=/data1/shahs3/users/preskaa/AMLproteogenomics/data/APS028_AML_PG2_analysis/fragpipe_workflows/PG2_permissive
workflow=$HOME/fragpipe-dia/fragpipe_workflows/fragpipe23_trypsin_dia_speclib_quant.workflow
manifest=$HOME/fragpipe-dia/tests/test.fp-manifest
# provide paths to fragpipe config tools, python and diann
config_tools=/home/preskaa/250624_fragpipe_config_tools
# provide out directory
outdir=/data1/shahs3/users/preskaa/AMLproteogenomics/data/APS028_AML_PG2_analysis/fragpipe_23_test
# tell fragpipe itself what resources are available
# set this to the number of "cpu-tasks" set above
threads=4
# for memory, I would recommend setting this at slightly lower than what we have told slurm we need
# e.g., if you set SLURM to 120 GB, I would set this to 100
memory=45 #in GB
########
# this creates the out directory and moves to this out directory
mkdir -p ${outdir}
cd ${outdir}
## make outdir for dia-nn as this appeared to be the issue before ....
mkdir -p ${outdir}/diann-output

# fix PG2 headers and add decoys and contaminants
sif_path=/data1/shahs3/users/preskaa/singularity/fragpipe_23.0.sif
fragpipe=/fragpipe_bin/fragpipe-23.0/fragpipe-23.0/bin/fragpipe
# provide paths to fragpipe config tools, python and diann
# config_tools=/fragpipe_bin/fragpipe_config_tools
config_diann=/usr/bin/diann

singularity exec -e -B /data1/shahs3:/data1/shahs3 \
   -B /data1/kentsisa:/data1/kentsisa \
   -B /admin/software:/admin/software ${sif_path} bash -c "
${fragpipe} --headless \
  --workflow ${workflow} \
  --manifest ${manifest} \
  --config-tools-folder ${config_tools} \
  --workdir ${outdir} \
  --threads ${threads} \
  --config-diann ${config_diann} \
  --ram ${memory} \
  # --dry-run
"
