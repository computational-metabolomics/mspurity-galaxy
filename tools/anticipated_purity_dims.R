library(msPurity)
library(optparse)

option_list <- list(
  make_option(c("--mzML_file"), type="character"),
  make_option(c("--peaks_file"), type="character"),
  make_option(c("-o", "--out_dir"), type="character"),
  make_option("--minOffset", default=0.5),
  make_option("--maxOffset", default=0.5),
  make_option("--ilim", default=0.05),
  make_option("--ppm", default=4),
  make_option("--dimspy", action="store_true"),
  make_option("--sim", action="store_true"),
  make_option("--remove_nas", action="store_true"),
  make_option("--iwNorm", default="none", type="character"),
  make_option("--dimspy_file_num", default=1),
  make_option("--exclude_isotopes", action="store_true"),
  make_option("--isotope_matrix", type="character")
)

# store options
opt<- parse_args(OptionParser(option_list=option_list))

print(sessionInfo())
print(opt)

if (opt$dimspy){
  indf <- read.table(opt$peaks_file,
                     header = TRUE, sep='\t', stringsAsFactors = FALSE)
  filename = colnames(indf)[8:ncol(indf)][opt$dimspy_file_num]
  # check if the data file is mzML or RAW (can only use mzML currently) so
  # we expect an mzML file of the same name in the same folder
  indf$i <- indf[,colnames(indf)==filename]
  indf[,colnames(indf)==filename] <- as.numeric(indf[,colnames(indf)==filename])

  filename = sub("raw", "mzML", filename, ignore.case = TRUE)

  df <- indf[4:nrow(indf),]
  if ('blank_flag' %in% colnames(df)){
    df <- df[df$blank_flag==1,]
  }

  colnames(df)[colnames(df)=='m.z'] <- 'mz'

  if ('nan' %in% df$mz){
    df[df$mz=='nan',]$mz <- NA
  }
  df$mz <- as.numeric(df$mz)


}else{
  df <- read.table(opt$peaks_file, header = TRUE, sep='\t')
  filename = NA
}

if (!is.null(opt$remove_nas)){
  df <- df[!is.na(df$mz),]
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

print('FIRST ROWS OF PEAK FILE')
print(head(df))

if (dir.exists(opt$mzML_file)){
  # if directory then we need to add a file name
  print(filename)
  if (is.na(filename)){
    print('ERROR: If a directory is provided then a filename needs to be entered
          directory or automatically obtained by using a dimspy output')
    quit()
  }else{
    mzml_file <- file.path(opt$mzML_file, filename)
  }
}else{
  mzml_file <- opt$mzML_file
}

if (is.null(opt$sim)){
    sim=FALSE
}else{
    sim=TRUE
}

minOffset = as.numeric(opt$minOffset)
maxOffset = as.numeric(opt$maxOffset)



if (opt$iwNorm=='none'){
    iwNorm = FALSE
    iwNormFun = NULL
}else if (opt$iwNorm=='gauss'){
    iwNorm = TRUE
    iwNormFun = msPurity::iwNormGauss(minOff=-minOffset, maxOff=maxOffset)
}else if (opt$iwNorm=='rcosine'){
    iwNorm = TRUE
    iwNormFun = msPurity::iwNormRcosine(minOff=-minOffset, maxOff=maxOffset)
}else if (opt$iwNorm=='QE5'){
    iwNorm = TRUE
    iwNormFun = msPurity::iwNormQE.5()
}


predicted <- msPurity::dimsPredictPuritySingle(df$mz,
                                     filepth=mzml_file,
                                     minOffset=minOffset,
                                     maxOffset=maxOffset,
                                     ppm=opt$ppm,
                                     mzML=TRUE,
                                     sim = sim,
                                     ilim = opt$ilim,
                                     isotopes = isotopes,
                                     im = im,
                                     iwNorm = iwNorm,
                                     iwNormFun = iwNormFun
                                     )
predicted <- cbind(df, predicted)


write.table(predicted, file.path(opt$out_dir, 'anticipated_dims_purity.tsv'), row.names=FALSE, sep='\t')
