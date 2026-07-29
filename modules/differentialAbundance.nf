process DifferentialAbundance_ANCOMBC2 {
    publishDir params.output_ancombc2, pattern: "*.{qza,txt}", mode: 'copy'

    input:
    path filtered_table
    path metadata
    path taxonomy
    path genus_table

    output:
    path "*.qza", emit: qza
    path "*.qzv", emit: qzv

    script:
    """
    module load qiime2/${params.qiime2_version}

    qiime composition ancombc2 \
        --i-table ${filtered_table} \
        --m-metadata-file ${metadata} \
        --p-fixed-effects-formula ${params.model_formula} \
        --p-reference-levels '${params.reference_levels}' \
        --o-ancombc2-output ancombc2-asv-results.qza
    
    qiime composition ancombc2-visualizer \
        --i-data ancombc2-asv-results.qza \
        --i-taxonomy ${taxonomy} \
        --o-visualization ancombc2-asv-barplot.qzv

    qiime composition ancombc2 \
        --i-table ${genus_table} \
        --m-metadata-file ${metadata} \
        --p-fixed-effects-formula ${params.model_formula} \
        --p-reference-levels '${params.reference_levels}' \
        --o-ancombc2-output ancombc2-genus-results.qza
    
    qiime composition ancombc2-visualizer \
        --i-data ancombc2-genus-results.qza \
        --i-taxonomy ${taxonomy} \
        --o-visualization ancombc2-genus-barplot.qzv
    """
}