library(optparse)
library(msPurity)
library(xcms)
print(sessionInfo())


option_list <- list(
  make_option(c("-o", "--out_dir"), type="character"),
  make_option("--pa", type="character"),
  
  make_option("--av_level", default="intra", type="character"),

  make_option("--minfrac", default=0.5),
  make_option("--minnum", default=1),
  make_option("--ppm", default=5.0),

  make_option("--snr", default=0), 
  
  make_option("--ra", default=0),
  
  make_option("--snr_pre", default=0), 
  make_option("--ra_pre", default=0), 
  
  make_option("--av", default="median", type="character"),
  make_option("--sum_i", action="store_true"),
  make_option("--plim", default=0.5), 
  make_option("--remove_peaks", action="store_true"),
  make_option("--cores", default=1)
)

opt <- parse_args(OptionParser(option_list=option_list))

print(opt)

loadRData <- function(rdata_path, name){
#loads an RData file, and returns the named xset object if it is there
    load(rdata_path)
    return(get(ls()[ls() %in% name]))
}

# Requires
pa <- loadRData(opt$pa, 'pa')

pa@cores <- opt$cores

if(is.null(opt$remove_peaks)){
  remove_peaks = FALSE
}else{
  remove_peaks = TRUE
}

if(is.null(opt$sum_i)){
  sum_i = FALSE
}else{
  sum_i = TRUE
}

if(opt$av_level=="intra"){

  pa <- msPurity::averageIntraFragSpectra(pa, 
                                      minfrac=opt$minfrac,
                                      minnum=opt$minnum,
                                      ppm=opt$ppm,
                                      snr=opt$snr,
                                      ra=opt$ra,
                                      snr_pre=opt$snr_pre,
                                      ra_pre=opt$ra_pre,
                                      av=opt$av,
                                      sum_i=sum_i,
                                      plim=opt$plim,
                                      remove_peaks=remove_peaks,
                                      cores=opt$cores)

} else if(opt$av_level=="inter"){

  pa <- msPurity::averageInterFragSpectra(pa, 
                                      minfrac=opt$minfrac,
                                      minnum=opt$minnum,
                                      ppm=opt$ppm,
                                      snr=opt$snr,
                                      ra=opt$ra,
                                      av=opt$av,
                                      sum_i=sum_i,
                                      plim=opt$plim,
                                      remove_peaks=remove_peaks,
                                      cores=opt$cores)
} else if(opt$av_level=="all"){

  pa <- msPurity::averageAllFragSpectra(pa, 
                                        minfrac=opt$minfrac,
                                        minnum=opt$minnum,
                                        ppm=opt$ppm,
                                        snr=opt$snr,
                                        ra=opt$ra,
                                        snr_pre=opt$snr_pre,
                                        ra_pre=opt$ra_pre,
                                        av=opt$av,
                                        sum_i=sum_i,
                                        plim=opt$plim,
                                        remove_peaks=remove_peaks,
                                        cores=opt$cores)

}

save(pa, file=file.path(opt$out_dir, paste('average_', opt$av_level, '_fragementation_spectra.RData', sep=""))

