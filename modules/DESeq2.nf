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

	conda "conda-forge::python=3.8"
    publishDir "${out_dir}", mode: "$mode"
	input:
        path p1
	    path p2

    output:
        file("*.tsv")
        path 'DESeq2_result.txt'

	script:
	"""
    Rscript $projectDir/DESeq2_script.R $p1 $p2 --wdir `echo \$PWD` > DESeq2_result.txt
	"""
}


workflow {

    data_count = channel.fromPath("${input_count}")
	data_sample = channel.fromPath("${input_sample}")
    DESeq2(data_count,data_sample)
}
