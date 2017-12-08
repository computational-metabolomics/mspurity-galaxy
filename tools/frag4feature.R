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
  make_option("--cores", default=4),
  make_option("--mzML_files", type="character"),
  make_option("--galaxy_names", type="character"),
  make_option("--grp_peaklist", type="character")
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

if (!is.null(opt$mzML_files) && !is.null(opt$galaxy_names)){
    # NOTE: This only works if the pa file was generated IN Galaxy!! Relies on
    # the pa@fileList having the names of files given as 'names' of the variables (done in frag4feature)
    # Will update in the next version of msPurity
    filepaths <- trimws(strsplit(opt$mzML_files, ',')[[1]])
    filepaths <- filepaths[filepaths != ""]
    new_names <- basename(filepaths)

    galaxy_names <- trimws(strsplit(opt$galaxy_names, ',')[[1]])
    galaxy_names <- galaxy_names[galaxy_names != ""]

    nsave <- names(pa@fileList)
    old_filenames  <- basename(pa@fileList)
    pa@fileList <- filepaths[match(names(pa@fileList), galaxy_names)]

    pa@puritydf$filename <- basename(pa@fileList[match(pa@puritydf$filename, old_filenames)])
    pa@grped_df$filename <- basename(pa@fileList[match(pa@grped_df$filename, old_filenames)])
}

if(!all(basename(pa@fileList)==basename(xset@filepaths))){
  if(!all(names(pa@fileList)==basename(xset@filepaths))){
    quit(status = 1)
  }else{
    xset@filepaths <- unname(pa@fileList)
  }
}

if(is.null(opt$grp_peaklist)){
    grp_peaklist = NA
}else{
    grp_peaklist = opt$grp_peaklist
}

print(pa)
print(pa@fileList)
print(xset)
print(xset@filepaths)
print(opt$ppm)
print(opt$plim)
print(convert2RawRT)




pa <- msPurity::frag4feature(pa=pa, xset=xset, ppm=opt$ppm, plim=opt$plim,
                            intense=opt$mostIntense, convert2RawRT=convert2RawRT,
                            db_name='alldata.sqlite', out_dir=opt$out_dir, grp_peaklist=grp_peaklist)

save(pa, file=file.path(opt$out_dir, 'frag4feature.RData'))

print(head(pa@grped_df))
write.table(pa@grped_df, file.path(opt$out_dir, 'frag4feature.tsv'), row.names=FALSE, sep='\t')