process BetaDiversity_WeightedUniFrac {
    publishDir params.output_bdiversity, pattern: "*.qzv", mode: 'copy'

    input:
    path w_unifrac
    path metadata

    output:
    path "*.qzv"

    when:
    params.run_diversity == true

    script:
    """
    module load qiime2/${params.qiime2_version}

    qiime diversity beta-group-significance \
        --i-distance-matrix ${w_unifrac} \
        --m-metadata-file ${metadata} \
        --m-metadata-column ${params.analysis_group} \
        --p-pairwise \
        --o-visualization weighted_unifrac_significance.qzv
    """
}