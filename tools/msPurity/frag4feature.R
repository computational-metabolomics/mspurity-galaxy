library(optparse)
library(msPurity)
library(xcms)
print(sessionInfo())

xset_pa_filename_fix <- function(opt, pa, xset=NULL) {


  if (!is.null(opt$mzML_files) && !is.null(opt$galaxy_names)) {
    # NOTE: Relies on the pa@fileList having the names of files given as 'names' of the variables
    # needs to be done due to Galaxy moving the files around and screwing up any links to files

    filepaths <- trimws(strsplit(opt$mzML_files, ",")[[1]]) # nolint

    filepaths <- filepaths[filepaths != ""]

    galaxy_names <- trimws(strsplit(opt$galaxy_names, ",")[[1]])
    galaxy_names <- galaxy_names[galaxy_names != ""]

    nsave <- names(pa@fileList)
    old_filenames  <- basename(pa@fileList)

    pa@fileList <- filepaths[match(names(pa@fileList), galaxy_names)]
    names(pa@fileList) <- nsave

    pa@puritydf$filename <- basename(pa@fileList[match(pa@puritydf$filename, old_filenames)])
    pa@grped_df$filename <- basename(pa@fileList[match(pa@grped_df$filename, old_filenames)])
  }
  print(pa@fileList)

  if (!is.null(xset)) {

    print(xset@filepaths)

    if (!all(basename(pa@fileList) == basename(xset@filepaths))) {
       if (!all(names(pa@fileList) == basename(xset@filepaths))) {
          print("FILELISTS DO NOT MATCH")
          message("FILELISTS DO NOT MATCH")
          quit(status = 1)
       }else{
          xset@filepaths <- unname(pa@fileList)
       }
   }
 }

  return(list(pa, xset))
}


option_list <- list(
  make_option(c("-o", "--out_dir"), type = "character"),
  make_option("--pa", type = "character"),
  make_option("--xset", type = "character"),
  make_option("--ppm", default = 10),
  make_option("--plim", default = 0.0),
  make_option("--convert2RawRT", action = "store_true"),
  make_option("--intense", action = "store_true"),
  make_option("--createDB", action = "store_true"),
  make_option("--cores", default = 4),
  make_option("--mzML_files", type = "character"),
  make_option("--galaxy_names", type = "character"),
  make_option("--grp_peaklist", type = "character"),
  make_option("--useGroup", action = "store_true")
)

# store options
opt <- parse_args(OptionParser(option_list = option_list))
print(opt)

loadRData <- function(rdata_path, name) {
#loads an RData file, and returns the named xset object if it is there
    load(rdata_path)
    return(get(ls()[ls() %in% name]))
}

# This function retrieve a xset like object
#@author Gildas Le Corguille lecorguille@sb-roscoff.fr
getxcmsSetObject <- function(xobject) {
    # XCMS 1.x
    if (class(xobject) == "xcmsSet")
        return(xobject)
    # XCMS 3.x
    if (class(xobject) == "XCMSnExp") {
        # Get the legacy xcmsSet object
        suppressWarnings(xset <- as(xobject, "xcmsSet"))
        sampclass(xset) <- xset@phenoData$sample_group
        return(xset)
    }
}

# Requires
pa <- loadRData(opt$pa, "pa")
xset <- loadRData(opt$xset, c("xset", "xdata"))
xset <- getxcmsSetObject(xset)

pa@cores <- opt$cores

print(pa@fileList)
print(xset@filepaths)

if (is.null(opt$intense)) {
  intense <- FALSE
}else{
  intense <- TRUE
}

if (is.null(opt$convert2RawRT)) {
    convert2RawRT <- FALSE
}else{
    convert2RawRT <- TRUE
}

if (is.null(opt$createDB)) {
    createDB <- FALSE
}else{
    createDB <- TRUE
}

if (is.null(opt$useGroup)) {
    fix <- xset_pa_filename_fix(opt, pa, xset)
    pa <- fix[[1]]
    xset <- fix[[2]]
    useGroup <- FALSE
}else{
    # if are only aligning to the group not eah file we do not need to align the files between the xset and pa object
    print("useGroup")
    fix <- xset_pa_filename_fix(opt, pa)
    pa <- fix[[1]]
    useGroup <- TRUE
}


if (is.null(opt$grp_peaklist)) {
    grp_peaklist <- NA
}else{
    grp_peaklist <- opt$grp_peaklist
}
print(useGroup)

pa <- msPurity::frag4feature(pa = pa,
                             xset = xset,
                             ppm = opt$ppm,
                             plim = opt$plim,
                             intense = intense,
                             convert2RawRT = convert2RawRT,
                             db_name = "alldata.sqlite",
                             out_dir = opt$out_dir,
                             grp_peaklist = grp_peaklist,
                             create_db = createDB,
                             use_group = useGroup)
print(pa)
save(pa, file = file.path(opt$out_dir, "frag4feature_output.RData"))

pa@grped_df$filename <- sapply(pa@grped_df$fileid, function(x) names(pa@fileList)[as.integer(x)])

print(head(pa@grped_df))
write.table(pa@grped_df, file.path(opt$out_dir, "frag4feature_output.tsv"), row.names = FALSE, sep = "\t")
