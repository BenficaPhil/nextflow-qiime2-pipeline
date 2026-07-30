process AlphaDiversity_ObservedFeatures {
    publishDir params.output_adiversity, pattern: "*.qzv", mode: 'copy'

    input:
    path obs_fea
    path metadata

    output:
    path "*.qzv"

    when:
    params.run_diversity == true

    script:
    """
    module load qiime2/${params.qiime2_version}

    qiime diversity alpha-group-significance \
        --i-alpha-diversity ${obs_fea} \
        --m-metadata-file ${metadata} \
        --o-visualization observed_features_significance.qzv
    """
}