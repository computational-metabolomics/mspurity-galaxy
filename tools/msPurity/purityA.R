library(msPurity)
library(optparse)
print(sessionInfo())

option_list <- list(
  make_option(c("-o", "--out_dir"), type="character"),
  make_option("--mzML_files", type="character"),
  make_option("--galaxy_names", type="character"),
  make_option("--minOffset", type="numeric"),
  make_option("--maxOffset", type="numeric"),
  make_option("--ilim", type="numeric"),
  make_option("--iwNorm", default="none", type="character"),
  make_option("--exclude_isotopes", action="store_true"),
  make_option("--isotope_matrix", type="character"),
  make_option("--mostIntense", action="store_true"),
  make_option("--plotP", action="store_true"),
  make_option("--nearest", action="store_true"),
  make_option("--cores", default=4),
  make_option("--ppmInterp", default=7)
)

opt <- parse_args(OptionParser(option_list=option_list))
print(opt)


if (opt$iwNorm=='none'){
    iwNorm = FALSE
    iwNormFun = NULL
}else if (opt$iwNorm=='gauss'){
    iwNorm = TRUE
    if (is.null(opt$minOffset) || is.null(opt$maxOffset)){
      print('User has to define offsets if using Gaussian normalisation')
    }else{
      iwNormFun = msPurity::iwNormGauss(minOff=-as.numeric(opt$minOffset), 
                                      maxOff=as.numeric(opt$maxOffset))
    }
}else if (opt$iwNorm=='rcosine'){
    iwNorm = TRUE
    if (is.null(opt$minOffset) || is.null(opt$maxOffset)){
      print('User has to define offsets if using R-cosine normalisation')
    }else{
      iwNormFun = msPurity::iwNormRcosine(minOff=-as.numeric(opt$minOffset), 
                                          maxOff=as.numeric(opt$maxOffset))
    }
}else if (opt$iwNorm=='QE5'){
    iwNorm = TRUE
    iwNormFun = msPurity::iwNormQE.5()
}

filepaths <- trimws(strsplit(opt$mzML_files, ',')[[1]])
filepaths <- filepaths[filepaths != ""]



if(is.null(opt$minOffset) || is.null(opt$maxOffset)){
    offsets = NA
}else{
    offsets = as.numeric(c(opt$minOffset, opt$maxOffset))
}


if(is.null(opt$mostIntense)){
    mostIntense = FALSE
}else{
    mostIntense = TRUE
}

if(is.null(opt$nearest)){
    nearest = FALSE
}else{
    nearest = TRUE
}

if(is.null(opt$plotP)){
    plotP = FALSE
    plotdir = NULL
}else{
    plotP = TRUE
    plotdir = opt$out_dir
}


if (is.null(opt$isotope_matrix)){
    im <- NULL
}else{
    im <- read.table(opt$isotope_matrix,
                     header = TRUE, sep='\t', stringsAsFactors = FALSE)
}

if (is.null(opt$exclude_isotopes)){
    isotopes <- FALSE
}else{
    isotopes <- TRUE
}

pa <- msPurity::purityA(filepaths,
                        cores = opt$cores,
                        mostIntense = mostIntense,
                        nearest = nearest,
                        offsets = offsets,
                        plotP = plotP,
                        plotdir = plotdir,
                        interpol = "linear",
                        iwNorm = iwNorm,
                        iwNormFun = iwNormFun,
                        ilim = opt$ilim,
                        mzRback = "pwiz",
                        isotopes = isotopes,
                        im = im,
                        ppmInterp = opt$ppmInterp)


if (!is.null(opt$galaxy_names)){
    galaxy_names <- trimws(strsplit(opt$galaxy_names, ',')[[1]])
    galaxy_names <- galaxy_names[galaxy_names != ""]
    names(pa@fileList) <- galaxy_names
}

print(pa)
save(pa, file=file.path(opt$out_dir, 'purityA_output.RData'))

pa@puritydf$filename <- sapply(pa@puritydf$fileid, function(x) names(pa@fileList)[as.integer(x)])

print(head(pa@puritydf))
write.table(pa@puritydf, file.path(opt$out_dir, 'purityA_output.tsv'), row.names=FALSE, sep='\t')

# removed_peaks <- data.frame(removed_peaks)
# write.table(data.frame('ID'=rownames(removed_peaks),removed_peaks),
#         file.path(opt$out_dir, 'removed_peaks.txt'), row.names=FALSE, sep='\t')
