#!/usr/bin/env Rscript
'
Usage:
  clusterprofiler_ora.R --de_res=<de_res> --pathways=<pathways> --prefix=<prefix> [options]

Mandatory arguments:
  --de_res=<de_res>            TopTable from DESeq2 in TSV format
  --pathways=<pathways>        Pathway database to test against. One of "KEGG", "Reactome", "WikiPathway", "GO_BP", "GO_MF"
  --prefix=<prefix>            Prefix for output filenames

Optional arguments:
  --de_fdr_cutoff=<fdr>        Consider genes with an fdr smaller than this value as the positive group of the ORA test [default: 0.1]
  --pathway_p_cutoff=<p>       Make plot if there is a least one pathway enriched with a p value smaller than this [default: 0.05]
  --results_dir=<dir>          Output directory [default: ./]
' -> doc

library(conflicted)
library(docopt)
arguments <- docopt(doc, version = "0.1")
print(arguments)

library(clusterProfiler)
library(org.Hs.eg.db)
library(dplyr)
library(ggplot2)
library(ReactomePA)
library(readr)
conflict_prefer("select", "dplyr")
conflict_prefer("filter", "dplyr")



#' Function definitions for the different databases
ora_tests <- list(
  "KEGG" = function(genes, universe) {
    enrichKEGG(
      gene         = genes,
      universe     = universe,
      organism     = "hsa",
      pvalueCutoff = 0.05
    )
  },
  "Reactome" = function(genes, universe) {
    enrichPathway(
      gene = genes,
      organism = "human",
      universe = universe,
      pvalueCutoff = 0.05,
      readable = TRUE
    )
  },
  "WikiPathway" = function(genes, universe) {
    enrichWP(
      gene = genes,
      universe = universe,
      organism = "Homo sapiens",
      pvalueCutoff = 0.05
    )
  },
  "GO_BP" = function(genes, universe) {
    enrichGO(
      gene = genes,
      universe = universe,
      keyType = "ENTREZID",
      OrgDb = org.Hs.eg.db,
      ont = "BP",
      pAdjustMethod = "BH",
      qvalueCutoff = 0.05,
      minGSSize = 10
    )
  },
  "GO_MF" = function(genes, universe) {
    enrichGO(
      gene = genes,
      universe = universe,
      keyType = "ENTREZID",
      OrgDb = org.Hs.eg.db,
      ont = "MF",
      pAdjustMethod = "BH",
      qvalueCutoff = 0.05,
      minGSSize = 10
    )
  }
)

#' Estimate reasonable size for the heatmap plots based on the number of significant pathways
#'
#' @params p result of clusterProfiler::cnetplot
get_heatplot_dims <- function(p) {
  nr_gene <- length(unique(p$data$Gene))
  nr_cat <- length(unique(p$data$categoryID))

  hp_width <- min(nr_gene * 0.25, 40)
  hp_height <- min(nr_cat * 0.25, 40)

  return(c(hp_width, hp_height))
}



# Retrieve and validate Parameters
de_res <- read_tsv(arguments$de_res)
pathways <- arguments$pathways
de_fdr_cutoff <- arguments$de_fdr_cutoff
pathway_p_cutoff <- arguments$pathway_p_cutoff
prefix <- arguments$prefix
results_dir <- arguments$results_dir
stopifnot(pathways %in% names(ora_tests))

# full list with ENTREZIDs added
hgnc_to_entrez <- AnnotationDbi::select(
  org.Hs.eg.db, unique(de_res$gene_name),
  keytype = "SYMBOL",
  columns = c("ENTREZID")
)
de_res_entrez <- de_res |> inner_join(hgnc_to_entrez, by = c("gene_name" = "SYMBOL"))
universe <- unique(de_res_entrez$ENTREZID)

# list of significant genes for ORA test
de_res_sig <- de_res_entrez |> filter(padj < de_fdr_cutoff)
de_foldchanges <- de_res_sig$log2FoldChange
names(de_foldchanges) <- de_res_sig$ENTREZID

message(paste0("Performing ", pathways, " ORA-test..."))
test_fun <- ora_tests[[pathways]]
ora_res <- test_fun(de_res_sig$ENTREZID, universe)
ora_res <- setReadable(ora_res, OrgDb = org.Hs.eg.db, keyType = "ENTREZID")
res_tab <- as_tibble(ora_res@result)

write_tsv(res_tab, file.path(results_dir, paste0(prefix, "_ORA_", pathways, ".tsv")))

if (min(res_tab$p.adjust) < pathway_p_cutoff) {
  p <- dotplot(ora_res, showCategory = 40)

  ggsave(file.path(results_dir, paste0(prefix, "_ORA_", pathways, "_dotplot.pdf")), plot = p, width = 15, height = 10)

  p <- cnetplot(ora_res,
    categorySize = "pvalue", showCategory = 5,
    foldChange = de_foldchanges,
    vertex.label.font = 6
  )

  ggsave(file.path(results_dir, paste0(prefix, "_ORA_", pathways, "_cnetplot.pdf")), plot = p, width = 15, height = 12)

  p <- heatplot(ora_res, foldChange = de_foldchanges, showCategory = 40) +
    scale_fill_gradient2(midpoint = 0, low = "blue4", mid = "white", high = "red4")
  hp_dims <- get_heatplot_dims(p)

  ggsave(file.path(results_dir, paste0(prefix, "_ORA_", pathways, "_heatplot.pdf")), plot = p, width = hp_dims[1], height = hp_dims[2])
} else {
  message(paste0("Warning: No significant enrichment in ", pathways, " ORA analysis. "))
}
