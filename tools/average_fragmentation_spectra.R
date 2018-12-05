library(optparse)
library(msPurity)
library(xcms)
print(sessionInfo())


option_list <- list(
  make_option(c("-o", "--out_dir"), type="character"),
  make_option("--pa", type="character"),
  
  make_option("--av_level"),

  make_option("--minfrac", default=0.5),
  make_option("--minnum", default=1),
  make_option("--ppm", default=5.0),

  make_option("--snr", default=0), 
  
  make_option("--ra", default=0),
  
  make_option("--snr_pre", default=0, 
  make_option("--ra_pre", default=0), 
  
  make_option("--av", default='median', type="character"),
  make_option("--sum_i", action="store_true"),
  make_option("--plim", default=0.5), 
  make_option("--remove_peaks", action="store_true"),
  make_option("--cores", default=1)
)

# store options
opt<- parse_args(OptionParser(option_list=option_list))

print(opt)

loadRData <- function(rdata_path, name){
#loads an RData file, and returns the named xset object if it is there
    load(rdata_path)
    return(get(ls()[ls() %in% name]))
}

# Requires
pa <- loadRData(opt$pa, 'pa')

pa@cores <- opt$cores

print(pa@fileList)

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

print(pa@fileList)
print(names(pa@fileList))
saveRDS(pa, 'test_pa.rds')
if(opt$av_level=="intra"){

  pa <- msPurity::averageIntraFragSpectra(pa, 
                                      minfrac=ops$minfrac,
                                      minnum=ops$minnum,
                                      ppm=ops$ppm,
                                      snr=ops$snr,
                                      ra=ops$ra,
                                      snr_pre=ops$snr_pre,
                                      ra_pre=ops$ra_pre,
                                      av=ops$av,
                                      sum_i=sum_i,
                                      plim=ops$plim,
                                      remove_peaks=remove_peaks,
                                      cores=ops$cores)

} else if(opt$av_level=="inter"){

  pa <- msPurity::averageInterFragSpectra(pa, 
                                      minfrac=ops$minfrac,
                                      minnum=ops$minnum,
                                      ppm=ops$ppm,
                                      snr=ops$snr,
                                      ra=ops$ra,
                                      av=ops$av,
                                      sum_i=sum_i,
                                      plim=ops$plim,
                                      remove_peaks=remove_peaks,
                                      cores=ops$cores)
} else if(opt$av_level=="all"){

  pa <- msPurity::averageAllFragSpectra(pa, 
                                        minfrac=ops$minfrac,
                                        minnum=ops$minnum,
                                        ppm=ops$ppm,
                                        snr=ops$snr,
                                        ra=ops$ra,
                                        snr_pre=ops$snr_pre,
                                        ra_pre=ops$ra_pre,
                                        av=ops$av,
                                        sum_i=sum_i,
                                        plim=ops$plim,
                                        remove_peaks=remove_peaks,
                                        cores=ops$cores)

}

save(pa, file=file.path(opt$out_dir, paste('average_', opt$av_level, '_fragementation_spectra.RData', sep=""))

