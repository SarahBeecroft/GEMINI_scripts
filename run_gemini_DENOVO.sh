#!/bin/bash
#de novo script for trio

DB=Databases/
DATABASE=ILLUMINA_DATABASE_20180427
LIST=UBERON-0001134_skeletal_muscle_tissue.txt
#patients
PROBAND=D16-1569
MUM=D16-1571
DAD=D16-1570

gemini query -q "select gene, qual, chrom, start, end, ref, alt, aa_change, aa_length, vep_hgvsc, vep_hgvsp, impact, impact_severity, transcript, exon, aaf_1kg_all, aaf_exac_all, exac_num_het, exac_num_hom_alt, aaf_gnomad_all, gnomad_num_het, gnomad_num_hom_alt, is_conserved, is_lof, is_splicing, in_hom_run, gerp_bp_score, cadd_scaled, polyphen_pred, sift_pred, in_omim, pfam_domain, clinvar_sig, clinvar_gene_phenotype, gt_ref_depths.$PROBAND, gt_alt_depths.$PROBAND, gt_ref_depths.$MUM, gt_alt_depths.$MUM, gt_ref_depths.$DAD, gt_alt_depths.$DAD from variants where (aaf_exac_all <= .01) and (exac_num_hom_alt <= 1) and (aaf_gnomad_all <= 0.01) and (gnomad_num_het <=1) and (gnomad_num_hom_alt <= 1) and (impact_severity != 'LOW')" \
    --show-samples \
    --sample-delim ";" \
    --gt-filter "(gt_types.$PROBAND == HET) and (gt_alt_depths.$PROBAND >=5) and \
    (gt_types.$MUM != HET) and (gt_types.$MUM != HOM_ALT) and \
    (gt_types.$DAD != HET) and (gt_types.$DAD != HOM_ALT) and \
    (gt_types).(*).(==HET).(count <= 1) and \
    (gt_types).(*).(==HOM_ALT).(count <= 1)" \
    --header \
    $DATABASE \
    | addColumn.py - 1 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 20 first \
    | addColumn.py - 2 $DB/Expression/$LIST 1 5 first \
    | addColumn.py - 3 $DB/Expression/$LIST 1 3 first \
    | addColumn.py - 4 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 17 first \
    | addColumn.py - 5 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 18 first \
    | addColumn.py - 6 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 19 first
