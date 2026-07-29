process AlphaBetaDiversity {
    publishDir params.output_adiversity, pattern: "*_vector.qza", mode: 'copy'
    publishDir params.output_adiversity, pattern: "alpha_diversity/*_signficance.qzv", mode: 'copy'
    publishDir params.output_bdiversity, pattern: "*_distance_matrix.qza", mode: 'copy'
    publishDir params.output_bdiversity, pattern: "*_pcoa_results.qza", mode: 'copy'
    publishDir params.output_bdiversity, pattern: "*_emperor.qzv", mode: 'copy'
    publishDir params.output_adiversity, pattern: "beta_diversity/*_signficance.qzv", mode: 'copy'
    publishDir params.output_rarefied, pattern: "rarefied_table.qza", mode: 'copy'

    input:
    path filtered_table
    path rooted_tree
    path metadata

    output:
    path "diversity-core-metrics/*_vector.qza" 
    path "diversity-core-metrics/*_distance_matrix.qza"
    path "diversity-core-metrics/*_pcoa_results.qza"
    path "diversity-core-metrics/*_emperor.qzv"
    path "diversity-core-metrics/rarefied_table.qza"
    path "alpha_diversity/*_signficance.qzv"
    path "beta_diversity/*_signficance.qzv"

    when:
    params.run_diversity == true

    script:
    """
    module load qiime2/${params.qiime2_version}

    qiime diversity core-metrics-phylogenetic \
        --i-phylogeny ${rooted_tree} \
        --i-table ${filtered_table} \
        --p-sampling-depth ${params.sampling_depth} \
        --m-metadata-file ${metadata} \
        --output-dir diversity-core-metrics

    mkdir alpha_diversity beta_diversity

    qiime diversity alpha-group-significance \
        --i-alpha-diversity diversity-core-metrics/shannon_vector.qza \
        --m-metadata-file ${metadata} \
        --o-visualization alpha_diversity/shannon_significance.qzv

    qiime diversity alpha-group-significance \
        --i-alpha-diversity observed_features_vector.qza \
        --m-metadata-file ${metadata} \
        --o-visualization alpha_diversity/observed_features_significance.qzv

    qiime diversity alpha-group-significance \
        --i-alpha-diversity diversity-core-metrics/faith_pd_vector.qza \
        --m-metadata-file ${metadata} \
        --o-visualization alpha_diversity/faith_pd_significance.qzv

    qiime diversity alpha-group-significance \
        --i-alpha-diversity diversity-core-metrics/evenness_vector.qza \
        --m-metadata-file ${metadata} \
        --o-visualization alpha_diversity/evenness_significance.qzv

    qiime diversity beta-group-significance \
        --i-distance-matrix diversity-core-metrics/unweighted_unifrac_distance_matrix.qza \
        --m-metadata-file ${metadata} \
        --m-metadata-column ${params.analysis_group} \
        --p-pairwise \
        --o-visualization beta_diversity/unweighted_unifrac_significance.qzv

    qiime diversity beta-group-significance \
        --i-distance-matrix diversity-core-metrics/weighted_unifrac_distance_matrix.qza \
        --m-metadata-file ${metadata} \
        --m-metadata-column ${params.analysis_group} \
        --p-pairwise \
        --o-visualization beta_diversity/weighted_unifrac_significance.qzv

    qiime diversity beta-group-significance \
        --i-distance-matrix diversity-core-metrics/jaccard_distance_matrix.qza \
        --m-metadata-file ${metadata} \
        --m-metadata-column ${params.analysis_group} \
        --p-pairwise \
        --o-visualization beta_diversity/jaccard_significance.qzv

    qiime diversity beta-group-significance \
        --i-distance-matrix diversity-core-metrics/bray_curtis_distance_matrix.qza \
        --m-metadata-file ${metadata} \
        --m-metadata-column ${params.analysis_group} \
        --p-pairwise \
        --o-visualization beta_diversity/bray_curtis_significance.qzv
    """
}