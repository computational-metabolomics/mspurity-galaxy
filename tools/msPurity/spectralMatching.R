library(msPurity)
library(msPurityData)
library(optparse)
print(sessionInfo())


option_list <- list(
  make_option(c("-o", "--outDir"), type="character"),
  make_option("--q_dbPth", type="character"),
  make_option("--l_dbPth", type="character"),
  
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
}else if (!is.null(opt$q_dbPth)){
  q_dbPth <- opt$q_dbPth
}else{
  message('No query database available')
  exit()
}

if(!is.null(opt$l_defaultDb)){
  l_dbPth <- system.file("extdata", "library_spectra", "library_spectra.db", package="msPurityData")
}else if (!is.null(opt$l_dbPth)){
  l_dbPth <- opt$l_dbPth
}else{
  message('No library database available')
  exit()
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



sm <- msPurity::spectralMatching(q_dbPth = q_dbPth,
                           l_dbPth = l_dbPth,
                           
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
                           outPth = "db_with_spectral_matching.sqlite"
                           )



write.table(sm$matchedResults, 'matched_results.tsv', sep = '\t', row.names = FALSE, col.names = TRUE)
write.table(sm$xcmsMatchedResults, 'xcms_matched_results.tsv', sep = '\t', row.names = FALSE, col.names = TRUE)
