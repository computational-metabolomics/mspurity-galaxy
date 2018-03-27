library(msPurity)
library(optparse)
library(xcms)
library(CAMERA)
print('CREATING DATABASE')


xset_pa_filename_fix <- function(opt, pa, xset){


  if (!is.null(opt$mzML_files) && !is.null(opt$galaxy_names)){
    # NOTE: Relies on the pa@fileList having the names of files given as 'names' of the variables 
    # needs to be done due to Galaxy moving the files around and screwing up any links to files

    filepaths <- trimws(strsplit(opt$mzML_files, ',')[[1]])
    filepaths <- filepaths[filepaths != ""]
    new_names <- basename(filepaths)

    galaxy_names <- trimws(strsplit(opt$galaxy_names, ',')[[1]])
    galaxy_names <- galaxy_names[galaxy_names != ""]

    nsave <- names(pa@fileList)
    old_filenames  <- basename(pa@fileList)
    pa@fileList <- filepaths[match(names(pa@fileList), galaxy_names)]
    names(pa@fileList) <- nsave

    pa@puritydf$filename <- basename(pa@fileList[match(pa@puritydf$filename, old_filenames)])
    pa@grped_df$filename <- basename(pa@fileList[match(pa@grped_df$filename, old_filenames)])
  }


 if(!all(basename(pa@fileList)==basename(xset@filepaths))){
    if(!all(names(pa@fileList)==basename(xset@filepaths))){
       print('FILELISTS DO NOT MATCH')
       message('FILELISTS DO NOT MATCH')
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

print('TESTETSTESTETE')
print(pa@fileList)


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


print(pa@fileList)
print(xset@filepaths)


db_pth <- msPurity::create_database(pa, xset=xset, xsa=xa, out_dir=opt$out_dir,
                          grp_peaklist=grp_peaklist, db_name=opt$db_name)


if (!is.null(opt$eic)){
  if (is.null(opt$raw_rt_columns)){
    rtrawColumns <- FALSE
  }else{
    rtrawColumns <- TRUE
  }

  # Saves the EICS into the previously created database
  px <- msPurity::purityX(xset, saveEIC = TRUE,
                           cores=opt$cores, sqlitePth=db_pth,
                           rtrawColumns = rtrawColumns)
}



con <- DBI::dbConnect(RSQLite::SQLite(), db_pth)

cmd <- paste('SELECT cpg.grpid, cpg.mz, cpg.mzmin, cpg.mzmax, cpg.rt, cpg.rtmin, cpg.rtmax, c_peaks.cid, ',
             'c_peaks.mzmin AS c_peak_mzmin, c_peaks.mzmax AS c_peak_mzmax, ',
             'c_peaks.rtmin AS c_peak_rtmin, c_peaks.rtmax AS c_peak_rtmax, s_peak_meta.*, fileinfo.filename, fileinfo.nm_save ',
             'FROM c_peak_groups AS cpg ',
             'LEFT JOIN c_peak_X_c_peak_group AS cXg ON cXg.grpid=cpg.grpid ',
             'LEFT JOIN c_peaks on c_peaks.cid=cXg.cid ',
             'LEFT JOIN c_peak_X_s_peak_meta AS cXs ON cXs.cid=c_peaks.cid ',
             'LEFT JOIN s_peak_meta ON cXs.pid=s_peak_meta.pid ',
             'LEFT JOIN fileinfo ON s_peak_meta.fileid=fileinfo.fileid')

print(cmd)
cpeakgroup_msms <- DBI::dbGetQuery(con, cmd)

write.table(cpeakgroup_msms, file.path(opt$out_dir, 'cpeakgroup_msms.tsv'), row.names=FALSE, sep='\t')
