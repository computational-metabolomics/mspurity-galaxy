library(optparse)
library(msPurity)
library(xcms)
print(sessionInfo())


get_av_spectra <- function(x){

  if (length(x$av_intra)>0){
    av_intra_df <- plyr::ldply(x$av_intra)

    if (nrow(av_intra_df)==0){
      av_intra_df <- NULL
    }else{
      av_intra_df$method <- 'intra'
    }

  }else{
    av_intra_df <- NULL
  }

  if ((is.null(x$av_inter)) || (nrow(x$av_inter)==0)){
    av_inter_df <- NULL
  }else{
    av_inter_df <- x$av_inter
    av_inter_df$method <- 'inter'
  }

  if ((is.null(x$av_all)) || (nrow(x$av_all)==0)){
    av_all_df <- NULL
  }else{
    av_all_df <- x$av_all
    av_all_df$method <- 'all'
  }

  combined <- plyr::rbind.fill(av_intra_df, av_inter_df, av_all_df)

  return(combined)
}


option_list <- list(
  make_option("--out_rdata", type="character"),
  make_option("--out_peaklist", type="character"),
  make_option("--pa", type="character"),

  make_option("--av_level", type="character"),

  make_option("--minfrac", default=0.5),
  make_option("--minnum", default=1),
  make_option("--ppm", default=5.0),

  make_option("--snr", default=0),

  make_option("--ra", default=0),

  make_option("--av", default="median", type="character"),
  make_option("--sumi", action="store_true"),

  make_option("--rmp", action="store_true"),
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

if(is.null(opt$rmp)){
  rmp = FALSE
}else{
  rmp = TRUE
}

if(is.null(opt$sumi)){

  sumi = FALSE
}else{
  sumi = TRUE

}


if(opt$av_level=="intra"){

  pa <- msPurity::averageIntraFragSpectra(pa,
                                      minfrac=opt$minfrac,
                                      minnum=opt$minnum,
                                      ppm=opt$ppm,
                                      snr=opt$snr,
                                      ra=opt$ra,
                                      av=opt$av,
                                      sumi=sumi,
                                      rmp=rmp,
                                      cores=opt$cores)

} else if(opt$av_level=="inter"){

  pa <- msPurity::averageInterFragSpectra(pa,
                                      minfrac=opt$minfrac,
                                      minnum=opt$minnum,
                                      ppm=opt$ppm,
                                      snr=opt$snr,
                                      ra=opt$ra,
                                      av=opt$av,
                                      sumi=sumi,
                                      rmp=rmp,
                                      cores=opt$cores)
} else if(opt$av_level=="all"){

  pa <- msPurity::averageAllFragSpectra(pa,
                                        minfrac=opt$minfrac,
                                        minnum=opt$minnum,
                                        ppm=opt$ppm,
                                        snr=opt$snr,
                                        ra=opt$ra,
                                        av=opt$av,
                                        sumi=sumi,
                                        rmp=rmp,
                                        cores=opt$cores)

}

print(pa)
save(pa, file=opt$out_rdata)


if (length(pa)>0){

  av_spectra <- plyr::ldply(pa@av_spectra, get_av_spectra)

  if (nrow(av_spectra)==0){
    message('No average spectra available')
  } else{
    colnames(av_spectra)[1] <- 'grpid'
    av_spectra$grpid <- names(pa@av_spectra)[av_spectra$grpid]
    
    if((length(pa@av_intra_params)>0) || (length(pa@av_inter_params)>0) ){
        # Add some extra info (only required if av_intra or av_inter performed)
        colnames(av_spectra)[2] <- 'fileid'
        av_spectra$avid <- 1:nrow(av_spectra)
        
        filenames <- sapply(av_spectra$fileid, function(x) names(pa@fileList)[as.integer(x)])
        # filenames_galaxy <- sapply(av_spectra$fileid, function(x) basename(pa@fileList[as.integer(x)]))
        
        av_spectra = as.data.frame(append(av_spectra, list(filename = filenames), after=2))
    }


    print(head(av_spectra))
    write.table(av_spectra, opt$out_peaklist, row.names=FALSE, sep='\t')

  }
}

