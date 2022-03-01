#!/usr/bin/env nextflow

nextflow.preview.dsl=2

process goTopGo {

  conda "conda-forge::r-base=4.1.2 bioconda::bioconductor-topgo bioconda::bioconductor-org.hs.eg.db conda-forge::r-ggplot2"

  input:
    path(DESeq2_in)
  output:
    path("topGO_GO-BP_ORA_weight01_fisher_up.txt")
    path("topGO_GO-BP_ORA_weight01_fisher_dn.txt")
  script:
    """
    GOTOPGO.R ${DESeq2_in}
    """
}
