library(msPurity)
library(optparse)

option_list <- list(
  make_option(c("-o", "--out_dir"), type="character"),
  make_option("--pa", type="character"),
  make_option("--xset", type="character"),
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
  make_option("--galaxy_names", type="character")
  # # if purity assessments are to be run as part of tool
  # make_option("--run_purity_assessments", action="store_true"),
  # make_option("--minOffset", default=0.5),
  # make_option("--maxOffset", default=0.5),
  # make_option("--ilim", default=0.05),
  # make_option("--iwNorm", default="none", type="character"),
  # make_option("--exclude_isotopes", action="store_true"),
  # make_option("--isotope_matrix", type="character"),
  # make_option("--mostIntense", action="store_true"),
  # make_option("--plotP", action="store_true"),
  # make_option("--nearest", action="store_true"),
  # make_option("--ppm_f4f", default=10),
  # make_option("--plim_f4f", default=0.0),
  # make_option("--convert2RawRT_f4f", action="store_true"),
  # make_option("--mostIntense_f4f", action="store_true"),

)

# store options
opt<- parse_args(OptionParser(option_list=option_list))


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


loadRData <- function(rdata_path, name){
#loads an RData file, and returns the named xset object if it is there
    load(rdata_path)
    return(get(ls()[ls() == name]))
}


if (!is.na(opt$scan_ids)){
    scan_ids <- trimws(strsplit(opt$scan_ids, ',')[[1]])
    scan_ids <- scan_ids[scan_ids != ""]
}else{
    scan_ids <- NA
}

# Requires
pa <- loadRData(opt$pa, 'pa')
xset <- loadRData(opt$xset, 'xset')

if (!is.null(opt$mzML_files) && !is.null(opt$galaxy_names)){
    # NOTE: This only works if the pa file was generated IN Galaxy!! Relies on
    # the pa@fileList having the names of files given as 'names' of the variables (done in frag4feature)
    # Will update in the next version of msPurity
    filepaths <- trimws(strsplit(opt$mzML_files, ',')[[1]])
    filepaths <- filepaths[filepaths != ""]
    new_names <- basename(filepaths)

    galaxy_names <- trimws(strsplit(opt$galaxy_names, ',')[[1]])
    galaxy_names <- galaxy_names[galaxy_names != ""]

    nsave <- names(pa@fileList)
    old_filenames  <- basename(pa@fileList)
    pa@fileList <- filepaths[match(names(pa@fileList), galaxy_names)]

    pa@puritydf$filename <- basename(pa@fileList[match(pa@puritydf$filename, old_filenames)])
    pa@grped_df$filename <- basename(pa@fileList[match(pa@grped_df$filename, old_filenames)])
}

if(!all(basename(pa@fileList)==basename(xset@filepaths))){
  if(!all(names(pa@fileList)==basename(xset@filepaths))){
    quit(status = 1)
  }else{
    xset@filepaths <- unname(pa@fileList)
  }
}

print(instrument_types)
print(library_sources)
print(scan_ids)

result <- msPurity::spectral_matching(pa = pa,
                            xset = xset,
                            db_name = 'results.sqlite',
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
                            library_db_pth = opt$library_db_pth,
                            instrument_types = instrument_types,
                            library_sources = library_sources,
                            scan_ids = scan_ids)

print(file.path(result$out_dir, result$db_name))

write.table(result$xcms_summary_df, file.path(opt$out_dir, 'xcms_hits.tsv'), row.names=FALSE, sep='\t')

con <- DBI::dbConnect(RSQLite::SQLite(), file.path(result$out_dir, result$db_name))
# con <- DBI::dbConnect(RSQLite::SQLite(), file.path(opt$out_dir, 'result.sqlite'))

cmd <- paste('SELECT * FROM matches
              LEFT JOIN library_meta ON matches.lid=library_meta.lid
              LEFT JOIN s_peak_meta ON matches.pid=s_peak_meta.pid
              LEFT JOIN fileinfo ON s_peak_meta.fileid=fileinfo.fileid
              WHERE matches.score >= ', opt$score_thres)
print(cmd)
scan_hits <- DBI::dbGetQuery(con, cmd)

write.table(scan_hits, file.path(opt$out_dir, 'scan_hits.tsv'), row.names=FALSE, sep='\t')