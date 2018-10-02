#!/bin/bash

for region in chr19:55439166-57646570, chr19:46734255-52115645, chr11:43954812-60890563, chr9:119382768-139562993, chr4:73956736-85555196, chr4:19892688-57889677, chr2:179236831-192820898, chr2:139046385-143798189

do

gemini query --region $region -q "select gene, qual, filter, chrom, start, end, ref, alt, type, exon, aa_change, impact, impact_severity, max_aaf_all, aaf_adj_exac_all, exac_num_het, exac_num_hom_alt, sift_pred, polyphen_pred, pfam_domain, clinvar_disease_name, clinvar_sig, gts.TN1604D0854, gts.TN1604D0857 from variants where impact_severity != 'LOW' and (aaf_exac_all <= 0.02) and (max_aaf_all <=0.02) and (exac_num_hom_alt < 20)" --show-samples --sample-delim ";" --gt-filter "(gt_types.TN1604D0854 != HOM_REF) and (gt_depths.TN1604D0854 >= 20) and (gt_types.TN1604D0857 != HOM_REF) and (gt_depths.TN1604D0857 >= 20) and (gt_types).(*).(==HOM_ALT).(count <21) and (gt_types).(*).(==HET).(count <21)" --header ~/Desktop/ILLUMINA_DATABASE_26102016 >> sibpair3_linkageregions.tsv

done