library(msPurity)
library(msPurityData)
library(optparse)
print(sessionInfo())
# load in library spectra config
source_local <- function(fname){ argv <- commandArgs(trailingOnly=FALSE); base_dir <- dirname(substring(argv[grep("--file=", argv)], 8)); source(paste(base_dir, fname, sep="/")) }
source_local("dbconfig.R")

option_list <- list(
  make_option(c("-o", "--outDir"), type="character"),
  make_option("--q_dbPth", type="character"),
  make_option("--l_dbPth", type="character"),

  make_option("--q_dbType", type="character", default=NA),
  make_option("--l_dbType", type="character", default=NA),

  make_option("--q_msp", type="character", default=NA),
  make_option("--l_msp", type="character", default=NA),

  make_option("--q_defaultDb", action="store_true"),
  make_option("--l_defaultDb", action="store_true"),

  make_option("--q_ppmPrec", type="double"),
  make_option("--l_ppmPrec", type="double"),

  make_option("--q_ppmProd", type="double"),
  make_option("--l_ppmProd", type="double"),

  make_option("--q_raThres", type="double", default=NA),
  make_option("--l_raThres", type="double", default=NA),

  make_option("--q_polarity", type="character", default=NA),
  make_option("--l_polarity", type="character", default=NA),

  make_option("--q_purity", type="double", default=NA),
  make_option("--l_purity", type="double", default=NA),

  make_option("--q_xcmsGroups", type="character", default=NA),
  make_option("--l_xcmsGroups", type="character", default=NA),

  make_option("--q_pids", type="character", default=NA),
  make_option("--l_pids", type="character", default=NA),

  make_option("--q_rtrangeMin", type="double", default=NA),
  make_option("--l_rtrangeMin", type="double", default=NA),

  make_option("--q_rtrangeMax", type="double", default=NA),
  make_option("--l_rtrangeMax", type="double", default=NA),

  make_option("--q_accessions", type="character", default=NA),
  make_option("--l_accessions", type="character", default=NA),

  make_option("--q_sources", type="character", default=NA),
  make_option("--l_sources", type="character", default=NA),

  make_option("--q_sourcesUser", type="character", default=NA),
  make_option("--l_sourcesUser", type="character", default=NA),

  make_option("--q_instrumentTypes", type="character", default=NA),
  make_option("--l_instrumentTypes", type="character", default=NA),

  make_option("--q_instrumentTypesUser", type="character", default=NA),
  make_option("--l_instrumentTypesUser", type="character", default=NA),

  make_option("--q_instruments", type="character", default=NA),
  make_option("--l_instruments", type="character", default=NA),

  make_option("--q_spectraTypes", type="character", default=NA),
  make_option("--l_spectraTypes", type="character", default=NA),

  make_option("--q_spectraFilter", action="store_true"),
  make_option("--l_spectraFilter", action="store_true"),

  make_option("--usePrecursors", action="store_true"),

  make_option("--mzW", type="double"),
  make_option("--raW", type="double"),

  make_option("--rttol", type="double", default=NA),

  make_option("--updateDb", action="store_true"),
  make_option("--copyDb", action="store_true"),
  make_option("--cores", default=1)


)

# store options
opt<- parse_args(OptionParser(option_list=option_list))

print(opt)

# check if the sqlite databases have any spectra
checkSPeakMeta <- function(dbPth, nme){
    if(is.null(dbPth)){
        return(TRUE)
    }else if ((file.exists(dbPth)) & (file.info(dbPth)$size>0)){
        con <- DBI::dbConnect(RSQLite::SQLite(), dbPth)
        if (DBI::dbExistsTable(con, "s_peak_meta")){
            spm <- DBI::dbGetQuery(con, 'SELECT  * FROM s_peak_meta ORDER BY ROWID ASC LIMIT 1')
            return(TRUE)
        }else if(DBI::dbExistsTable(con, "library_spectra_meta")){
            spm <- DBI::dbGetQuery(con, 'SELECT  * FROM library_spectra_meta ORDER BY ROWID ASC LIMIT 1')
            return(TRUE)
        }else{
            print(paste("No spectra available for ",nme))
            return(FALSE)
        }
    }else{
        print(paste("file empty or does not exist for", nme))
        return(FALSE)
    }

        
}


