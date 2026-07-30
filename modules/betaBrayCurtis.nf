process BetaDiversity_BrayCurtis {
    publishDir params.output_bdiversity, pattern: "*.qzv", mode: 'copy'

    input:
    path bray_curtis
    path metadata

    output:
    path "*.qzv"

    when:
    params.run_diversity == true

    script:
    """
    module load qiime2/${params.qiime2_version}

    qiime diversity beta-group-significance \
        --i-distance-matrix ${bray_curtis} \
        --m-metadata-file ${metadata} \
        --m-metadata-column ${params.analysis_group} \
        --p-pairwise \
        --o-visualization bray_curtis_significance.qzv
    """
}