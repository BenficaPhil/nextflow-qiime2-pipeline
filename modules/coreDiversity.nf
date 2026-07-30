process AlphaBetaDiversity_CoreMetrics {
    publishDir params.output_adiversity, pattern: "diversity-core-metrics/*_vector.qza", mode: 'copy',
                                         saveAs: { it.substring(it.lastIndexOf('/') + 1) }
    publishDir params.output_bdiversity, pattern: "diversity-core-metrics/*_distance_matrix.qza", mode: 'copy',
                                         saveAs: { it.substring(it.lastIndexOf('/') + 1) }
    publishDir params.output_bdiversity, pattern: "diversity-core-metrics/*_pcoa_results.qza", mode: 'copy',
                                         saveAs: { it.substring(it.lastIndexOf('/') + 1) }
    publishDir params.output_bdiversity, pattern: "diversity-core-metrics/*_emperor.qzv", mode: 'copy',
                                         saveAs: { it.substring(it.lastIndexOf('/') + 1) }
    publishDir params.output_rarefied, pattern: "diversity-core-metrics/rarefied_table.qza", mode: 'copy',
                                       saveAs: { it.substring(it.lastIndexOf('/') + 1) }

    input:
    path filtered_table
    path rooted_tree
    path metadata

    output:
    path "diversity-core-metrics/shannon_vector.qza", emit: shannon
    path "diversity-core-metrics/observed_features_vector.qza", emit: obs_fea
    path "diversity-core-metrics/faith_pd_vector.qza", emit: faith_pd
    path "diversity-core-metrics/evenness_vector.qza", emit: evenness
    path "diversity-core-metrics/unweighted_unifrac_distance_matrix.qza", emit: u_unifrac
    path "diversity-core-metrics/weighted_unifrac_distance_matrix.qza", emit: w_unifrac
    path "diversity-core-metrics/jaccard_distance_matrix.qza", emit: jaccard
    path "diversity-core-metrics/bray_curtis_distance_matrix.qza", emit: bray_curtis
    path "diversity-core-metrics/*_pcoa_results.qza"
    path "diversity-core-metrics/*_emperor.qzv"
    path "diversity-core-metrics/rarefied_table.qza"

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
    """
}
