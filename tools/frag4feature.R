#!/usr/bin/env Rscript


# ----- LOG FILE -----
#log_file <- file("assess_purity_log.txt", open="wt")
#sink(log_file)
#sink(log_file, type = "output")


# ----- PACKAGE -----
cat("\tSESSION INFO\n")

#source_local <- function(fname){ argv <- commandArgs(trailingOnly=FALSE); base_dir <- dirname(substring(argv[grep("--file=", argv)], 8)); source(paste(base_dir, fname, sep="/")) }
#source_local("lib.r")

#Import the different functions
#Modify the frag4feature functions (DELETE IT AFTER)
source("/home/jsaintvanne/W4M/mspurity-galaxyTest/tools/lib.R")
pkgs <- c("xcms","optparse")#,"batch")#,"msPurity")
loadAndDisplayPackages(pkgs)
cat("\n\n")

source("/home/jsaintvanne/W4M/msPurityTest/R/create_database.R")
source("/home/jsaintvanne/W4M/msPurityTest/R/purityA-class.R")
source("/home/jsaintvanne/W4M/msPurityTest/R/flag-filter-remove.R")
source("/home/jsaintvanne/W4M/msPurityTest/R/purityA-constructor.R")
source("/home/jsaintvanne/W4M/msPurityTest/R/purityA-frag4feature.R")
source("/home/jsaintvanne/W4M/msPurityTest/R/iw-norm.R")
source("/home/jsaintvanne/W4M/msPurityTest/R/pcalc.R")



# ----- ARGUMENTS -----
cat("\tARGUMENTS INFO\n\n")
#args <- parseCommandArgs(evaluate = FALSE) #interpretation of arguments given in command line as an R list of objects
#write.table(as.matrix(args), col.names=F, quote=F, sep='\t')


option_list <- list(
  make_option(c("-o", "--out_dir"), type="character"),
  make_option("--pa", type="character"),
  make_option("--xset", type="character"),
  make_option("--fileMatchingFile", type="character"),
  make_option("--ppm", default=10),
  make_option("--plim", default=0.0),
  make_option("--convert2RawRT", action="store_true"),
  make_option("--mostIntense", action="store_true"),
  make_option("--createDB", action="store_true"),
  make_option("--cores", default=4),
  make_option("--mzML_files", type="character"),
  make_option("--galaxy_names", type="character"),
  make_option("--grp_peaklist", type="character")
)

# store options
opt <- parse_args(OptionParser(option_list=option_list))

print(opt)

# Requires
pa <- loadRData(opt$pa, 'pa')
xdata <- loadRData(opt$xset, c('xset','xdata'))
#xset <- getxcmsSetObject(xdata)

pa@cores <- opt$cores

if(is.null(opt$fileMatchingFile)){
  CSVfile <- NULL
}else{
  CSVfile <- opt$fileMatchingFile
}

if(is.null(opt$mostIntense)){
    mostIntense = FALSE
}else{
    mostIntense = TRUE
}

if(is.null(opt$convert2RawRT)){
    convert2RawRT = FALSE
}else{
    convert2RawRT= TRUE
}

if(is.null(opt$createDB)){
    createDB = FALSE
}else{
    createDB = TRUE
}


#fix <- xset_pa_filename_fix(opt, pa, xset)
#pa <- fix[[1]]
#xset <- fix[[2]]

if(is.null(opt$grp_peaklist)){
    grp_peaklist = NA
}else{
    grp_peaklist = opt$grp_peaklist
}


cat("\n\n")

# ----- PROCESSING INFILE -----
cat("\tARGUMENTS PROCESSING INFO\n")


cat("\n\n")

# ----- INFILE PROCESSING -----
cat("\tINFILE PROCESSING INFO\n")
cat("\n\n")

# ----- MAIN PROCESSING INFO -----
cat("\tMAIN PROCESSING INFO\n")


cat("\t\tCOMPUTE\n\n")

saveRDS(pa, 'test_pa.rds')

pa <- frag4feature(pa=pa, xdata=xdata, CSVfile=CSVfile, ppm=opt$ppm, plim=opt$plim,
                   intense=opt$mostIntense, convert2RawRT=convert2RawRT,
                   db_name='alldata.sqlite', out_dir=opt$out_dir, grp_peaklist=grp_peaklist,
                   create_db=createDB)

object2save <- c("pa")
save(list=object2save[object2save %in% ls()], file=file.path(opt$out_dir, 'frag4feature.RData'))


write.table(pa@grped_df, file.path(opt$out_dir, 'frag4feature.tsv'), row.names=FALSE, sep='\t')