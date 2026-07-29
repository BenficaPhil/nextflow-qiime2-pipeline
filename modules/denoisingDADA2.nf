process Denoising_DADA2 {
    publishDir params.output_dada2, pattern: "*.qza", mode: 'copy'
    publishDir params.output_qzv, pattern: "*.qzv", mode: 'copy'

    input:
    path trimmed_demux
    tuple val(forward), val(reverse)
    path metadata

    output:
    path "rep-seqs.qza", emit: rep_seqs
    path "asv-table.qza", emit: asv_table
    path "*stats.qza", emit: stats
    path "*frequencies.qza", emit: frequencies
    path "*.qzv", emit: qzv

    script:
    """
    module load qiime2/${params.qiime2_version}

    qiime dada2 denoise-paired \
        --i-demultiplexed-seqs ${trimmed_demux} \
        --p-trunc-len-f ${forward} \
        --p-trunc-len-r ${reverse} \
        --p-n-threads 8 \
        --o-representative-sequences rep-seqs.qza \
        --o-table asv-table.qza \
        --o-denoising-stats dada2-denoising-stats.qza \
        --o-base-transition-stats dada2-base-transition-stats.qza
    
    qiime metadata tabulate \
        --m-input-file dada2-denoising-stats.qza \
        --o-visualization dada2-denoising-stats.qzv
    
    qiime feature-table summarize \
        --i-table asv-table.qza \
        --m-metadata-file ${metadata} \
        --o-summary asv-table.qzv \
        --o-feature-frequencies asv-frequencies.qza \
        --o-sample-frequencies sample-frequencies.qza

    qiime feature-table tabulate-seqs \
        --i-data rep-seqs.qza \
        --o-visualization rep-seqs.qzv
    """
}