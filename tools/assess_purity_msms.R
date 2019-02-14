#!/usr/bin/env Rscript

# ----- LOG FILE -----
#log_file <- file("assess_purity_log.txt", open="wt")
#sink(log_file)
#sink(log_file, type = "output")

# ----- PACKAGE -----
cat("\tSESSION INFO\n")

#Import the different functions
#Modify the frag4feature functions (DELETE IT AFTER)
source("/home/jsaintvanne/W4M/mspurity-galaxyTest/tools/lib.R")
pkgs <- c("xcms","optparse","tools","batch","msPurity")
loadAndDisplayPackages(pkgs)
cat("\n\n")

#source_local <- function(fname){ argv <- commandArgs(trailingOnly=FALSE); base_dir <- dirname(substring(argv[grep("--file=", argv)], 8)); source(paste(base_dir, fname, sep="/")) }
#source_local("lib.r")

# ----- ARGUMENTS -----
cat("\tARGUMENTS INFO\n\n")

# List options
option_list <- list(
  make_option(c("-o", "--out_dir"), type="character"),
  make_option("--singlefile_galaxyPath", type="character"),
  make_option("--singlefile_sampleName", type="character"),
  make_option("--minOffset", default=0.5),
  make_option("--maxOffset", default=0.5),
  make_option("--ilim", default=0.05),
  make_option("--iwNorm", default="none", type="character"),
  make_option("--exclude_isotopes", action="store_true"),
  make_option("--isotope_matrix", type="character"),
  make_option("--mostIntense", action="store_true"),
  make_option("--plotP", action="store_true"),
  make_option("--nearest", action="store_true"),
  make_option("--cores", default=1)
)

# Store options
opt <- parse_args(OptionParser(option_list=option_list))
print(opt)

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
    im <- read.table(opt$isotope_matrix, header = TRUE, sep='\t', stringsAsFactors = FALSE)
}

if (is.null(opt$exclude_isotopes)){
    isotopes <- FALSE
}else{
    isotopes <- TRUE
}

print(opt)

cat("\n")

# ----- PROCESSING INFILE -----
cat("\tARGUMENTS PROCESSING INFO\n\n")

zipfile <- NULL
filepaths <- getRawfilePathFromArguments(opt$singlefile_galaxyPath,zipfile,opt)
cat("\n")

# ----- INFILE PROCESSING -----
cat("\tINFILE PROCESSING INFO\n")

if(is.null("singlefile_galaxyPath") || ("singlefile_galaxyPath" == "" )){
  message("no file as input")
  return(NULL)
}

cat("\n\n")


# ----- MAIN PROCESSING INFO -----
cat("\tMAIN PROCESSING INFO\n")


cat("\t\tCOMPUTE\n")

pa <- msPurity::purityA(fileList = filepaths$singlefile,
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
              im = im)


cat("\n\n")


# ----- EXPORT -----

write.table(pa@puritydf, file.path(opt$out_dir, 'purity_msms.tsv'), row.names=FALSE, sep='\t', quote=FALSE)

#saving R data in .Rdata file to save the variables used in the present tool
objects2save <- c("pa")
save(list=objects2save[objects2save %in% ls()], file=file.path(opt$out_dir, 'purity_msms.RData'))

# removed_peaks <- data.frame(removed_peaks)
# write.table(data.frame('ID'=rownames(removed_peaks),removed_peaks),
#         file.path(opt$out_dir, 'removed_peaks.txt'), row.names=FALSE, sep='\t')

cat("\tDONE\n")