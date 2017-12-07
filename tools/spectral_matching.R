library(msPurity)
library(optparse)

option_list <- list(
  make_option(c("-o", "--out_dir"), type="character"),
  make_option("--target_db_pth", type="character"),
  make_option("--library_db_pth", type="character"),
  make_option("--ra_thres_l", default=0),
  make_option("--ra_thres_t", default=2),
  make_option("--cores", default=1),
  make_option("--pol", default='positive'),
  make_option("--ppm_tol_prod", default=10),
  make_option("--ppm_tol_prec", default=5),
  make_option("--score_thres", default=0.6),
  make_option("--instrument_types", type='character'),
  make_option("--library_sources", type='character'),
  make_option("--scan_ids", default=NA),
  make_option("--topn", default=NA),
  make_option("--mzML_files", type="character"),
  make_option("--galaxy_names", type="character"),
  make_option("--create_new_database", action="store_true")

)

# store options
opt<- parse_args(OptionParser(option_list=option_list))



if (!is.null(opt$create_new_database)){
    target_db_pth <-  file.path(opt$out_dir, 'db_with_spectral_matching.sqlite')
    file.copy(opt$target_db_pth, target_db_pth)
}else{
    target_db_pth <- opt$target_db_pth
}


if (opt$instrument_types=='None'){
    instrument_types <- NA
}else{
    instrument_types <- trimws(strsplit(opt$instrument_types, ',')[[1]])
}
if (opt$library_sources=='None'){
    library_sources <- NA
}else{
    library_sources <- trimws(strsplit(opt$library_sources, ',')[[1]])
}


if (!is.na(opt$scan_ids)){
    scan_ids <- trimws(strsplit(opt$scan_ids, ',')[[1]])
    scan_ids <- scan_ids[scan_ids != ""]
}else{
    scan_ids <- NA
}


print(instrument_types)
print(library_sources)
print(scan_ids)

result <- msPurity::spectral_matching(
                            target_db_pth =target_db_pth ,
                            library_db_pth = opt$library_db_pth,
                            ra_thres_l = opt$ra_thres_l,
                            ra_thres_t = opt$ra_thres_t,
                            cores = opt$cores,
                            pol = opt$pol,
                            ppm_tol_prod = opt$ppm_tol_prod,
                            ppm_tol_prec = opt$ppm_tol_prec,
                            score_thres = opt$score_thres,
                            out_dir = opt$out_dir,
                            topn = opt$topn,
                            grp_peaklist = NA,

                            instrument_types = instrument_types,
                            library_sources = library_sources,
                            scan_ids = scan_ids)

print(file.path(result$result_db_pth))

write.table(result$xcms_summary_df, file.path(opt$out_dir, 'xcms_hits.tsv'), row.names=FALSE, sep='\t')

con <- DBI::dbConnect(RSQLite::SQLite(), file.path(result$result_db_pth))
# con <- DBI::dbConnect(RSQLite::SQLite(), file.path(opt$out_dir, 'result.sqlite'))

cmd <- paste('SELECT * FROM matches
              LEFT JOIN library_meta ON matches.lid=library_meta.lid
              LEFT JOIN s_peak_meta ON matches.pid=s_peak_meta.pid
              LEFT JOIN fileinfo ON s_peak_meta.fileid=fileinfo.fileid
              WHERE matches.score >= ', opt$score_thres)
print(cmd)
scan_hits <- DBI::dbGetQuery(con, cmd)

write.table(scan_hits, file.path(opt$out_dir, 'scan_hits.tsv'), row.names=FALSE, sep='\t')