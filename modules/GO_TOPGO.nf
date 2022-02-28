#!/usr/bin/env nextflow

nextflow.preview.dsl=2

process goTopGo {
  input:
    file DESeq2.tsv
  output:
    file topGO_GO_up.txt
    file topGO_GO_dn.txt
  script:
    """
    ../bin/GOTOPGO.R DESeq2.tsv
    """
}
