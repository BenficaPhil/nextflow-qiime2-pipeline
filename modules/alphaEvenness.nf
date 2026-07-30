process AlphaDiversity_Evenness {
    publishDir params.output_adiversity, pattern: "*.qzv", mode: 'copy'

    input:
    path evenness
    path metadata

    output:
    path "*.qzv"

    when:
    params.run_diversity == true

    script:
    """
    module load qiime2/${params.qiime2_version}

    qiime diversity alpha-group-significance \
        --i-alpha-diversity ${evenness} \
        --m-metadata-file ${metadata} \
        --o-visualization evenness_significance.qzv
    """
}