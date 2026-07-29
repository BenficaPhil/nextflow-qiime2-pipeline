process DownloadTaxonomyClassifier {
    publishDir params.output_taxonomy, pattern: "*.qza", mode: 'copy'

    input:
    path database_url

    output:
    path "*.qza", emit: qza

    script:
    """
    wget ${database_url}
    """
}