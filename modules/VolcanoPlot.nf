nextflow.enable.dsl=2

def s = """\
        _________________________________________________
        Nextflow Volcano:

        ▶ Input DESeq2 IHW results: ${params._DESeq2_result.tsv}
        ▶ Input genes of interest: ${params.genes_of_interest}
        ▶ result output directory: ${params.resDir}
        _________________________________________________
        """
println s.stripIndent()

out_dir = file(params.resDir)
mode = params.publish_dir_mode

process VolcanoPlot {
    //Packages dependencies
        conda "conda-forge::python=3.8 bioconda::bioconductor-enhancedvolcano=1.12.0 conda-forge::r-dplyr=1.0.7 conda-forge::r-tibble=3.1.6 conda-forge::r-readr=2.1.1 conda-forge::r-argparser=0.7.1"
    publishDir "${out_dir}", mode: "$mode"

        input:
        path _DESeq2_result.tsv
	    path genes_of_interest.txt

    output:
        file("*.pdf")
        path 'Volcano_plot_summary.txt'

	script:
	"""
    VolcanoPlots_script.R $_DESeq2_result.tsv $genes_of_interest --cpus $task.cpus > Volcano_plot_summary.txt
	"""
}
