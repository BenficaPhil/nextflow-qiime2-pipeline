process FilterASVTable {
    publishDir params.output_filtered, pattern: "*.qza", mode: 'copy'
    publishDir params.output_qzv, pattern: "*.qzv", mode: 'copy'
    
    input:
    path asv_table
    path taxonomy
    path metadata

    output:
    path "filtered-table.qza", emit: filtered_table
    path "*-frequencies.qza", emit: qza
    path "*.qzv", emit: qzv

    script:
    """
    module load qiime2/${params.qiime2_version}

    qiime taxa filter-table \
        --i-table ${asv_table} \
        --i-taxonomy ${taxonomy} \
        --p-exclude mitochondria,chloroplast,Unassigned \
        --o-filtered-table filtered-table.qza

    qiime feature-table summarize \
        --i-table filtered-table.qza \
        --m-metadata-file ${metadata} \
        --o-feature-frequencies filtered-asv-frequencies.qza \
        --o-sample-frequencies filtered-sample-frequencies.qza \
        --o-summary filtered-table.qzv

    qiime taxa barplot \
        --i-table filtered-table.qza \
        --i-taxonomy ${taxonomy} \
        --m-metadata-file ${metadata} \
        --o-visualization filtered-taxa-bar-plots.qzv
    """
}