from datetime import datetime

"""
rules for running Fragpipe's DIA_SpecLib_Quant workflow
"""
localrules: create_manifest, create_workflow

def _get_diafilepath(wildcards):
    df = pd.read_csv(samplesheet,sep="\t")
    if wildcards.db == "swissprot":
        df1 = pd.read_csv(norm_samplesheet, sep="\t")
        df = pd.concat([df, df1])
    # get path for sample
    temp = df[df["individual_id"] == wildcards.sample]
    directory = list(temp["directory"])[0]
    DIA_file = list(temp["DIA_file"])[0]
    _, DIA_file = DIA_file.split(" ")
    return os.path.join(directory, DIA_file)

# create manifest and a temp directory for fragpipe
rule create_manifest:
    input:
        dia_filepath=_get_diafilepath
    output:
        manifest = os.path.join(workflow_dir, "{db}",
            "{sample}.fp-manifest"),
        hardlink = temp(os.path.join(out_dir, "{sample}",
            "{db}", "temp", "{sample}.raw")),
    params:
        hardlink_dir= os.path.join(out_dir,"{sample}",
            "{db}","temp")
    resources:
        mem_mb = 4000,
        time = 20,
    container:
        "docker://quay.io/preskaa/proteomics:v240915"
    script:
        "../scripts/write_dia_manifest.py"

# add decoys and contaminants to PG2 proteomes
rule add_decoys_contams:
    input:
        proteome = os.path.join(out_dir,"{sample}","{db}","proteome.fasta")
    output:
        proteome = os.path.join(out_dir, "{sample}", "{db}",
            "decoys-contam-proteome.fasta.fas")
    params:
        philosopher="/fragpipe_bin/fragpipe-23.0/fragpipe-23.0/tools/Philosopher/philosopher-v5.1.1",
        tmpdir=os.path.join(out_dir, "{sample}", "{db}"),
        date = datetime.today().strftime('%Y-%m-%d')
    resources:
        mem_mb = 8000,
        time = 360, # increased for retries default 120
    threads: 1,
    container:
        "/data1/shahs3/users/preskaa/singularity/fragpipe_23.0.sif"
    shell:
        """
        cd {params.tmpdir} &&
        {params.philosopher} workspace --init --nocheck &&
        {params.philosopher} workspace --temp {params.tmpdir}
        {params.philosopher} database --custom {input.proteome} --contam --contamprefix &&
        {params.philosopher} workspace --clean --nocheck &&
        mv {params.date}-decoys-contam-proteome.fasta.fas {output.proteome}
        """

rule create_workflow:
    input:
        database = os.path.join(out_dir,"{sample}","{db}",
            "decoys-contam-proteome.fasta.fas"),
        workflow = "fragpipe_workflows/fragpipe23_trypsin_dia_speclib_quant.workflow"
    output:
        workflow = os.path.join(workflow_dir, "{db}",
            "{sample}.workflow")
    resources:
        mem_mb = 4000,
        time = 10,
    threads: 1,
    container:
        "docker://quay.io/preskaa/proteomics:v240915"
    script:
        "../scripts/write_dia_workflow.py"

# create swissprot workflows
rule swissprot_workflow:
    input:
        database = swissprot_fasta,
        workflow = "fragpipe_workflows/fragpipe23_trypsin_dia_speclib_quant.workflow"
    output:
        workflow = os.path.join(workflow_dir, "swissprot",
            "trypsin_dia_speclib_quant.workflow")
    resources:
        mem_mb = 4000,
        time = 10,
    threads: 1,
    container:
        "docker://quay.io/preskaa/proteomics:v240915"
    script:
        "../scripts/write_dia_workflow.py"


# run fragpipe with our custom docker image

# fetch correct workflow
def _fetch_workflow(wildcards):
    if wildcards.db != "swissprot":
        workflow = os.path.join(workflow_dir, "{db}",
            "{sample}.workflow")
    else:
        workflow = os.path.join(workflow_dir, "swissprot",
            "trypsin_dia_speclib_quant.workflow")
    return workflow
rule run_fragpipe:
    input:
        workflow = _fetch_workflow,
        manifest= os.path.join(workflow_dir, "{db}",
            "{sample}.fp-manifest"),
        hardlink= os.path.join(out_dir,"{sample}",
            "{db}","temp","{sample}.raw")
    output:
        protein_tsv = os.path.join(out_dir,"{sample}","{db}",
            "protein.tsv"),
    params:
        outdir=os.path.join(out_dir,"{sample}","{db}"),
        memory=45, # in GB
        tempdir =  os.path.join(out_dir,"{sample}",
            "{db}","temp"),
        config_tools = fragpipe_config_tools
    threads: 4,
    resources:
        mem_mb = 100000,
        time = 1440 # increased for retries default was 360
    container:
        "/data1/shahs3/users/preskaa/singularity/fragpipe_23.0.sif"
    script:
        "../scripts/run_fragpipe.sh"






