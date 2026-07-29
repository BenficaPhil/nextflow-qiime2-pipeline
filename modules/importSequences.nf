process ImportSequences {
    publishDir params.output_import, pattern: "*.qza", mode: 'copy'
    publishDir params.output_qzv, pattern: "*.qzv", mode: 'copy'

    input:
    path manifest

    output:
    path "*.qza", emit: qza
    path "*.qzv", emit: qzv

    script:
    """
    module load qiime2/${params.qiime2_version}

    qiime tools import \
        --type 'SampleData[PairedEndSequencesWithQuality]' \
        --input-format PairedEndFastqManifestPhred33V2 \
        --input-path ${manifest} \
        --output-path paired-end-demux.qza
    
    qiime demux summarize \
        --i-data paired-end-demux.qza \
        --o-visualization paired-end-demux.qzv
    """
}