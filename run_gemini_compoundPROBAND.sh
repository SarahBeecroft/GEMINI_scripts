#!/bin/bash

DB=Databases/
DATABASE=ILLUMINA_DATABASE_21042017
LIST=UBERON-0001134_skeletal_muscle_tissue.txt
PROBAND=$1

#Example use: ./run_gemini_compoundPROBAND.sh D13-1199 > output.txt
#The first column is the rank of the gene in muscle enrichment lists.
#Second column is the probability the gene is intolerant of homozygous LOF (ExAC).

#Script designed to look at candidate compound recessive mutations in a proband only.
#Currently set to look for variants that have <= .01 frequency in exac, no homozygotes in exac.
#Must be heterozygous in the proband with a read depth supporting the variant of 5 or more.
#Variant must exist (heterozygous or homo alt) in a maximum of 5 exomes (reduce to 1 if you only want the variant to be present ONLY in the proband).

nice gemini query -q "select gene, gms_illumina, qual, chrom, start, end, ref, alt, codon_change, aa_change, aa_length, vep_hgvsc, vep_hgvsp, impact, impact_severity, transcript, exon, aaf_1kg_all, aaf_exac_all, exac_num_het, exac_num_hom_alt, aaf_gnomad_all, gnomad_num_het, gnomad_num_hom_alt, is_conserved, is_lof, is_splicing, in_hom_run, gerp_bp_score, cadd_scaled, polyphen_pred, sift_pred, in_omim, pfam_domain, clinvar_sig, clinvar_gene_phenotype, gt_depths.$PROBAND, gt_ref_depths.$PROBAND, gt_alt_depths.$PROBAND from variants where (aaf_exac_all <= 0.01) and (exac_num_hom_alt < 1) and (aaf_gnomad_all <= 0.01) and (gnomad_num_hom_alt <1)" \
    --show-samples \
    --sample-delim ";" \
    --gt-filter "(gt_types.$PROBAND == HET) and (gt_alt_depths.$PROBAND >=5) and \
                 (gt_types).(*).(==HET).(count<=5) and \
                 (gt_types).(*).(==HOM_ALT).(count<=5)" \
    --header \
    $DATABASE \
    | sed 's/%/%%/g' \
    | awk -v j=0 '{if(j==0){print; j++}; if($1==prev){lines=lines$0"\n"; i++} else {if(i>1){printf lines}; prev=$1; lines=$0"\n"; i=1}} END {if(i>1){printf lines}}' \
    | python addColumn.py - 1 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 20 first \
    | python addColumn.py - 2 $DB/Expression/$LIST 1 5 first \
    | python addColumn.py - 3 $DB/Expression/$LIST 1 3 first \
    | python addColumn.py - 4 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 17 first \
    | python addColumn.py - 5 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 18 first \
    | python addColumn.py - 6 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 19 first
