library(optparse)
library(msPurity)
print(sessionInfo())

# Get the parameter
option_list <- list(
  make_option(c("-s","--sm_resultPth"),type="character"),
  make_option(c("-m","--metfrag_resultPth"),type="character"),
  make_option(c("-c","--sirius_csi_resultPth"),type="character"),
  make_option(c("-p","--probmetab_resultPth"),type="character"),
  make_option(c("-l","--ms1_lookup_resultPth"),type="character"),

  make_option("--ms1_lookup_checkAdducts", action="store_true"),
  make_option("--ms1_lookup_keepAdducts", type="character", default=NA),
  make_option("--ms1_lookup_dbSource", type="character", default="hmdb"),

  make_option("--sm_weight", type="numeric"),
  make_option("--metfrag_weight", type="numeric"),
  make_option("--sirius_csi_weight", type="numeric"),
  make_option("--probmetab_weight", type="numeric"),
  make_option("--ms1_lookup_weight", type="numeric"),
  make_option("--biosim_weight", type="numeric"),
  
  make_option("--summaryOutput", action="store_true"),
  
  make_option("--create_new_database", action="store_true"),
  make_option("--outdir", type="character", default="."),

  make_option("--compoundDbType", type="character", default="sqlite"),
  make_option("--compoundDbPth", type="character", default=NA),
  make_option("--compoundDbHost", type="character", default=NA)
)
opt <- parse_args(OptionParser(option_list=option_list))

print(opt)

if (!is.null(opt$create_new_database)){
  sm_resultPth <-  file.path(opt$outdir, 'combined_annotations.sqlite')
  file.copy(opt$sm_resultPth, sm_resultPth)
}else{
  sm_resultPth <- opt$sm_resultPth
}

if (is.null(opt$ms1_lookup_checkAdducts)){
  opt$ms1_lookup_checkAdducts <- FALSE
}
if (!is.null(opt$ms1_lookup_keepAdducts)){
    opt$ms1_lookup_keepAdducts <- gsub("__ob__", "[", opt$ms1_lookup_keepAdducts)
    opt$ms1_lookup_keepAdducts <- gsub("__cb__", "]", opt$ms1_lookup_keepAdducts)
    ms1_lookup_keepAdducts <- strsplit(opt$ms1_lookup_keepAdducts, ",")[[1]]
}

weights <-list('sm'=opt$sm_weight,
               'metfrag'=opt$metfrag_weight,
               'sirius_csifingerid'= opt$sirius_csi_weight,
               'probmetab'=opt$probmetab_weight,
               'ms1_lookup'=opt$ms1_lookup_weight,
               'biosim'=opt$biosim_weight
               )
print(weights)

if (is.null(opt$probmetab_resultPth)){
  opt$probmetab_resultPth = NA
}

if (round(!sum(unlist(weights),0)==1)){
  stop(paste0('The weights should sum to 1 not ', sum(unlist(weights))))
}

if (is.null(opt$summaryOutput)){
  summaryOutput = FALSE
}else{
 summaryOutput = TRUE
}

if (opt$compoundDbType=='local_config'){
  # load in compound config
  # Soure local function taken from workflow4metabolomics
  source_local <- function(fname){ argv <- commandArgs(trailingOnly=FALSE); base_dir <- dirname(substring(argv[grep("--file=", argv)], 8)); source(paste(base_dir, fname, sep="/")) }
  source_local("dbconfig.R")
}else{
  compoundDbPth = opt$compoundDbPth
  compoundDbType = opt$compoundDbType
  compoundDbName = NA
  compoundDbHost = NA
  compoundDbPort = NA
  compoundDbUser = NA
  compoundDbPass = NA
}

summary_output <- msPurity::combineAnnotations(
                            sm_resultPth = sm_resultPth,
                            compoundDbPth = compoundDbPth,
                            metfrag_resultPth = opt$metfrag_resultPth,
                            sirius_csi_resultPth = opt$sirius_csi_resultPth,
                            probmetab_resultPth = opt$probmetab_resultPth,
                            ms1_lookup_resultPth = opt$ms1_lookup_resultPth,
                            ms1_lookup_keepAdducts = ms1_lookup_keepAdducts,
                            ms1_lookup_checkAdducts = opt$ms1_lookup_checkAdducts,

                            compoundDbType = compoundDbType,
                            compoundDbName = compoundDbName,
                            compoundDbHost = compoundDbHost,
                            compoundDbPort = compoundDbPort,
                            compoundDbUser = compoundDbUser,
                            compoundDbPass = compoundDbPass,
                            weights = weights,
                            summaryOutput = summaryOutput)
if (summaryOutput){
  write.table(summary_output, file.path(opt$outdir, 'combined_annotations.tsv'), sep = '\t', row.names = FALSE)
}


write.table(summary_output, file.path(opt$outdir, 'combined_annotations.tsv'), sep = '\t', row.names = FALSE)


closeAllConnections()

