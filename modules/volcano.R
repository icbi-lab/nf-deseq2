#!/usr/bin/Rscript
args = commandArgs(trailingOnly = TRUE)

if (length(args) == 0) {
  stop("Need three input arguments!", call.=FALSE)
} else if (length(args) == 2) {
  # default output file
  args[3] = "./tests/testdata/example_nfcore/volcano.pdf"
}

library("readxl")
library("dplyr")
library("EnhancedVolcano")

# Import DESeq2 output + genes of interest
sigGenes <- read_excel(args[1])
genes_of_interest <- read.delim(args[2], header = TRUE)


# make volcano plot using "EnhancedVolcano" package
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
  
  pdf(file = args[3], paper = "a4r", width = 297, height = 210)
  print(plot)
  dev.off()
}

make_volcano(sigGenes, genes_of_interest$gene_name) %>% save_A4_pdf

#save_A4_pdf(make_volcano(sigGenes, genes_of_interest$gene_name))