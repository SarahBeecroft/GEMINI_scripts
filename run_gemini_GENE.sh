#!/bin/bash

DB=Databases/
DATABASE=ILLUMINA_DATABASE_20180427
#Run the gemini analysis
nice gemini query -q "select gene, qual, chrom, start, end, ref, alt, codon_change, aa_change, aa_length, impact, impact_severity, transcript, exon, aaf_1kg_all, aaf_exac_all, exac_num_het, exac_num_hom_alt, aaf_gnomad_all, gnomad_num_het, gnomad_num_hom_alt, is_conserved, is_lof, is_splicing, in_hom_run, gerp_bp_score, cadd_scaled, polyphen_pred, sift_pred, in_omim, pfam_domain, clinvar_sig, clinvar_gene_phenotype from variants where gene='$1'" \
    --show-samples \
    --sample-delim ";" \
    --gt-filter "((gt_types).(*).(==HET).(count > 0) or (gt_types).(*).(==HOM_ALT).(count > 0)) and (gt_alt_depths).(*).( >= 5).(count > 0)" \
    --header \
    $DATABASE



