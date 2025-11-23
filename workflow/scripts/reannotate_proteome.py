#!/usr/bin/env python3
import pandas as pd
from Bio import SeqIO
import numpy as np

"""
generate proteome from PG2 results in UniProt format
"""
def make_seqdict(input_file):
    """
    make a dict of sequences from fasta file
    :param input_file: fasta file
    :return: dictionary of sequences with ORFs
    """
    seq_dict = {}
    with open(input_file, "r") as f:
        for record in SeqIO.parse(f, "fasta"):
            seq_dict[record.description] = str(record.seq)
    return seq_dict

def seqdict2df(sp_dict):
    sp_dat = pd.DataFrame.from_dict(sp_dict, orient="index")
    sp_dat = sp_dat.reset_index()
    sp_dat.columns = ["header", "seq"]
    return sp_dat

def stringtie_orf(header, tx_id, haplotype):
    _, protein_id, _ = header.split()
    transdecoder_ORF = protein_id.split(".p")[1]
    ORF_id = f"{tx_id}.h{haplotype}.p{transdecoder_ORF}"
    return ORF_id

## inputs
gffcmp_hap1 = snakemake.input["gffcmp_hap1"]
gffcmp_hap2 = snakemake.input["gffcmp_hap2"]
input_proteome = snakemake.input["proteome"]
output_proteome = snakemake.output["proteome"]
output_protein_table = snakemake.output["protein_table"]
swissprot_fasta = snakemake.params["swissprot_fasta"]

# gffcmp_hap1 = "/data1/shahs3/users/preskaa/AMLproteogenomics/data/APS028_AML_PG2_analysis/fragpipe23_reannotated_out/F83/PG2_restrictive/transcriptome/haplotype_1/transcript.gffcmp.transcripts.gtf.tmap"
# gffcmp_hap2 = "/data1/shahs3/users/preskaa/AMLproteogenomics/data/APS028_AML_PG2_analysis/fragpipe23_reannotated_out/F83/PG2_restrictive/transcriptome/haplotype_2/transcript.gffcmp.transcripts.gtf.tmap"
# input_proteome = "/data1/kentsisa/AML_proteogenomics/PG2_restrictive/Proj_B-101-986/F83/experiment/combined.proteome.unique.fasta"
# output_proteome = "/data1/shahs3/users/preskaa/AMLproteogenomics/data/APS028_AML_PG2_analysis/reannotation_test/test.proteome.fasta"
# output_protein_table = "/data1/shahs3/users/preskaa/AMLproteogenomics/data/APS028_AML_PG2_analysis/reannotation_test/test.proteome.tsv"
# swissprot_fasta = "/data1/shahs3/reference/ref-sarcoma/blast_databases/swissprot_human_250206/2025-02-06-reviewed-isoforms-UP000005640.fas"

# load in gffcmp results
gffcmp_df = pd.read_csv(gffcmp_hap1, sep="\t")
# tag haplotype
gffcmp_df["haplotype"] = 1
# load in second haplotype
temp = pd.read_csv(gffcmp_hap2, sep="\t")
temp["haplotype"] = 2
gffcmp_df = pd.concat([gffcmp_df, temp])
# now load in swissprot fasta
sp_dict = make_seqdict(swissprot_fasta)
sp_dat = seqdict2df(sp_dict)
# account for duplicate sequences in swissprot
sp_dat = sp_dat.drop_duplicates(keep="first", subset="seq")
# convert our PG2 proteome to a dataframe
pg2_dict = make_seqdict(input_proteome)
pg2_dat = seqdict2df(pg2_dict)
# merge on sequence, keeping only detected sequences
mergedat = pd.merge(pg2_dat, sp_dat, on=["seq"], suffixes=("_pg2", "_sp"), how="left", indicator=True)
# pull out haplotype info so we can merge this into the dataframe
haplotypes = []
tx_ids = []
for _, row in mergedat.iterrows():
    header = row["header_pg2"]
    # fusions don't encode haplotype info in headers
    if header.startswith("pg|fusion"):
        tx_ids.append("fusion")
        haplotypes.append(-1)
    # determine haplotype
    elif header.startswith("pg|MSTRG"):
        _, protein_id, loc = header.split()
        tx_id = protein_id.split(".p")[0]
        haplotype = loc.split("_")[0]
        haplotypes.append(int(haplotype))
        tx_ids.append(tx_id)
    else:
        print(f"unhandled case: {header}")
