#!/usr/bin/env Rscript
'
Usage:
  VolcanoPlots_script.R --de_res=<de_res> --goi=<goi> --prefix=<prefix> [options]

Mandatory arguments:
  --de_res=<de_res>           TopTable from DESeq2 in TSV format
  --goi=<goi>                 Genes of interest in txt format
  --prefix=<prefix>           Prefix for output filenames

Optional arguments:
  --pCutoff=<pCutoff>         Cut-off for statistical significance [default: 0.05]
  --FCcutoff=<FCcutoff>       Cut-off for absolute log2 fold-change [default: 2]
  --results_dir=<dir>         Output directory [default: ./]
' -> doc

library(conflicted)
library(docopt)
arguments <- docopt(doc, version = "0.1")
print(arguments)

library(readr)
library(dplyr)
library(EnhancedVolcano)


# Load parameters
de_res <- read_tsv(arguments$de_res)
goi <- read_lines(arguments$goi, skip = 1)
pCutoff <- as.numeric(arguments$pCutoff)
FCcutoff <- as.numeric(arguments$FCcutoff)
prefix <- arguments$prefix
results_dir <- arguments$results_dir


# Make volcano plots using "EnhancedVolcano" package

message(paste0("Drawing volcano plots..."))

p <- EnhancedVolcano(
  toptable = de_res,
  lab = NA,
  x = "log2FoldChange",
  y = "pvalue",
  pCutoff = pCutoff,
  FCcutoff = FCcutoff,
  title = paste0(prefix, "_volcano_plot"),
  caption = paste0("fold change cutoff: ", pCutoff, ", p-value cutoff: ", FCcutoff)
)

ggsave(file.path(results_dir, paste0(prefix, "_volcano_plot.pdf")), plot = p, width = 297, height = 210, units = "mm")

p <- EnhancedVolcano(
  toptable = de_res,
  lab = NA,
  x = "log2FoldChange",
  y = "padj",
  pCutoff = pCutoff,
  FCcutoff = FCcutoff,
  title = paste0(prefix, "_volcano_plot"),
  caption = paste0("fold change cutoff: ", pCutoff, ", adj.p-value cutoff:: ", FCcutoff)
)

ggsave(file.path(results_dir, paste0(prefix, "_volcano_padj.pdf")), plot = p, width = 297, height = 210, units = "mm")

p <- EnhancedVolcano(
  toptable = de_res,
  lab = de_res$gene_name,
  selectLab = goi,
  x = "log2FoldChange",
  y = "padj",
  pCutoff = pCutoff,
  FCcutoff = FCcutoff,
  drawConnectors = TRUE,
  title = paste0(prefix, "_volcano_plot_genes_of_interest"),
  caption = paste0("fold change cutoff: ", pCutoff, ", adj.p-value cutoff:: ", FCcutoff)
)

ggsave(file.path(results_dir, paste0(prefix, "_volcano_padj_GoI.pdf")), plot = p, width = 297, height = 210, units = "mm")

