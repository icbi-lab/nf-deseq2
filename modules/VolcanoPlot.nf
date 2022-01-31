nextflow.enable.dsl=2

out_dir = file(params.resDir)
mode = params.publish_dir_mode

process VolcanoPlot {
    //Packages dependencies
    conda "conda-forge::r-base=4.1.2 conda-forge::r-docopt=0.7.1 conda-forge::r-conflicted=1.1.0 conda-forge::r-readr=2.1.1 conda-forge::dplyr=1.0.7 bioconda::bioconductor-enhancedvolcano=1.12.0"
    publishDir "${out_dir}", mode: "$mode"

    input:
        path(de_res)
	      path(goi)
	      val(pCutoff)
	      val(FCcutoff)
	      val(prefix)

    output:
        path("${prefix}_volcano_plot.pdf"), emit: volcano
        path("${prefix}_volcano_padj.pdf"), emit: volcano_padj
        path("${prefix}_volcano_padj_GoI.pdf"), emit: volcano_GoI
        path("*.pdf"), emit: plots, optional: true

	script:
	"""
    VolcanoPlots_script.R \\
    --de_res=${de_res} \\
    --goi=${goi} \\
    --prefix=${prefix} \\
    --pCutoff=${pCutoff} \\
    --FCcutoff=${FCcutoff}
	"""
}
