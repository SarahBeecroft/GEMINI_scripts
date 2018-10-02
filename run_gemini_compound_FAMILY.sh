#!/bin/bash

FAMILY=9927
PROBAND=D14-1421
DAD=D15-0158
MUM=D15-0156
DB=Databases/
DATABASE=ILLUMINA_DATABASE_21042017
LIST=UBERON-0001134_skeletal_muscle_tissue.txt

#Run the gemini analysis looking for het mutations shared between proband and dad, not present in mum.
nice gemini query -q "select gene, gms_illumina, qual, chrom, start, end, ref, alt, codon_change, aa_change, aa_length, vep_hgvsc, vep_hgvsp, impact, impact_severity, transcript, exon, aaf_1kg_all, aaf_exac_all, exac_num_het, exac_num_hom_alt, aaf_gnomad_all, gnomad_num_het, gnomad_num_hom_alt, is_conserved, is_lof, is_splicing, in_hom_run, gerp_bp_score, cadd_scaled, polyphen_pred, sift_pred, in_omim, pfam_domain, clinvar_sig, clinvar_gene_phenotype, gt_depths.$PROBAND, gt_ref_depths.$PROBAND, gt_alt_depths.$PROBAND, gt_depths.$MUM, gt_ref_depths.$MUM, gt_alt_depths.$MUM, gt_depths.$DAD, gt_ref_depths.$DAD, gt_alt_depths.$DAD from variants where (aaf_exac_all <= 0.01) and (exac_num_hom_alt < 1)" \
    --show-samples \
    --sample-delim ";" \
    --gt-filter "(gt_types.$PROBAND == HET) and (gt_alt_depths.$PROBAND >=5) and \
                 (gt_types.$DAD == HET) and \
                 (gt_types.$MUM != HET and gt_types.$MUM != HOM_ALT) and \
                 (gt_types).(family_id != '$FAMILY').(==HET).(count<=3) and \
                 (gt_types).(family_id != '$FAMILY').(==HOM_ALT).(count<=3)" \
    --header \
    $DATABASE > parent1.txt

#Run the gemini analysis looking for het mutations shared between proband and mum, not present in dad.
nice gemini query -q "select gene, gms_illumina, qual, chrom, start, end, ref, alt, codon_change, aa_change, aa_length, vep_hgvsc, vep_hgvsp, impact, impact_severity, transcript, exon, aaf_1kg_all, aaf_exac_all, exac_num_het, exac_num_hom_alt, aaf_gnomad_all, gnomad_num_het, gnomad_num_hom_alt, is_conserved, is_lof, is_splicing, in_hom_run, gerp_bp_score, cadd_scaled, polyphen_pred, sift_pred, in_omim, pfam_domain, clinvar_sig, clinvar_gene_phenotype, gt_depths.$PROBAND, gt_ref_depths.$PROBAND, gt_alt_depths.$PROBAND, gt_depths.$MUM, gt_ref_depths.$MUM, gt_alt_depths.$MUM, gt_depths.$DAD, gt_ref_depths.$DAD, gt_alt_depths.$DAD from variants where (aaf_exac_all <= 0.01) and (exac_num_hom_alt < 1)" \
    --show-samples \
    --sample-delim ";" \
    --gt-filter "(gt_types.$PROBAND == HET) and (gt_alt_depths.$PROBAND >=5) and \
                 (gt_types.$MUM == HET) and \
                 (gt_types.$DAD != HET and gt_types.$DAD != HOM_ALT) and \
                 (gt_types).(family_id != '$FAMILY').(==HET).(count<=3) and \
                 (gt_types).(family_id != '$FAMILY').(==HOM_ALT).(count<=3)" \
    --header \
    $DATABASE > parent2.txt

#Retrieve the genes with 2 variants in proband, one shared with mum the other with dad
awk '($1!="gene"){print $1}' parent1.txt | sort | uniq > t1
awk '($1!="gene"){print $1}' parent2.txt | sort | uniq > t2
comm -12 t1 t2 > comm
head -1 parent1.txt | awk -v OFS='\t' '{print "rank(enr)", "rank(max)", "pRec", $0}'
while read line
do
    grep "^$line\t" parent1.txt
    grep "^$line\t" parent2.txt
done < comm \
    | uniq \
    | sed 's/%/%%/g' \
    | awk -v j=0 '{if(j==0){print; j++}; if($1==prev){lines=lines$0"\n"; i++} else {if(i>1){printf lines}; prev=$1; lines=$0"\n"; i=1}} END {if(i>1){printf lines}}' \
    | addColumn.py - 1 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 20 first \
    | addColumn.py - 2 $DB/Expression/$LIST 1 5 first \
    | addColumn.py - 3 $DB/Expression/$LIST 1 3 first \
    | addColumn.py - 4 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 17 first \
    | addColumn.py - 5 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 18 first \
    | addColumn.py - 6 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 19 first \
    | sort -k1,1 -g
rm comm t1 t2 parent1.txt parent2.txt
