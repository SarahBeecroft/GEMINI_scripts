#!/bin/bash

PROBAND=$1

DB=Databases/
DATABASE=ILLUMINA_DATABASE_20170721
LIST=UBERON-0001134_skeletal_muscle_tissue.txt

#Run the gemini analysis looking for het mutations shared between proband and dad, not present in mum.
nice gemini query -q "select gene, exome, splicing, intron_overlaps, intron_length, gms_illumina, qual, chrom, start, end, ref, alt, codon_change, aa_change, aa_length, vep_hgvsc, vep_hgvsp, impact, impact_severity, transcript, exon, aaf_1kg_all, aaf_exac_all, exac_num_het, exac_num_hom_alt, aaf_gnomad_all, gnomad_num_het, gnomad_num_hom_alt, is_conserved, is_lof, is_splicing, in_hom_run, gerp_bp_score, cadd_scaled, polyphen_pred, sift_pred, in_omim, pfam_domain, clinvar_sig, clinvar_gene_phenotype, gt_depths.$PROBAND, gt_ref_depths.$PROBAND, gt_alt_depths.$PROBAND from variants where (aaf_exac_all < .01) and (exac_num_hom_alt < 1) and (gnomad_num_het <= 10) and (gnomad_num_hom_alt < 1)" \
    --show-samples \
    --sample-delim ";" \
    --gt-filter "(gt_types.$PROBAND == HOM_ALT) and (gt_alt_depths.$PROBAND >= 10) and \
                 (gt_types).(*).(==HET).(count<=3) and \
                 (gt_types).(*).(==HOM_ALT).(count<=4)" \
    --header \
    $DATABASE \
    | addColumn.py - 1 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 21 first \
    | addColumn.py - 2 $DB/Expression/$LIST 1 5 first \
    | addColumn.py - 3 $DB/Expression/$LIST 1 3 first \
    | addColumn.py - 4 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 17 first \
    | addColumn.py - 5 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 18 first \
    | addColumn.py - 6 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 19 first
