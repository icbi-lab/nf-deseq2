
process HELLO {

    // conda "conda-forge::python=3.8"

    input:
    path samplesheet
    path gene_expression
    path genes_of_interest

    output:
    path("*.txt"), emit: hello

    script:
    """
    cat <<-END > test.txt
    This is a dummy process for test purposes.
    The input files of the pipeline are:
        samplesheet: ${samplesheet.name}
        gene expression matrix: ${gene_expression.name}
        genes of interest: \$(tr "\\n" " " < ${genes_of_interest})
    END
    """
}
