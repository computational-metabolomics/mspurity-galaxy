library(msPurity)
library(optparse)
library(xcms)
library(CAMERA)
print('CREATING DATABASE')


xset_pa_filename_fix <- function(opt, pa, xset){
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
  print(xset)
  print(xset@filepaths) 
  if(!all(basename(pa@fileList)==basename(xset@filepaths))){
    if(!all(names(pa@fileList)==basename(xset@filepaths))){
      quit(status = 1)
    }else{
      xset@filepaths <- unname(pa@fileList)
    }
  }

  return(list(pa, xset))
}


option_list <- list(
  make_option(c("-o", "--out_dir"), type="character"),
  make_option("--pa", type="character"),
  make_option("--xset_xa", type="character"),
  make_option("--xcms_camera_option", type="character"),
  make_option("--eic", action="store_true"),
  make_option("--cores", default=4),
  make_option("--mzML_files", type="character"),
  make_option("--galaxy_names", type="character"),
  make_option("--grp_peaklist", type="character"),
  make_option("--db_name", type="character", default='lcms_data.sqlite'),
  make_option("--raw_rt_columns", action="store_true")
)

# store options
opt<- parse_args(OptionParser(option_list=option_list))

loadRData <- function(rdata_path, name){
  #loads an RData file, and returns the named xset object if it is there
  load(rdata_path)
  return(get(ls()[ls() == name]))
}

print(paste('pa', opt$pa))
print(opt$xset)
print(opt$xcms_camera_option)
# Requires
pa <- loadRData(opt$pa, 'pa')

if (opt$xcms_camera_option=='xcms'){
  xset <- loadRData(opt$xset, 'xset')
  fix <- xset_pa_filename_fix(opt, pa, xset)  
  pa <- fix[[1]]
  xset <- fix[[2]]
  xa <- NULL
}else{
  
  xa <- loadRData(opt$xset, 'xa')
  fix <- xset_pa_filename_fix(opt, pa, xa@xcmsSet)  
  pa <- fix[[1]]
  xa@xcmsSet <- fix[[2]]
  xset <- NULL
}





if(is.null(opt$grp_peaklist)){
  grp_peaklist = NA
}else{
  grp_peaklist = opt$grp_peaklist
}




db_pth <- msPurity::create_database(pa, xset=xset, xsa=xa, out_dir=opt$out_dir,
                          grp_peaklist=grp_peaklist, db_name=opt$db_name)


if (!is.null(opt$eic)){
  if (is.null(opt$raw_rt_columns)){
    rtrawColumns <- FALSE
  }else{
    rtrawColumns <- TRUE
  }

  # Saves the EICS into the previously created database
  px <- msPurity::purityX(pa@fileList, saveEIC = TRUE,
                           cores=opt$cores, sqlitePth=sqlitePth,
                           rtrawColumns = rtrawColumns)
}
