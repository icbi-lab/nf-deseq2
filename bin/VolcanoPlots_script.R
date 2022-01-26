#!/usr/bin/env Rscript

# Import library
library("conflicted")
library("dplyr")
library("EnhancedVolcano")
library("tibble")
library("readr")
library("argparser", quietly = TRUE)

# Create a parser
p <- arg_parser("Input to draw Volcano plots")

# Add command line arguments
p <- add_argument(p, "de_res", help = "DESeq2 differential expression results as tsv file", type = "character")
p <- add_argument(p, "genes_of_interest", help = "txt file containing an arbitrary number of genes to be plotted", type = "character")
p <- add_argument(p, "--resDir", help = "Output result directory", default = "./results")
p <- add_argument(p, "--prefix", help = "Prefix of result file", default = "test")

# Parse the command line arguments
argv <- parse_args(p)


results_dir <- argv$resDir
prefix <- argv$prefix

# Reading the DESeq2 diff_res tsv file and genes of interest txt file
de_res <- read_tsv(argv$de_res)
genes_of_interest <- read.table(argv$genes_of_interest$gene_name) |> as.vector()


# Make volcano plot using "EnhancedVolcano" package
de_res <- de_res[!is.na(de_res$padj), ]
de_res$label <- ifelse(de_res$gene_name %in% genes_of_interest, de_res$gene_name, NA)

y_max <- -log10(min(de_res$padj, na.rm = T))
x_min <- -ceiling(abs(min(de_res$log2FoldChange, na.rm = T)))
x_max <- ceiling(max(de_res$log2FoldChange, na.rm = T))

p <- EnhancedVolcano(de_res,
                     lab = de_res$label,
                     x = 'log2FoldChange',
                     y = 'padj',
                     xlim = c(x_min, x_max),
                     ylim = c(0, y_max),
                     title = prefix,
                     pCutoff = 0.05,
                     FCcutoff = 2,
                     drawConnectors = TRUE)

# save single plot as pdf
save_A4_pdf <- function(plot){

pdf(file = file.path("./", paste0(prefix, "_Volcano_plot.pdf"),
                     paper = "a4r", width = 297, height = 210))
print(plot)
dev.off()
}


save_A4_pdf(p)

