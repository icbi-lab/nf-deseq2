nextflow.enable.dsl=2

def s = """\
        _________________________________________________
        Nextflow DESeq2:

        ▶ Inpu count data matrix: ${params.countData}
        ▶ Input sample annotation data: ${params.colData}
        ▶ result output directory: ${params.resDir}
        _________________________________________________
        """
println s.stripIndent()

input_count = params.countData
input_sample = params.colData
out_dir = file(params.resDir)
mode = params.publish_dir_mode

process DESeq2 {
    //Packages dependencies
        conda "conda-forge::python=3.8"
        conda "bioconda::bioconductor-biocparallel=1.28.0"
        conda "bioconda::bioconductor-deseq2=1.34.0"
        conda "bioconda::bioconductor-org.hs.eg.db=3.14.0"
        conda "conda-forge::r-dplyr=1.0.7"
        conda "bioconda::bioconductor-ihw=1.22.0"
        conda "conda-forge::r-tibble=3.1.6"
        conda "conda-forge::r-readr=2.1.1"
        conda "conda-forge::r-argparser=0.7.1"
    publishDir "${out_dir}", mode: "$mode"

        input:
        path count_matrix_path
	    path sample_ann_path

    output:
        file("*.tsv")
        path 'DESeq2_result_summary.txt'

	script:
	"""
    DESeq2_script.R $count_matrix_path $sample_ann_path --cpus $task.cpus > DESeq2_result_summary.txt
	"""
}


workflow {

    data_count = channel.fromPath("${input_count}")
	data_sample = channel.fromPath("${input_sample}")
    DESeq2(data_count,data_sample)
}
