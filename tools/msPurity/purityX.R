library(msPurity)
library(optparse)
print(sessionInfo())

option_list <- list(
  make_option(c("--xset_path"), type = "character"),
  make_option(c("-o", "--out_dir"), type = "character"),
  make_option(c("--mzML_path"), type = "character"),
  make_option("--minOffset", default = 0.5),
  make_option("--maxOffset", default = 0.5),
  make_option("--ilim", default = 0.05),
  make_option("--iwNorm", default = "none", type = "character"),
  make_option("--exclude_isotopes", action = "store_true"),
  make_option("--isotope_matrix", type = "character"),
  make_option("--purityType", default = "purityFWHMmedian"),
  make_option("--singleFile", default = 0),
  make_option("--cores", default = 4),
  make_option("--xgroups", type = "character"),
  make_option("--camera_xcms", default = "xset"),
  make_option("--files", type = "character"),
  make_option("--galaxy_files", type = "character"),
  make_option("--choose_class", type = "character"),
  make_option("--ignore_files", type = "character"),
  make_option("--rtraw_columns", action = "store_true")
)


opt <- parse_args(OptionParser(option_list = option_list))
print(opt)


if (!is.null(opt$xgroups)) {
  xgroups <- as.numeric(strsplit(opt$xgroups, ",")[[1]])
} else {
  xgroups <- NULL
}


print(xgroups)

if (!is.null(opt$remove_nas)) {
  df <- df[!is.na(df$mz), ]
}

if (is.null(opt$isotope_matrix)) {
  im <- NULL
} else {
  im <- read.table(opt$isotope_matrix,
    header = TRUE, sep = "\t", stringsAsFactors = FALSE
  )
}

if (is.null(opt$exclude_isotopes)) {
  isotopes <- FALSE
} else {
  isotopes <- TRUE
}

if (is.null(opt$rtraw_columns)) {
  rtraw_columns <- FALSE
} else {
  rtraw_columns <- TRUE
}

loadRData <- function(rdata_path, xnames) {
  # loads an RData file, and returns the named xset object if it is there
  load(rdata_path)
  return(get(ls()[ls() %in% xnames]))
}




getxcmsSetObject <- function(xobject) {
  # XCMS 1.x
  if (class(xobject) == "xcmsSet"){
    return(xobject)
  }
  # XCMS 3.x
  if (class(xobject) == "XCMSnExp") {
    # Get the legacy xcmsSet object
    suppressWarnings(xset <- as(xobject, "xcmsSet"))
    if (!is.null(xset@phenoData$sample_group)){
      xcms::sampclass(xset) <- xset@phenoData$sample_group
    }else{
      xcms::sampclass(xset) <- "."
    }
    return(xset)
  }
}

target_obj <- loadRData(opt$xset_path, c('xset', 'xa', 'xdata'))

if (opt$camera_xcms == "camera") {
  xset <- target_obj@xcmsSet
} else {
  xset <- target_obj
}

xset <- getxcmsSetObject(xset)

print(xset)

minOffset <- as.numeric(opt$minOffset)
maxOffset <- as.numeric(opt$maxOffset)

if (opt$iwNorm == "none") {
  iwNorm <- FALSE
  iwNormFun <- NULL
} else if (opt$iwNorm == "gauss") {
  iwNorm <- TRUE
  iwNormFun <- msPurity::iwNormGauss(minOff = -minOffset, maxOff = maxOffset)
} else if (opt$iwNorm == "rcosine") {
  iwNorm <- TRUE
  iwNormFun <- msPurity::iwNormRcosine(minOff = -minOffset, maxOff = maxOffset)
} else if (opt$iwNorm == "QE5") {
  iwNorm <- TRUE
  iwNormFun <- msPurity::iwNormQE.5()
}

print(xset@filepaths)

if (!is.null(opt$files)) {
  updated_filepaths <- trimws(strsplit(opt$files, ",")[[1]])
  updated_filepaths <- updated_filepaths[updated_filepaths != ""]
  print(updated_filepaths)
  updated_filenames <- basename(updated_filepaths)
  original_filenames <- basename(xset@filepaths)
  update_idx <- match(updated_filenames, original_filenames)

  if (!is.null(opt$galaxy_files)) {
    galaxy_files <- trimws(strsplit(opt$galaxy_files, ",")[[1]])
    galaxy_files <- galaxy_files[galaxy_files != ""]
    xset@filepaths <- galaxy_files[update_idx]
  } else {
    xset@filepaths <- updated_filepaths[update_idx]
  }
}

if (!is.null(opt$choose_class)) {
  classes <- trimws(strsplit(opt$choose_class, ",")[[1]])

  ignore_files_class <- which(!as.character(xset@phenoData$class) %in% classes)

  print("choose class")
  print(ignore_files_class)
} else {
  ignore_files_class <- NA
}

if (!is.null(opt$ignore_files)) {
  ignore_files_string <- trimws(strsplit(opt$ignore_files, ",")[[1]])
  filenames <- rownames(xset@phenoData)
  ignore_files <- which(filenames %in% ignore_files_string)

  ignore_files <- unique(c(ignore_files, ignore_files_class))
  ignore_files <- ignore_files[ignore_files != ""]
} else {
  if (anyNA(ignore_files_class)) {
    ignore_files <- NULL
  } else {
    ignore_files <- ignore_files_class
  }
}

print("ignore_files")
print(ignore_files)


ppLCMS <- msPurity::purityX(
  xset = xset,
  offsets = c(minOffset, maxOffset),
  cores = opt$cores,
  xgroups = xgroups,
  purityType = opt$purityType,
  ilim = opt$ilim,
  isotopes = isotopes,
  im = im,
  iwNorm = iwNorm,
  iwNormFun = iwNormFun,
  singleFile = opt$singleFile,
  fileignore = ignore_files,
  rtrawColumns = rtraw_columns
)

dfp <- ppLCMS@predictions

# to make compatable with deconrank
# (keep grpid for other compatibility)
dfp <- data.frame("peakID"=dfp$grpid, dfp)

colnames(dfp)[colnames(dfp) == "median"] <- "medianPurity"
colnames(dfp)[colnames(dfp) == "mean"] <- "meanPurity"
colnames(dfp)[colnames(dfp) == "sd"] <- "sdPurity"
colnames(dfp)[colnames(dfp) == "stde"] <- "sdePurity"
colnames(dfp)[colnames(dfp) == "RSD"] <- "cvPurity"
colnames(dfp)[colnames(dfp) == "pknm"] <- "pknmPurity"

if (sum(is.na(dfp$medianPurity)) > 0) {
  dfp[is.na(dfp$medianPurity), ]$medianPurity <- 0
}

print(head(dfp))
write.table(dfp, file.path(opt$out_dir, "purityX_output.tsv"), row.names = FALSE, sep = "\t")

save.image(file.path(opt$out_dir, "purityX_output.RData"))