addQueryNameColumn <- function(sm){
    if (is.null(sm$matchedResults) || length(sm$matchedResults)==1 || nrow(sm$matchedResults)==0){
        return(sm)
    }

    con <- DBI::dbConnect(RSQLite::SQLite(),sm$q_dbPth)
    if (DBI::dbExistsTable(con, "s_peak_meta")){
        spm <- DBI::dbGetQuery(con, 'SELECT  pid, name AS query_entry_name FROM s_peak_meta')
    }else if(DBI::dbExistsTable(con, "library_spectra_meta")){
        spm <- DBI::dbGetQuery(con, 'SELECT  id AS pid, name  AS query_entry_name FROM library_spectra_meta')
    }
    print(sm$matchedResults)
    if ('pid' %in% colnames(sm$matchedResults)){
        sm$matchedResults <- merge(sm$matchedResults, spm, by.x='pid', by.y='pid')    
    }else{
        sm$matchedResults <- merge(sm$matchedResults, spm, by.x='qpid', by.y='pid')
    }
    
    print(sm$xcmsMatchedResults)
    if (is.null(sm$xcmsMatchedResults) || length(sm$xcmsMatchedResults)==1 || nrow(sm$xcmsMatchedResults)==0){
        return(sm)
    }else{
        if ('pid' %in% colnames(sm$xcmsMatchedResults)){
            sm$xcmsMatchedResults<- merge(sm$xcmsMatchedResults, spm, by.x='pid', by.y='pid')    
        }else{
            sm$xcmsMatchedResults <- merge(sm$xcmsMatchedResults, spm, by.x='qpid', by.y='pid')
        }
    }
    
    return(sm)
    
}


