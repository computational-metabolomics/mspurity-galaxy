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
  make_option("--instrument_types", type='character'),
  make_option("--library_sources", type='character'),
  make_option("--scan_ids", type='character'),
  make_option("--topn", default='NA'),
  make_option("--mzML_files", type="character"),
  make_option("--galaxy_names", type="character")
)

# store options
opt<- parse_args(OptionParser(option_list=option_list))


scan_ids <- trimws(strsplit(opt$scan_ids, ',')[[1]])
instrument_types <- trimws(strsplit(opt$instrument_types, ',')[[1]])
library_sources <- trimws(strsplit(opt$library_sources, ',')[[1]])

loadRData <- function(rdata_path, name){
#loads an RData file, and returns the named xset object if it is there
    load(rdata_path)
    return(get(ls()[ls() == name]))
}

if (opt$topn=='NA'){
    topn = NA
}

if (opt$scan_ids=='NA'){
    scan_ids = NA
}


# Requires
pa <- loadRData(opt$pa, 'pa')
xset <- loadRData(opt$xset, 'xset')


print(pa@fileList)
print(xset@filepaths)
print(xset@phenoData)

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

save.image('test.RData')


print(xset@filepaths)
print(pa@fileList)
print(head(pa@puritydf))
print(head(pa@grped_df))

result <- msPurity::spectral_matching(pa = pa,
                            xset = xset,
                            ra_thres_l = opt$ra_thres_l,
                            ra_thres_t = opt$ra_thres_t,
                            cores = opt$cores,
                            pol = opt$pol,
                            ppm_tol_prod = opt$ppm_tol_prod,
                            ppm_tol_prec = opt$ppm_tol_prec,
                            score_thres = opt$score_thres,
                            out_dir = opt$out_dir,
                            topn = topn,
                            db_name = NA,
                            grp_peaklist = NA,
                            library_db_pth = opt$library_db_pth,
                            instrument_types = instrument_types,
                            library_sources = library_sources,
                            scan_ids = scan_ids)

print(file.path(result$out_dir, result$db_name))

