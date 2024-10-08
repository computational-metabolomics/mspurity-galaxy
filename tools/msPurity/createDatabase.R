library(msPurity)
library(optparse)
library(xcms)
library(CAMERA)
print(sessionInfo())
print("CREATING DATABASE")

xset_pa_filename_fix <- function(opt, pa, xset) {
  if (!is.null(opt$mzML_files) && !is.null(opt$galaxy_names)) {
    # NOTE: Relies on the pa@fileList having the names of files given as 'names' of the variables
    # needs to be done due to Galaxy moving the files around and screwing up any links to files

    filepaths <- trimws(strsplit(opt$mzML_files, ",")[[1]])
    filepaths <- filepaths[filepaths != ""]

    galaxy_names <- trimws(strsplit(opt$galaxy_names, ",")[[1]])
    galaxy_names <- galaxy_names[galaxy_names != ""]

    nsave <- names(pa@fileList)
    old_filenames <- basename(pa@fileList)
    pa@fileList <- filepaths[match(names(pa@fileList), galaxy_names)]
    names(pa@fileList) <- nsave

    pa@puritydf$filename <- basename(pa@fileList[match(pa@puritydf$filename, old_filenames)])
    pa@grped_df$filename <- basename(pa@fileList[match(pa@grped_df$filename, old_filenames)])
  }


  if (!all(basename(pa@fileList) == basename(xset@filepaths))) {
    if (!all(names(pa@fileList) == basename(xset@filepaths))) {
      print("FILELISTS DO NOT MATCH")
      message("FILELISTS DO NOT MATCH")
      quit(status = 1)
    } else {
      xset@filepaths <- unname(pa@fileList)
    }
  }

  print(xset@phenoData)
  print(xset@filepaths)

  return(list(pa, xset))
}




option_list <- list(
  make_option(c("-o", "--outDir"), type = "character"),
  make_option("--pa", type = "character"),
  make_option("--xset_xa", type = "character"),
  make_option("--xcms_camera_option", type = "character"),
  make_option("--eic", action = "store_true"),
  make_option("--cores", default = 4),
  make_option("--mzML_files", type = "character"),
  make_option("--galaxy_names", type = "character"),
  make_option("--grpPeaklist", type = "character")
)


# store options
opt <- parse_args(OptionParser(option_list = option_list))
print(opt)

loadRData <- function(rdata_path, name) {
  # loads an RData file, and returns the named xset object if it is there
  load(rdata_path)
  return(get(ls()[ls() %in% name]))
}

getxcmsSetObject <- function(xobject) {
  # XCMS 1.x
  if (class(xobject) == "xcmsSet") {
    return(xobject)
  }
  # XCMS 3.x
  if (class(xobject) == "XCMSnExp") {
    # Get the legacy xcmsSet object
    suppressWarnings(xset <- as(xobject, "xcmsSet"))
    xcms::sampclass(xset) <- xset@phenoData$sample_group
    return(xset)
  }
}


print(paste("pa", opt$pa))
print(opt$xset)

print(opt$xcms_camera_option)
# Requires
pa <- loadRData(opt$pa, "pa")


print(pa@fileList)

# Missing list element causes failures (should be updated
# in msPurity R package for future releases)
if (!exists("allfrag", where = pa@filter_frag_params)) {
  pa@filter_frag_params$allfrag <- FALSE
}

if (opt$xcms_camera_option == "xcms") {
  xset <- loadRData(opt$xset, c("xset", "xdata"))
  xset <- getxcmsSetObject(xset)
  fix <- xset_pa_filename_fix(opt, pa, xset)
  pa <- fix[[1]]
  xset <- fix[[2]]
  xa <- NULL
} else {
  xa <- loadRData(opt$xset, "xa")
  fix <- xset_pa_filename_fix(opt, pa, xa@xcmsSet)
  pa <- fix[[1]]
  xa@xcmsSet <- fix[[2]]
  xset <- NULL
}


if (is.null(opt$grpPeaklist)) {
  grpPeaklist <- NA
} else {
  grpPeaklist <- opt$grpPeaklist
}

dbPth <- msPurity::createDatabase(pa,
  xset = xset,
  xsa = xa,
  outDir = opt$outDir,
  grpPeaklist = grpPeaklist,
  dbName = "createDatabase_output.sqlite"
)





if (!is.null(opt$eic)) {
  if (is.null(xset)) {
    xset <- xa@xcmsSet
  }
  # previous check should have matched filelists together
  xset@filepaths <- unname(pa@fileList)

  convert2Raw <- function(x, xset) {
    sid <- unique(x$sample)
    # for each file get list of peaks
    x$rt_raw <- xset@rt$raw[[sid]][match(x$rt, xset@rt$corrected[[sid]])]
    x$rtmin_raw <- xset@rt$raw[[sid]][match(x$rtmin, xset@rt$corrected[[sid]])]
    x$rtmax_raw <- xset@rt$raw[[sid]][match(x$rtmax, xset@rt$corrected[[sid]])]
    return(x)
  }

  xset@peaks <- as.matrix(
    plyr::ddply(data.frame(xset@peaks), ~sample, convert2Raw, xset = xset)
  )

  # Saves the EICS into the previously created database
  px <- msPurity::purityX(xset,
    saveEIC = TRUE,
    cores = 1,
    sqlitePth = dbPth,
    rtrawColumns = TRUE
  )
}

closeAllConnections()
