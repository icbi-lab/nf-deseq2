#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

### BioQC
library("readr")
library("BioQC")

# Expression data
tpm_mat = read_tsv(args[1])
tpm_mat$gene_name

tpm_mat_2 = tpm_mat
tpm_mat_2$gene_id = NULL
tpm_mat_2$gene_name = NULL
tpm_mat_2 = as.matrix.data.frame(tpm_mat_2)
row.names(tpm_mat_2) = tpm_mat$gene_name

# Sample_sheet
all_samples = read_csv(args[2])

# Read in markers
gmtFile = system.file(args[3], package="BioQC")
gmt <- readGmt(gmtFile)

# Start analysis
bioqcRes = wmwTest(tpm_mat_2, gmt)

# create heatmap
bioqcResFil <- filterPmat(bioqcRes, 1E-6)
bioqcAbsLogRes <- absLog10p(bioqcResFil)

jpeg(file="Bioqc_heatmap.jpg", width=1000, height=500)
heatmap(bioqcAbsLogRes, Colv=NA, Rowv=TRUE,
        cexRow=1, scale="row",
        labCol=1:ncol(bioqcAbsLogRes))
dev.off()
