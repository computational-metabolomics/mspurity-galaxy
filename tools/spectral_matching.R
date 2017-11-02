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
)

# store options
opt<- parse_args(OptionParser(option_list=option_list))

loadRData <- function(rdata_path, name){
#loads an RData file, and returns the named xset object if it is there
    load(rdata_path)
    return(get(ls()[ls() == name]))
}


# Requires
pa <- loadRData(opt$pa, 'pa')
xset <- loadRData(opt$xset, 'xset')


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
                            topn = opt$topn,
                            db_name = NA,
                            grp_peaklist = NA,
                            library_db_pth = opt$library_db_pth,
                            instrument_types = opt$instrument_types,
                            library_sources = opt$library_sources,
                            scan_ids = opt$scan_ids)

print(file.path(result$out_dir, result$db_name))

