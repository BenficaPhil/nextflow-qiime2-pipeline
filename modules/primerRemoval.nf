process PrimerRemoval {
    publishDir params.output_import, pattern: "*.qza", mode: 'copy'
    publishDir params.output_qzv, pattern: "*.qzv", mode: 'copy'

    input:
    path demux

    output:
    path "*.qza", emit: qza
    path "*.qzv", emit: qzv

    script:
    """
    module load qiime2/${params.qiime2_version}

    qiime cutadapt trim-paired \
        --i-demultiplexed-sequences ${demux} \
        --p-cores 0 \
        --p-front-f ${params.forward_primer} \
        --p-front-r ${params.reverse_primer} \
        --o-trimmed-sequences trimmed-paired-end-demux.qza

    qiime demux summarize \
        --i-data trimmed-paired-end-demux.qza \
        --o-visualization trimmed-paired-end-demux.qzv
    """
}