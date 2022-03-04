#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/*
BioQC is a is a R/Bioconductor package to detect tissue heterogeneity in gene expression data
*/

process 'BioQC' {

  conda 'conda-forge::r-base=4.0 conda-forge::r-readr bioconda::bioconductor-bioqc'

  input:
  path gene_expression
  path samplesheet
    
  output:
  path ('Bioqc_heatmap.jpg'), emit: heatmap
    
  script:
    """
    BioQC.R $gene_expression $samplesheet extdata/exp.tissuemark.affy.roche.symbols.gmt
    """
}