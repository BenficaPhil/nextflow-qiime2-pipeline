process AlphaRarefaction {
    publishDir params.output_qzv, pattern: "*.qzv", mode: 'copy'

    input:
    path filtered_table
    path rooted_tree
    path metadata

    output:
    path "alpha-rarefaction.qzv", emit: qzv

    script:
    """
    module load qiime2/${params.qiime2_version}

    qiime diversity alpha-rarefaction \
        --i-table ${filtered_table} \
        --i-phylogeny ${rooted_tree} \
        --p-max-depth 20000 \
        --m-metadata-file ${metadata} \
        --o-visualization alpha-rarefaction.qzv
    """
}