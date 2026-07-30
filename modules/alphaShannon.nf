process AlphaDiversity_Shannon {
    publishDir params.output_adiversity, pattern: "*.qzv", mode: 'copy'
    
    input:
    path shannon
    path metadata

    output:
    path "*.qzv"

    when:
    params.run_diversity == true

    script:
    """
    module load qiime2/${params.qiime2_version}

    qiime diversity alpha-group-significance \
        --i-alpha-diversity ${shannon} \
        --m-metadata-file ${metadata} \
        --o-visualization shannon_significance.qzv
    """
}