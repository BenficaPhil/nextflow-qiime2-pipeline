process AlphaDiversity_FaithPD {
    publishDir params.output_adiversity, pattern: "*.qzv", mode: 'copy'

    input:
    path faith_pd
    path metadata

    output:
    path "*.qzv"

    when:
    params.run_diversity == true

    script:
    """
    module load qiime2/${params.qiime2_version}

    qiime diversity alpha-group-significance \
        --i-alpha-diversity ${faith_pd} \
        --m-metadata-file ${metadata} \
        --o-visualization faith_pd_significance.qzv
    """
}