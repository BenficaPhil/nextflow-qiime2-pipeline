include { GenerateManifest } from './modules/generateManifest.nf'
include { ImportSequences } from './modules/importSequences.nf'
include { PrimerRemoval } from './modules/primerRemoval.nf'
include { QualityCutoff } from './modules/qualityCutoff.nf'
include { Denoising_DADA2 } from './modules/denoisingDADA2.nf'
include { TaxonomicClassification } from './modules/taxonomicClassification.nf'
include { FilterASVTable } from './modules/filterASVTable.nf'
include { GenusTable } from './modules/genusTable.nf'
include { GroupedTable } from './modules/groupedTable.nf'
include { PhylogeneticTree } from './modules/phylogeneticTree.nf'
include { AlphaRarefaction } from './modules/rarefactionCurves.nf'
include { AlphaBetaDiversity } from './modules/alphaBetaDiversity.nf'
include { FunctionalPrediction_PICRUSt2 } from './modules/functionalPrediction.nf'
//include { DifferentialAbundance_ANCOMBC2 } from './modules/differentialAbundance.nf'

workflow {
    // Specify the reads directory for input
    reads_ch = Channel.fromPath(params.reads)

    // Generate manifest file using fastq sequences provided by user in 01_data
    manifest_ch = reads_ch | GenerateManifest

    // Run QIIME 2 function to import sequences to demux.qza
    manifest_ch | ImportSequences

    // Remove primers through Cutadapt
    ImportSequences.out.qza | PrimerRemoval

    // Find truncation positions for DADA2 using quality cutoff
    PrimerRemoval.out.qzv | QualityCutoff

    // Perform denoising with DADA2 for quality control
    QualityCutoff.out.trunc_val
        .map { stdout ->
            def positions = stdout.readLines()[1]
            def parts = positions.trim().split(/\s+/)
            tuple(parts[0].toInteger(), parts[1].toInteger())
        }
        .set { truncation_ch }

    metadata_ch = Channel.fromPath(params.metadata)

    Denoising_DADA2(PrimerRemoval.out.qza, truncation_ch, metadata_ch)

    // Run pre-trained taxonomic classifier using downloaded database and rep seqs
    database_url = params.urls[params.tax_database] ?: params.urls['SILVA_138.2_animal_gut']
    database_ch = Channel.fromPath(database_url)
    repseqs_ch = Denoising_DADA2.out.rep_seqs
    asvtable_ch = Denoising_DADA2.out.asv_table

    TaxonomicClassification(database_ch, repseqs_ch, asvtable_ch, metadata_ch)

    // Filter mitochondria, chloroplasts, and Unassigned
    taxonomy_ch = TaxonomicClassification.out.qza

    FilterASVTable(asvtable_ch, taxonomy_ch, metadata_ch)

    // Export genus table
    ftable_ch = FilterASVTable.out.filtered_table
    
    GenusTable(ftable_ch, taxonomy_ch)

    // Export grouped table
    GroupedTable(ftable_ch, metadata_ch)

    // Phylogenetic Tree for diversity metrics Faith PD and UniFrac
    repseqs_ch | PhylogeneticTree

    // Alpha rarefaction curve
    tree_ch = PhylogeneticTree.out.rooted_tree

    AlphaRarefaction(ftable_ch, tree_ch, metadata_ch)

    // Alpha and beta diversity (runs only when specified and sampling depth available)
    AlphaBetaDiversity(ftable_ch, tree_ch, metadata_ch)

    // Functional Prediction with PICRUSt2
    FunctionalPrediction_PICRUSt2(ftable_ch, repseqs_ch)

    // Differential Abundance with ANCOM-BC2
    // genus_ch = GenusTable.out.qza
    //DifferentialAbundance_ANCOMBC2(ftable_ch, metadata_ch, taxonomy_ch, genus_ch)
}