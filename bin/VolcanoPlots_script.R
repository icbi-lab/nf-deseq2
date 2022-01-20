#!/usr/bin/env Rscript

# Import library
library("dplyr")
library("EnhancedVolcano")
library("tibble")
library("readr")
library("argparser", quietly = TRUE)

# Create a parser
p <- arg_parser("Input to draw Volcano plots")

# Add command line arguments
p <- add_argument(p, "resIHW", help = "DESeq2 differential expression results as tsv file", type = "character")
p <- add_argument(p, "genes_of_interest", help = "txt file containing an arbitrary number of genes to be plotted", type = "character")
p <- add_argument(p, "--resDir", help = "Output result directory", default = "./results")
p <- add_argument(p, "--prefix", help = "Prefix of result file", default = "test")

# Parse the command line arguments
argv <- parse_args(p)


results_dir <- argv$resDir
prefix <- argv$prefix

# Reading the DESeq2 diff_res tsv file and genes of interest txt file
resIHW <- read_tsv(argv$resIHW)
genes_of_interest <- read_delim(argv$genes_of_interest) |> as.vector()


# Make volcano plot using "EnhancedVolcano" package
make_volcano <- function(dat, label_subset) {

new_p_val <- dat[!dat$padj == 0, ]$padj[1]

dat <- dat[!is.na(dat$padj),]
dat[dat$padj == 0, ]$padj <- new_p_val

l_sub <- dat[dat$gene_name %in% label_subset, ]
l_sub <- l_sub[l_sub$padj < 0.05, ]$gene_name

l_total <- dat$gene_name
label <- ifelse(l_total %in% l_sub, l_total, NA)

y_max <- -log10(min(dat$padj, na.rm = T))
x_min <- -ceiling(abs(min(dat$log2FoldChange, na.rm = T)))
x_max <- ceiling(max(dat$log2FoldChange, na.rm = T))

p <- EnhancedVolcano(dat,
                     lab = label,
                     x = 'log2FoldChange',
                     y = 'padj',
                     xlim = c(x_min, x_max),
                     ylim = c(0, y_max),
                     title = "",
                     pCutoff = 0.05,
                     FCcutoff = 2,
                     drawConnectors = TRUE)
return(p)
}

# save single plot as pdf
save_A4_pdf <- function(plot){

pdf(file = file.path("./", paste0(prefix, "_Volcano_plot.pdf"),
                     paper = "a4r", width = 297, height = 210))
print(plot)
dev.off()
}


make_volcano(resIHW, genes_of_interest) |> save_A4_pdf

