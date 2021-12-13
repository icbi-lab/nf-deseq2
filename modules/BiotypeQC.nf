#!/usr/bin/env nextflow

/*
BioQC is a is a R/Bioconductor package to detect tissue heterogeneity in gene expression data
*/

params.gene_expression = "/home/ausserh/myScratch/Salmon_test.txt"
params.samplesheet = "/home/ausserh/testMatrix.tsv"
params.marker = "extdata/exp.tissuemark.affy.roche.symbols.gmt"


process 'BioQC' {

  conda 'bioconductor-bioqc r-readr'
  publishDir "/home/ausserh/BioQC_test", mode: 'copy'

  input:
  path gene_expression from params.gene_expression
  path samplesheet from params.samplesheet
  val marker from params.marker
    
  output:
  path ('*.jpg')
    
  script:
    """
    Rscript /data/scratch/ausserh/nf-deseq2/modules/BioQC.R $gene_expression $samplesheet $marker
    """
}