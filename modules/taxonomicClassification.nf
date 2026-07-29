process TaxonomicClassification {
    publishDir params.output_taxonomy, pattern: "*.qza", mode: 'copy'
    publishDir params.output_qzv, pattern: "*.qzv", mode: 'copy'

    input:
    path database
    path rep_seqs
    path asv_table
    path metadata

    output:
    path "*.qza", emit: qza
    path "*.qzv", emit: qzv

    script:
    """
    module load qiime2/${params.qiime2_version}

    qiime feature-classifier classify-sklearn \
        --i-classifier ${database} \
        --i-reads ${rep_seqs} \
        --o-classification taxonomy_${params.tax_database}.qza

    qiime metadata tabulate \
        --m-input-file taxonomy_${params.tax_database}.qza \
        --o-visualization taxonomy_${params.tax_database}.qzv

    qiime taxa barplot \
        --i-table ${asv_table} \
        --i-taxonomy taxonomy_${params.tax_database}.qza \
        --m-metadata-file ${metadata} \
        --o-visualization taxa-bar-plots.qzv
    """
}