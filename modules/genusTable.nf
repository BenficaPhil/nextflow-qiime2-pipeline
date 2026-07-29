process GenusTable {
    publishDir params.output_genus, pattern: "*.{qza,txt}", mode: 'copy'

    input:
    path filtered_table
    path taxonomy

    output:
    path "*.qza", emit: qza
    path "*.txt", emit: txt

    script:
    """
    module load qiime2/${params.qiime2_version}

    qiime taxa collapse \
        --i-table ${filtered_table} \
        --i-taxonomy ${taxonomy} \
        --p-level 6 \
        --o-collapsed-table collapsed-table-l6.qza

    qiime tools export \
        --input-path collapsed-table-l6.qza \
        --output-path biom/

    biom convert \
        --input-fp biom/feature-table.biom \
        --output-fp genus_table.txt \
        --to-tsv
    """
}