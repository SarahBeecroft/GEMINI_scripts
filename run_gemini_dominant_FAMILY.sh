#!/bin/bash

DB=Databases/
DATABASE=ILLUMINA_DATABASE_20171109
LIST=UBERON-0001134_skeletal_muscle_tissue.txt
PROBAND=D16-0784
MUM=D17-1010
AFF_BRO=D17-1012
DAD=D16-0661
PAT_GD=D16-0659

#Run the gemini analysis looking for het mutations in proband
gemini query -q "select gene, exome, splicing, intron_overlaps, intron_length, gms_illumina, qual, chrom, start, end, ref, alt, codon_change, aa_change, aa_length, vep_hgvsc, vep_hgvsp, impact, impact_severity, transcript, exon, aaf_1kg_all, aaf_exac_all, exac_num_het, exac_num_hom_alt, aaf_gnomad_all, gnomad_num_het, gnomad_num_hom_alt, is_conserved, is_lof, is_splicing, in_hom_run, gerp_bp_score, cadd_scaled, polyphen_pred, sift_pred, in_omim, pfam_domain, clinvar_sig, clinvar_gene_phenotype, gt_depths.$PROBAND, gt_ref_depths.$PROBAND, gt_alt_depths.$PROBAND from variants where (aaf_exac_all < .01) and (exac_num_hom_alt < 1) and (gnomad_num_het < 5) and (gnomad_num_hom_alt < 2)" \
    --show-samples \
    --sample-delim ";" \
    --gt-filter "(gt_types.$PROBAND == HET) and (gt_alt_depths.$PROBAND >=5) and \
    (gt_types.$MUM != HET) and (gt_types.$MUM != HOM_ALT) and \
    (gt_types.$AFF_BRO == HET) and (gt_alt_depths.$AFF_BRO >=5) and \
    (gt_types.$DAD == HET) and (gt_alt_depths.$DAD >=5) and \
    (gt_types.$PAT_GD == HET) and (gt_alt_depths.$PAT_GD >=5) and \
    (gt_types).(*).(==HET).(count<=4) and \
    (gt_types).(*).(==HOM_ALT).(count<=1)" \
    --header \
    $DATABASE \
    | addColumn.py - 1 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 20 first \
    | addColumn.py - 2 $DB/Expression/$LIST 1 5 first \
    | addColumn.py - 3 $DB/Expression/$LIST 1 3 first \
    | addColumn.py - 4 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 17 first \
    | addColumn.py - 5 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 18 first \
    | addColumn.py - 6 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 19 first
