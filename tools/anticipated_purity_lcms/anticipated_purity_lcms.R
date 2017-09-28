library(msPurity)
library(optparse)

option_list <- list(
  make_option(c("--xset_path"), type="character"),
  make_option(c("-o", "--out_dir"), type="character"),
  make_option(c("--mzML_path"), type="character"),
  make_option("--minOffset", default=0.5),
  make_option("--maxOffset", default=0.5),
  make_option("--ilim", default=0.05),
  make_option("--iwNorm", default="none", type="character"),
  make_option("--exclude_isotopes", action="store_true"),
  make_option("--isotope_matrix", type="character"),
  make_option("--purityType", default="purityFWHMmedian"),
  make_option("--singleFile", default=0),
  make_option("--cores", default=1),
  make_option("--xgroups", type="character"),
  make_option("--rdata_name", default='xset'),
  make_option("--camera_xcms", default='xset'),
  make_option("--files", type="character"),
  make_option("--choose_class", type="character"),
  make_option("--ignore_files", type="character")
)

# store options
opt<- parse_args(OptionParser(option_list=option_list))

print(sessionInfo())
print(opt)

if (!is.null(opt$xgroups)){
    xgroups = as.numeric(strsplit(opt$xgroups, ',')[[1]])
}else{
    xgroups = NULL
}



print(xgroups)

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

loadRData <- function(rdata_path, xset_name){
#loads an RData file, and returns the named xset object if it is there
    load(rdata_path)
    print(ls())
    return(get(ls()[ls() == xset_name]))
}

target_obj <- loadRData(opt$xset_path, opt$rdata_name)

if (opt$camera_xcms=='camera'){
    xset <- target_obj@xcmsSet
}else{
    xset <- target_obj
}

print(xset)

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




if (!is.null(opt$files)){


  updated_filepaths <- trimws(strsplit(opt$files, ',')[[1]])
  updated_filepaths <- updated_filepaths[updated_filepaths != ""]
  print(updated_filepaths)
  updated_filenames = basename(updated_filepaths)
  original_filenames = basename(xset@filepaths)
  update_idx = match(updated_filenames, original_filenames)
  xset@filepaths <- updated_filepaths[update_idx]
}

if (!is.null(opt$choose_class)){
  classes <- trimws(strsplit(opt$choose_class, ',')[[1]])
  filenames <- rownames(xset@phenoData)

  ignore_files_class <- filenames[!as.character(xset@phenoData$class) %in% classes]
}else{
  ignore_files_class <- ''
}

if (!is.null(opt$ignore_files)){
  ignore_files <- trimws(strsplit(opt$ignore_files, ',')[[1]])
  ignore_files <- unique(c(ignore_files, ignore_files_class))
  ignore_files <- ignore_files[ignore_files != ""]
}else{
  ignore_files <- NULL
}



ppLCMS <- msPurity::purityX(xset=xset,
                                offsets=c(minOffset, maxOffset),
                                cores=opt$cores,
                                xgroups=xgroups,
                                purityType=opt$purityType,
                                ilim = opt$ilim,
                                isotopes = isotopes,
                                im = im,
                                iwNorm = iwNorm,
                                iwNormFun = iwNormFun,
                                singleFile = opt$singleFile,
                                fileignore = ignore_files)

print('saving tsv')
print(head(ppLCMS@predictions))
write.table(ppLCMS@predictions, file.path(opt$out_dir, 'anticipated_purity_lcms.tsv'), row.names=FALSE, sep='\t')
print('saving RData')
save.image(file.path(opt$out_dir, 'anticipated_purity_lcms.RData'))
