nextflow.enable.dsl=2

def s = """\
        _________________________________________________
        Nextflow DESeq2:

        ▶ Inpu count data matrix: ${params.gene_expression}
        ▶ Input sample annotation data: ${params.samplesheet}
        ▶ result output directory: ${params.resDir}
        _________________________________________________
        """
println s.stripIndent()

out_dir = file(params.resDir)
mode = params.publish_dir_mode

process DESeq2 {
    //Packages dependencies
        conda "conda-forge::python=3.8 bioconda::bioconductor-biocparallel=1.28.0 bioconda::bioconductor-deseq2=1.34.0 bioconda::bioconductor-org.hs.eg.db=3.14.0 conda-forge::r-dplyr=1.0.7 bioconda::bioconductor-ihw=1.22.0 conda-forge::r-tibble=3.1.6 conda-forge::r-readr=2.1.1 conda-forge::r-argparser=0.7.1"
    publishDir "${out_dir}", mode: "$mode"

        input:
        path count_matrix_path
	    path sample_ann_path

    output:
        path("*.tsv"), emit: de_res
        path('DESeq2_result_summary.txt'), emit: summary

	script:
	"""
    DESeq2_script.R $count_matrix_path $sample_ann_path --cpus $task.cpus > DESeq2_result_summary.txt
	"""
}
