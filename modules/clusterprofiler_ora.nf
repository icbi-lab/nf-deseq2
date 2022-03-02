nextflow.enable.dsl = 2

process CLUSTERPROFILER_ORA {
    conda "conda-forge::r-base=4.1.2 conda-forge::r-conflicted=1.1.0 bioconda::bioconductor-clusterprofiler=4.2.0 " +
        "bioconda::bioconductor-org.hs.eg.db=3.14.0 conda-forge::dplyr=1.0.7 conda-forge::ggplot2=3.3.5 " +
        "conda-forge::r-docopt=0.7.1 bioconda::bioconductor-do.db=2.9=r41hdfd78af_12 conda-forge::r-readr=2.1.1 " +
        "bioconda::bioconductor-reactomepa=1.38.0 conda-forge::r-ggnewscale=0.4.5 conda-forge::r-reshape2=1.4.4"

    input:
    path(de_res)
    each(pathways)
    val(prefix)
    val(de_fdr_cutoff)

    output:
    path("${prefix}_ORA_${pathways}.tsv"), emit: ora_table
    path("*.pdf"), emit: plots, optional: true

    script:
    """
    clusterprofiler_ora.R \\
        --de_res=${de_res} \\
        --pathways=${pathways} \\
        --prefix=${prefix} \\
        --de_fdr_cutoff=${de_fdr_cutoff}
    """
}
