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
include { AlphaBetaDiversity_CoreMetrics } from './modules/coreDiversity.nf'
include { AlphaDiversity_Shannon } from './modules/alphaShannon.nf'
include { AlphaDiversity_ObservedFeatures } from './modules/alphaObservedFeatures.nf'
include { AlphaDiversity_FaithPD } from './modules/alphaFaithPD.nf'
include { AlphaDiversity_Evenness } from './modules/alphaEvenness.nf'
include { BetaDiversity_WeightedUniFrac } from './modules/betaWeightedUniFrac.nf'
include { BetaDiversity_UnweightedUniFrac } from './modules/betaUnweightedUniFrac.nf'
include { BetaDiversity_BrayCurtis } from './modules/betaBrayCurtis.nf'
include { BetaDiversity_Jaccard } from './modules/betaJaccard.nf'
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

    // Alpha and beta diversity core metrics results (runs only when --run_diversity is on and sampling depth available)
    AlphaBetaDiversity_CoreMetrics(ftable_ch, tree_ch, metadata_ch)
    
    // Alpha diversity statistical significance with Kruskal-Wallis (runs only when --run_diversity is on)
    shannon_ch = AlphaBetaDiversity_CoreMetrics.out.shannon
    obs_fea_ch = AlphaBetaDiversity_CoreMetrics.out.obs_fea
    faith_pd_ch = AlphaBetaDiversity_CoreMetrics.out.faith_pd
    evenness_ch = AlphaBetaDiversity_CoreMetrics.out.evenness

    AlphaDiversity_Shannon(shannon_ch, metadata_ch)
    AlphaDiversity_ObservedFeatures(obs_fea_ch, metadata_ch)
    AlphaDiversity_FaithPD(faith_pd_ch, metadata_ch)
    AlphaDiversity_Evenness(evenness_ch, metadata_ch)

    // Beta diversity statistical significance with PERMANOVA (runs only when --run_diversity is on)
    w_unifrac_ch = AlphaBetaDiversity_CoreMetrics.out.w_unifrac
    u_unifrac_ch = AlphaBetaDiversity_CoreMetrics.out.u_unifrac
    bray_curtis_ch = AlphaBetaDiversity_CoreMetrics.out.bray_curtis
    jaccard_ch = AlphaBetaDiversity_CoreMetrics.out.jaccard
    
    BetaDiversity_WeightedUniFrac(w_unifrac_ch, metadata_ch)
    BetaDiversity_UnweightedUniFrac(u_unifrac_ch, metadata_ch)
    BetaDiversity_BrayCurtis(bray_curtis_ch, metadata_ch)
    BetaDiversity_Jaccard(jaccard_ch, metadata_ch)

    // Functional Prediction with PICRUSt2
    FunctionalPrediction_PICRUSt2(ftable_ch, repseqs_ch)

    // Differential Abundance with ANCOM-BC2
    // genus_ch = GenusTable.out.qza
    // DifferentialAbundance_ANCOMBC2(ftable_ch, metadata_ch, taxonomy_ch, genus_ch)
}
