#!/bin/bash
#SBATCH --partition=componc_cpu,componc_gpu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --time=48:00:00
#SBATCH --mem=50GB
#SBATCH --job-name=fragpipe
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=preskaa@mskcc.org
#SBATCH --output=slurm%j_fragpipe.out

### example slurm submission script ###
# remove any modules that were loaded previously
module purge
# this tells the cluster to load fragpipe and java modules
module load fragpipe/22.0
module load java/20.0.1
#####
# provide the paths to your workflow and manifest here
workflow=/data1/shahs3/users/preskaa/AMLproteogenomics/data/APS028_AML_PG2_analysis/fragpipe_workflows/F1_trypsin_lysc_DIA.workflow
manifest=/data1/shahs3/users/preskaa/AMLproteogenomics/data/APS028_AML_PG2_analysis/fragpipe_workflows/F1.fp-manifest
# provide paths to fragpipe config tools, python and diann
config_tools=/data1/kentsisa/fragpipe_ondemand/fragpipe_config_tools
config_python=/data1/kentsisa/fragpipe_ondemand/fragpipe_env/bin/python3.9
config_diann=/admin/software/fragpipe/fragpipe-22.0/tools/diann/1.8.2_beta_8/linux/diann-1.8.1.8
# provide out directory
outdir=/data1/shahs3/users/preskaa/AMLproteogenomics/data/APS028_AML_PG2_analysis/fragpipe_out
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
sif_path=/data1/shahs3/users/preskaa/singularity/fragpipe_22.0.sif
philosopher=/fragpipe_bin/fragPipe-22.0/fragpipe/tools/Philosopher/philosopher-v5.1.1
proteome=/data1/kentsisa/AML_proteogenomics/Proj_B-101-985/F1/experiment/combined.proteome.unique.fasta
PG2_proteome=${outdir}/proteome.fasta
index_table=${outdir}/fasta_header_index.tsv

# fix headers
# need to activate for mono
source activate /data1/kentsisa/fragpipe_ondemand/fragpipe_env
# python /home/preskaa/fragpipe-smk/workflow/scripts/fix_pg2_headers.py ${proteome} ${PG2_proteome} ${index_table}

# add decoys and contaminants
# singularity exec -e -B /data1/shahs3:/data1/shahs3 \
#   -B /data1/kentsisa:/data1/kentsisa ${sif_path} bash -c "
#   ${philosopher} workspace --init --nocheck &&
#   ${philosopher} database --custom ${PG2_proteome} --contam --contamprefix &&
#   ${philosopher} workspace --clean --nocheck
# "

# this command launches fragpipe
# if you want to do a "dry-run", which just tests if everything is set-up properly
# before you launch the actual job, uncomment the dry-run option below
fragpipe=/fragpipe_bin/fragPipe-22.0/fragpipe/bin/fragpipe

 singularity exec -e -B /data1/shahs3:/data1/shahs3 \
   -B /data1/kentsisa:/data1/kentsisa ${sif_path} bash -c "
${fragpipe} --headless \
  --workflow ${workflow} \
  --manifest ${manifest} \
  --config-tools-folder ${config_tools} \
  --workdir ${outdir} \
  --threads ${threads} \
  --config-diann ${config_diann} \
  --config-python ${config_python} \
  --ram ${memory} \
#  --dry-run
"
