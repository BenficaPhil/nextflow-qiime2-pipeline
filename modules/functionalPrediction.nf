process FunctionalPrediction_PICRUSt2 {
    publishDir params.output_picrust2, pattern: "picrust2_output", mode: 'copy'

    input:
    path filtered_table
    path rep_seqs

    output:
    path "picrust2_output"

    script:
    """
    module load qiime2/${params.qiime2_version}

    qiime tools export \
        --input-path ${filtered_table} \
        --output-path biom/

    qiime tools export \
        --input-path ${rep_seqs} \
        --output-path rep_seqs/

    module load picrust2/${params.picrust2_version}

    picrust2_pipeline.py -s rep_seqs/dna-sequences.fasta -i biom/feature-table.biom -o picrust2_output -p 8

    cd picrust2_output/pathways_out

    gunzip *.gz

    add_descriptions.py -i path_abun_unstrat.tsv -m METACYC -o METACYC_descriptions.tsv
    """
}