# add the haplotype and tx_id to the merged dataframe
mergedat["haplotype"] = haplotypes
mergedat['haplotype'] = mergedat['haplotype'].astype('Int64')
mergedat["qry_id"] = tx_ids
# merge with gffcmp information
merge_gffcmp_df = pd.merge(mergedat, gffcmp_df, on = ["qry_id", "haplotype"], how="left")

### proteoform count for novel proteoforms (with PG accession numbers)
neogene_idx = 1
neotranscript_idx = 1
proteoform_idx = 1
fusion_idx = 1
# build protein table
table_data = []
with open(output_proteome, "w+") as outfile:
    for _, row in merge_gffcmp_df.iterrows():
        header = row["header_pg2"]
        haplotype = row["haplotype"]
        # give fusions no haplotype
        if haplotype == -1:
            haplotype = np.nan
        # first, build ORF annotation for different cases
        ref_gene_id = row["ref_gene_id"]
        ref_id = row["ref_id"]
        qry_id = row["qry_id"]
        classcode = row["class_code"]
        fusion_status = False
        # reannotate exact matches to known transcripts
        if classcode == "=":
            gene = ref_gene_id
            tx_id = ref_id
        # reannotate splice isoforms
        elif classcode != "u" and qry_id != "fusion":
            gene = ref_gene_id
            tx_id = f"StrgTx{neotranscript_idx}"
            neotranscript_idx += 1
        # reannotate fusion genes
        elif qry_id == "fusion":
            gene = header.split(".")[1]
            tx_id = f"ArribaFusion{fusion_idx}"
            fusion_status = True
        # last but not least, deal with neogenes
        else:
            gene = f"StrgGene{neogene_idx}"
            tx_id = f"StrgTx{neotranscript_idx}"
            neotranscript_idx += 1
            neogene_idx += 1
        # build protein fasta
        # if exact match to swissprot, give it a proper swissprot header
        if row["_merge"] == "both":
            sp_header = row["header_sp"]
            outfile.write(f">{sp_header}\n")
            # retain protein id
            temp = sp_header.split("|")
            protein_id = temp[1]
            sp_status = True
            ORF_id = "n/a"
        # if it's a newly predicted ORF give it a trembl header (kind of)
        else:
            # if it's a fusion, give a fusion protein id
            if row["qry_id"] == "fusion":
                protein_id = f"GF{fusion_idx}"
                ORF_id = f"{tx_id}.p{fusion_idx}"
                fusion_idx += 1
            # else, give it a PG2 id
            else:
                protein_id = f"PG{proteoform_idx}"
                ORF_id = stringtie_orf(header, tx_id, int(haplotype))
                proteoform_idx += 1
            new_header = f">tr|{protein_id}|{ORF_id} PG3 predicted ORF OS=Homo sapiens OX=9606 GN={gene} PE=2\n"
            # determined not to have an exact match in swissprot
            sp_status = False
            outfile.write(new_header)
        # write sequences
        outfile.write(f"{row['seq']}\n")
        # append all info to index table
        table_data.append({
            "Protein": protein_id,
            "Transcript": tx_id,
            "ORF": ORF_id,
            "Gene": gene,
            "PG2_header": header,
            "haplotype": haplotype,
            "fusion": fusion_status,
            "SwissProt": sp_status,

        })

    # write table
    protein_table = pd.DataFrame(table_data)
    protein_table.to_csv(output_protein_table, sep="\t", index=None)

