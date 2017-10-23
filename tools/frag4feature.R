library(msPurity)
library(optparse)

option_list <- list(
  make_option(c("-o", "--out_dir"), type="character"),
  make_option("--pa", type="character"),
  make_option("--xset", type="character"),
  make_option("--ppm", default=10),
  make_option("--plim", default=0.0),
  make_option("--convert2RawRT", action="store_true"),
  make_option("--mostIntense", action="store_true"),
  make_option("--cores", default=4)
)

# store options
opt<- parse_args(OptionParser(option_list=option_list))

loadRData <- function(rdata_path, name){
#loads an RData file, and returns the named xset object if it is there
    load(rdata_path)
    return(get(ls()[ls() == name]))
}

# Requires
pa <- loadRData(opt$pa, 'pa')
xset <- loadRData(opt$xset, 'xset')

pa@cores <- opt$cores

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

# Makes sure the same files are being used
if(!all(basename(pa@fileList)==basename(xset@filepaths))){
  if(!all(names(pa@fileList)==basename(xset@filepaths))){
    quit(status = 1)
  }else{
    xset@filepaths <- unname(pa@fileList)
  }
}

pa <- msPurity::frag4feature(pa=pa, xset=xset, ppm=opt$ppm, plim=opt$plim,
                            intense=opt$mostIntense, convert2RawRT=convert2RawRT)

save(pa, file=file.path(opt$out_dir, 'frag4feature.RData'))

print(head(pa@puritydf))
write.table(pa@grped_df, file.path(opt$out_dir, 'frag4feature.tsv'), row.names=FALSE, sep='\t')