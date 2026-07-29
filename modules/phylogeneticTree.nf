process PhylogeneticTree {
    publishDir params.output_phylogeny, pattern: "*.qza", mode: 'copy'

    input:
    path rep_seqs

    output:
    path "rooted-tree.qza", emit: rooted_tree
    path "unrooted-tree.qza", emit: unrooted_tree
    path "*-rep-seqs.qza", emit: aligned_rep_seqs

    script:
    """
    module load qiime2/${params.qiime2_version}

    qiime phylogeny align-to-tree-mafft-fasttree \
        --i-sequences ${rep_seqs} \
        --o-alignment aligned-rep-seqs.qza \
        --o-masked-alignment masked-aligned-rep-seqs.qza \
        --o-tree unrooted-tree.qza \
        --o-rooted-tree rooted-tree.qza
    """
}