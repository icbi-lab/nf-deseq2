nextflow.enable.dsl=2

out_dir = file(params.resDir)
mode = params.publish_dir_mode

process VolcanoPlot {
    //Packages dependencies
        conda "conda-forge::python=3.8 bioconda::bioconductor-enhancedvolcano=1.12.0 conda-forge::r-dplyr=1.0.7 conda-forge::r-tibble=3.1.6 conda-forge::r-readr=2.1.1 conda-forge::r-argparser=0.7.1 conda-forge::r-conflicted=1.1.0"
    publishDir "${out_dir}", mode: "$mode"

        input:
        path de_res
	      path genes_of_interest

    output:
        path("*.pdf"), emit: volcano
        path('Volcano_plot_summary.txt'), emit: summary

	script:
	"""
    VolcanoPlots_script.R $de_res $genes_of_interest > Volcano_plot_summary.txt
	"""
}