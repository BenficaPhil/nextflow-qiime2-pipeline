process GroupedTable {
    publishDir params.output_grouped, pattern: "*.qza", mode: 'copy'

    input:
    path filtered_table
    path metadata

    output:
    path "*.qza", emit: qza

    script:
    """
    module load qiime2/${params.qiime2_version}

    qiime feature-table group \
        --i-table ${filtered_table} \
        --m-metadata-file ${metadata} \
        --m-metadata-column ${params.analysis_group} \
        --p-axis sample \
        --p-mode sum \
        --o-grouped-table grouped-table-${params.analysis_group}.qza
    """
}