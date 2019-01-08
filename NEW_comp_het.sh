#!/bin/bash
PROBAND=D18-0636
DAD=D18-0638
MUM=D18-0637
DATABASE=ILLUMINA_20181201

#Run the gemini analysis looking for het mutations shared between proband and dad, not present in mum.
#gemini query -q "select gene, gms_illumina, qual, chrom, start, end, ref, alt, codon_change, aa_change, aa_length, vep_hgvsc, vep_hgvsp, impact, impact_severity, transcript, exon, aaf_1kg_all, aaf_exac_all, exac_num_het, exac_num_hom_alt, aaf_gnomad_all, gnomad_num_het, gnomad_num_hom_alt, is_conserved, is_lof, is_splicing, in_hom_run, gerp_bp_score, cadd_scaled, polyphen_pred, sift_pred, in_omim, pfam_domain, clinvar_sig, clinvar_gene_phenotype, gt_depths.$PROBAND, gt_ref_depths.$PROBAND, gt_alt_depths.$PROBAND, gt_depths.$MUM, gt_ref_depths.$MUM, gt_alt_depths.$MUM, gt_depths.$DAD, gt_ref_depths.$DAD, gt_alt_depths.$DAD from variants where (aaf_exac_all <= 0.01) and (exac_num_hom_alt <= 1) and (aaf_gnomad_all <= 0.01) and (gnomad_num_hom_alt <= 1)" \
    --show-samples \
    --sample-delim ";" \
    --gt-filter "(gt_types.$PROBAND == HET) and (gt_alt_depths.$PROBAND >=5) and \
                 (gt_types.$DAD == HET) and \
                 (gt_types.$MUM != HET and gt_types.$MUM != HOM_ALT) and \
                 (gt_types).(*).(==HET).(count<=5) and \
                 (gt_types).(*).(==HOM_ALT).(count<=5)" \
    --header \
    $DATABASE > $DAD.txt

#Run the gemini analysis looking for het mutations shared between proband and mum, not present in dad.
#gemini query -q "select gene, gms_illumina, qual, chrom, start, end, ref, alt, codon_change, aa_change, aa_length, vep_hgvsc, vep_hgvsp, impact, impact_severity, transcript, exon, aaf_1kg_all, aaf_exac_all, exac_num_het, exac_num_hom_alt, aaf_gnomad_all, gnomad_num_het, gnomad_num_hom_alt, is_conserved, is_lof, is_splicing, in_hom_run, gerp_bp_score, cadd_scaled, polyphen_pred, sift_pred, in_omim, pfam_domain, clinvar_sig, clinvar_gene_phenotype, gt_depths.$PROBAND, gt_ref_depths.$PROBAND, gt_alt_depths.$PROBAND, gt_depths.$MUM, gt_ref_depths.$MUM, gt_alt_depths.$MUM, gt_depths.$DAD, gt_ref_depths.$DAD, gt_alt_depths.$DAD from variants where (aaf_exac_all <= 0.01) and (exac_num_hom_alt <= 1) and (aaf_gnomad_all <= 0.01) and (gnomad_num_hom_alt <= 1)" \
    --show-samples \
    --sample-delim ";" \
    --gt-filter "(gt_types.$PROBAND == HET) and (gt_alt_depths.$PROBAND >=5) and \
                 (gt_types.$MUM == HET) and \
                 (gt_types.$DAD != HET and gt_types.$DAD != HOM_ALT) and \
                 (gt_types).(*).(==HET).(count<=5) and \
                 (gt_types).(*).(==HOM_ALT).(count<=5)" \
    --header \
    $DATABASE > $MUM.txt

#Retrieve the genes with 2 variants in proband, one shared with mum the other with dad
awk '($1!="gene"){print $1}' $DAD.txt | sort | uniq > $DAD.t1
awk '($1!="gene"){print $1}' $MUM.txt | sort | uniq > $MUM.t2
comm -12 $DAD.t1 $MUM.t2 > comm
grep -v None comm | sort > comm1
grep -f comm1 $DAD.txt > parents.vars.temp
grep -f comm1 $MUM.txt >> parents.vars.temp
cat parents.vars.temp | sort > sorted.parents.vars.temp
head -1 $DAD.txt | awk -v OFS='\t' '{print "rank(enr)", "rank(max)", "pRec", $0}' | cat - sorted.parents.vars.temp > temp && mv temp sorted.parents.vars.temp
cat sorted.parents.vars.temp | awk -v j=0 '{if(j==0){print; j++}; if($1==prev){lines=lines$0"\n"; i++} else {if(i>1){printf lines}; prev=$1; lines=$0"\n"; i=1}} END {if(i>1){printf lines}}' \
    | addColumn.py - 1 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 20 first \
    | addColumn.py - 2 $DB/Expression/$LIST 1 5 first \
    | addColumn.py - 3 $DB/Expression/$LIST 1 3 first \
    | addColumn.py - 4 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 17 first \
    | addColumn.py - 5 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 18 first \
    | addColumn.py - 6 $DB/ExAC/fordist_cleaned_exac_r03_march16_z_pli_rec_null_data.txt 2 19 first

rm $DAD.txt $MUM.txt comm comm1 parents.vars.temp sorted.parents.vars.temp