updateDbF <- function(q_con, l_con){
    message('Adding extra details to database')
    q_con <- DBI::dbConnect(RSQLite::SQLite(),sm$q_dbPth)
    if (DBI::dbExistsTable(q_con, "l_s_peak_meta")){
        l_s_peak_meta <- DBI::dbGetQuery(q_con, 'SELECT  * FROM l_s_peak_meta')
        colnames(l_s_peak_meta)[1] <- 'pid'
    }
    
    l_con <- DBI::dbConnect(RSQLite::SQLite(),l_dbPth)
    if (DBI::dbExistsTable(l_con, "s_peaks")){
        l_s_peaks <- DBI::dbGetQuery(q_con, sprintf("SELECT  * FROM s_peaks WHERE pid in (%s)", paste(unique(l_s_peak_meta$pid), collapse=',')))
        
    }else if(DBI::dbExistsTable(l_con, "library_spectra")){
        l_s_peaks <- DBI::dbGetQuery(l_con, sprintf("SELECT  * FROM library_spectra
                                                WHERE library_spectra_meta_id in (%s)", paste(unique(l_s_peak_meta$pid), collapse=',')))
    }else{
        l_s_peaks = NULL
    }
    
    if (DBI::dbExistsTable(l_con, "source")){
        l_source <- DBI::dbGetQuery(l_con, 'SELECT  * FROM source')
    }else if (DBI::dbExistsTable(l_con, "library_spectra_source")) {
        l_source <- DBI::dbGetQuery(l_con, 'SELECT  * FROM library_spectra_source')
    }else{
        l_source = NULL
    }
    
    if (!is.null(l_s_peaks)){
        DBI::dbWriteTable(q_con, name='l_s_peaks', value=l_s_peaks, row.names=FALSE, append=TRUE)
    }
    
    if (!is.null(l_source)){
        DBI::dbWriteTable(q_con, name='l_source', value=l_source, row.names=FALSE, append=TRUE)
    }
    
    
}


extractMultiple <- function(optParam){
  if (!is.na(optParam)){
     param <- trimws(strsplit(optParam, ',')[[1]])
     param <- param[param != ""]
  }else{
     param <- NA
  }
  return(param)

}

if(!is.null(opt$q_defaultDb)){
  q_dbPth <- system.file("extdata", "library_spectra", "library_spectra.db", package="msPurityData")
  q_dbType <- 'sqlite'
}else if (!opt$q_dbType=='local_config'){
  q_dbType <- opt$q_dbType
  q_dbPth <- opt$q_dbPth
}

if(!is.null(opt$l_defaultDb)){
  l_dbPth <- system.file("extdata", "library_spectra", "library_spectra.db", package="msPurityData")
  l_dbType <- 'sqlite'
}else if (!opt$l_dbType=='local_config'){
  l_dbType <- opt$l_dbType
  l_dbPth <- opt$l_dbPth
}


q_polarity <- extractMultiple(opt$q_polarity)
l_polarity <- extractMultiple(opt$l_polarity)

q_xcmsGroups <- extractMultiple(opt$q_xcmsGroups)
l_xcmsGroups <- extractMultiple(opt$l_xcmsGroups)

q_pids <- extractMultiple(opt$q_pids)
l_pids <- extractMultiple(opt$l_pids)

q_sources <- extractMultiple(opt$q_sources)
l_sources <- extractMultiple(opt$l_sources)

q_sourcesUser <- extractMultiple(opt$q_sourcesUser)
l_sourcesUser <- extractMultiple(opt$l_sourcesUser)

q_sources <-c(q_sources, q_sourcesUser)
l_sources <-c(l_sources, l_sourcesUser)

q_instrumentTypes <- extractMultiple(opt$q_instrumentTypes)
l_instrumentTypes <- extractMultiple(opt$l_instrumentTypes)

q_instrumentTypes <-c(q_instrumentTypes, q_instrumentTypes)
l_instrumentTypes <-c(l_instrumentTypes, l_instrumentTypes)


if(!is.null(opt$l_spectraFilter)){
  l_spectraFilter <- TRUE
}else{
  l_spectraFilter <- FALSE
}

if(!is.null(opt$q_spectraFilter)){
  q_spectraFilter <- TRUE
}else{
  q_spectraFilter <- FALSE
}

if(!is.null(opt$updateDb)){
  updateDb <- TRUE
}else{
  updateDb <- FALSE
}

if(!is.null(opt$copyDb)){
  copyDb <- TRUE
}else{
  copyDb <- FALSE
}

if(!is.null(opt$l_rtrangeMax)){
  l_rtrangeMax <- opt$l_rtrangeMax
}else{
  l_rtrangeMax <- NA
}

if(!is.null(opt$q_rtrangeMax)){
  q_rtrangeMax <- opt$q_rtrangeMax
}else{
  q_rtrangeMax <- NA
}

if(!is.null(opt$l_rtrangeMin)){
  l_rtrangeMin <- opt$l_rtrangeMin
}else{
  l_rtrangeMin <- NA
}

if(!is.null(opt$q_rtrangeMin)){
  q_rtrangeMin <- opt$q_rtrangeMin
}else{
  q_rtrangeMin <- NA
}

q_check <- checkSPeakMeta(opt$q_dbPth, 'query')
l_check <- checkSPeakMeta(opt$l_dbPth, 'library')

if (q_check && l_check){
    sm <- msPurity::spectralMatching(
        q_purity =  opt$q_purity,
        l_purity =  opt$l_purity,
        
        q_ppmProd =  opt$q_ppmProd,
        l_ppmProd =  opt$l_ppmProd,
        
        q_ppmPrec =  opt$q_ppmPrec,
        l_ppmPrec =  opt$l_ppmPrec,
        
        q_raThres =  opt$q_raThres,
        l_raThres =  opt$l_raThres,
        
        q_pol =  q_polarity,
        l_pol =  l_polarity,
        
        q_xcmsGroups = q_xcmsGroups,
        l_xcmsGroups = l_xcmsGroups,
        
        q_pids = q_pids,
        l_pids = l_pids,
        
        q_sources = q_sources,
        l_sources = l_sources,
        
        q_instrumentTypes = q_instrumentTypes,
        l_instrumentTypes = l_instrumentTypes,
        
        q_spectraFilter= q_spectraFilter,
        l_spectraFilter= l_spectraFilter,
        
        l_rtrange=c(l_rtrangeMin, l_rtrangeMax),
        q_rtrange=c(q_rtrangeMin, q_rtrangeMax),
        
        q_accessions = opt$q_accessions,
        l_accessions= opt$l_accessions,
        
        raW = opt$raW,
        mzW = opt$mzW,
        rttol=opt$rttol,
        cores=opt$cores,
        
        copyDb=copyDb,
        updateDb=updateDb,
        outPth = "db_with_spectral_matching.sqlite",
        
        q_dbPth = q_dbPth,
        q_dbType = q_dbType,
        q_dbName = q_dbName,
        q_dbHost = q_dbHost,
        q_dbUser = q_dbUser,
        q_dbPass = q_dbPass,
        q_dbPort = q_dbPort,
        
        l_dbPth = l_dbPth,
        l_dbType = l_dbType,
        l_dbName = l_dbName,
        l_dbHost = l_dbHost,
        l_dbUser = l_dbUser,
        l_dbPass = l_dbPass,
        l_dbPort = l_dbPort
        
    )
    
    sm <- addQueryNameColumn(sm)
    # Get name of the query results (and merged with the data frames)
    write.table(sm$matchedResults, 'matched_results.tsv', sep = '\t', row.names = FALSE, col.names = TRUE)
    write.table(sm$xcmsMatchedResults, 'xcms_matched_results.tsv', sep = '\t', row.names = FALSE, col.names = TRUE)
    
    if(updateDb){
        updateDbF(q_con, l_con)
    }
}
