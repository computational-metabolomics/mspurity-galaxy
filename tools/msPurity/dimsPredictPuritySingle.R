library(msPurity)
library(optparse)
print(sessionInfo())

option_list <- list(
  make_option(c("--mzML_file"), type="character"),
  make_option(c("--mzML_files"), type="character"),
  make_option(c("--mzML_filename"), type="character", default=''),
  make_option(c("--mzML_galaxy_names"), type="character", default=''),
  make_option(c("--peaks_file"), type="character"),
  make_option(c("-o", "--out_dir"), type="character"),
  make_option("--minoffset", default=0.5),
  make_option("--maxoffset", default=0.5),
  make_option("--ilim", default=0.05),
  make_option("--ppm", default=4),
  make_option("--dimspy", action="store_true"),
  make_option("--sim", action="store_true"),
  make_option("--remove_nas", action="store_true"),
  make_option("--iwNorm", default="none", type="character"),
  make_option("--file_num_dimspy", default=1),
  make_option("--exclude_isotopes", action="store_true"),
  make_option("--isotope_matrix", type="character")
)

# store options
opt<- parse_args(OptionParser(option_list=option_list))

print(sessionInfo())
print(opt)

print(opt$mzML_files)
print(opt$mzML_galaxy_names)

str_to_vec <- function(x){
    print(x)
    x <- trimws(strsplit(x, ',')[[1]])
    return(x[x != ""])
}

find_mzml_file <- function(mzML_files, galaxy_names, mzML_filename){
    mzML_filename <- trimws(mzML_filename)
    mzML_files <- str_to_vec(mzML_files)
    galaxy_names <- str_to_vec(galaxy_names)
    if (mzML_filename %in% galaxy_names){
        return(mzML_files[galaxy_names==mzML_filename])
    }else{
        stop(paste("mzML file not found - ", mzML_filename))
    }
}


if (is.null(opt$dimspy)){
    df <- read.table(opt$peaks_file, header = TRUE, sep='\t')
    if (file.exists(opt$mzML_file)){
        mzML_file <- opt$mzML_file
    }else if (!is.null(opt$mzML_files)){
        mzML_file <- find_mzml_file(opt$mzML_files, opt$mzML_galaxy_names, 
                                    opt$mzML_filename)
    }else{
        mzML_file <- file.path(opt$mzML_file, filename)    
    }	
}else{
    indf <- read.table(opt$peaks_file,
                       header = TRUE, sep='\t', stringsAsFactors = FALSE)
    
    filename <- colnames(indf)[8:ncol(indf)][opt$file_num_dimspy]
    print(filename)
    # check if the data file is mzML or RAW (can only use mzML currently) so
    # we expect an mzML file of the same name in the same folder
    indf$i <- indf[,colnames(indf)==filename]
    indf[,colnames(indf)==filename] <- as.numeric(indf[,colnames(indf)==filename])
    
    filename = sub("raw", "mzML", filename, ignore.case = TRUE)
    print(filename)
    
    
    if (file.exists(opt$mzML_file)){
        mzML_file <- opt$mzML_file
    }else if (!is.null(opt$mzML_files)){
        mzML_file <- find_mzml_file(opt$mzML_files, opt$mzML_galaxy_names, filename)
    }else{
        mzML_file <- file.path(opt$mzML_file, filename)    
    }	
    
    # Update the dimspy output with the correct information 
    df <- indf[4:nrow(indf),]
    if ('blank_flag' %in% colnames(df)){
        df <- df[df$blank_flag==1,]
    }
    colnames(df)[colnames(df)=='m.z'] <- 'mz'
    
    if ('nan' %in% df$mz){
        df[df$mz=='nan',]$mz <- NA
    }
    df$mz <- as.numeric(df$mz)
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

if (is.null(opt$sim)){
    sim=FALSE
}else{
    sim=TRUE
}

minOffset = as.numeric(opt$minoffset)
maxOffset = as.numeric(opt$maxoffset)

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

print('FIRST ROWS OF PEAK FILE')
print(head(df))
print(mzML_file)
predicted <- msPurity::dimsPredictPuritySingle(df$mz,
                                     filepth=mzML_file,
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

print(head(predicted))
print(file.path(opt$out_dir, 'dimsPredictPuritySingle_output.tsv'))

write.table(predicted, 
            file.path(opt$out_dir, 'dimsPredictPuritySingle_output.tsv'),
            row.names=FALSE, sep='\t')


