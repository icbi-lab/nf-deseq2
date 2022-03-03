nextflow.enable.dsl=2

out_dir = file(params.resDir)
mode = params.publish_dir_mode

process PCA {
    conda "conda-forge::python=3.8 conda-forge::pandas=1.2.0 conda-forge::scikit-learn=1.0.2 conda-forge::plotly=5.5.0 conda-forge::numpy=1.19.5 conda-forge::python-kaleido=0.2.1"

    input:
        path(count_matrix_path)
        path(sample_ann_path)
        val(colour_colum_pca)
        val(annotation_columns_counts)
        val(annotation_columns_samplesheet)
        val(prefix)

    output:
        path("${prefix}PCA_plot.png"), emit: pca_plot

    script:
    """
    PCA.py -I ${count_matrix_path} -IS ${sample_ann_path} -O ${prefix}PCA_plot.png  -CC ${colour_colum_pca} -AC ${annotation_columns_counts} -A ${annotation_columns_samplesheet}
    """
}

