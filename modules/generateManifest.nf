process GenerateManifest {
    publishDir params.output_import, mode: 'copy'

    input:
    path reads

    output:
    path '*.tsv'

    script:
    """
    bash generate_manifest.sh ${reads}
    """
}