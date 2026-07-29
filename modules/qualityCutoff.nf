process QualityCutoff {
    input:
    path trimmed_demux

    output:
    path extracted_demux
    stdout emit: trunc_val

    script:
    """
    module load qiime2/${params.qiime2_version}

    qiime tools export \
        --input-path trimmed-paired-end-demux.qzv \
        --output-path extracted_demux
    
    quality_cutoff_position.py ${params.quality_cutoff}
    """
}