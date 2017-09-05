library(msPurity)
library(optparse)

option_list <- list(
  make_option(c("--mzML_file"), type="character"),
  make_option(c("--mzs_file"), type="character"),
  make_option(c("-o", "--out_dir"), type="character"),
  make_option("--minOffset", default=0.5),
  make_option("--maxOffset", default=0.5),
  make_option("--ppm", default=4),
  make_option("--sim", action="store_true"),
  make_option("--iwNorm", default="none", type="character")
)

# store options
opt<- parse_args(OptionParser(option_list=option_list))
print(opt$in_file)

mzs <- read.table(opt$mzs_file, header = TRUE, sep='\t')
print(mzs)
print(opt$mzML_file)


if (is.null(opt$sim)){
    sim=FALSE
}else{
    sim=TRUE
}

print(sim)

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
    iwNormFun = msPurity::iwNormQE()
}


predicted <- msPurity::dimsPredictPuritySingle(mzs$mz,
                                     filepth=opt$mzML_file,
                                     minOffset=opt$minOffset,
                                     maxOffset=opt$maxOffset,
                                     ppm=opt$ppm,
                                     mzML=TRUE,
                                     sim = sim,
                                     iwNorm = iwNorm, iwNormFun = iwNormFun)
predicted <- cbind(mzs, predicted)


write.table(predicted, file.path(opt$out_dir, 'anticipated_dims_purity.txt'), row.names=FALSE, sep='\t')
