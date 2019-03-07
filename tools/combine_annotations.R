library(optparse)
library(msPurity)
print(sessionInfo())

# Get the parameter
option_list <- list(
  make_option(c("-s","--sm_resultPth"),type="character"),
  make_option(c("-m","--metfrag_resultPth"),type="character"),
  make_option(c("-c","--sirius_csi_resultPth"),type="character"),
  make_option(c("-p","--probmetab_resultPth"),type="character"),
  make_option(c("-sw","--sm_weight"),type="numeric"),
  make_option(c("-mw","--metfrag_weight"),type="numeric"),
  make_option(c("-cw","--sirius_csi_weight"),type="numeric"),
  make_option(c("-pw","--probmetab_weight"),type="numeric"),
  make_option("--create_new_database", action="store_true"),
  make_option(c("-o","--outdir"),type="character", default=".")
)
opt <- parse_args(OptionParser(option_list=option_list))

print(opt)

if (!is.null(opt$create_new_database)){
  sm_resultPth <-  file.path(opt$outdir, 'combined_annotations.sqlite')
  file.copy(opt$sm_resultPth, sm_resultPth)
}else{
  sm_resultPth <- opt$sm_resultPth
}


weights <-list('sm'=opt$sm_weight,
               'metfrag'=opt$metfrag_weight,
               'sirius_csifingerid'= opt$sirius_csi_weight,
               'probmetab'=opt$probmetab_weight
               )

if (round(!sum(unlist(weights),0)==1)){

  stop(paste0('The weights should sum to 1 not ', sum(unlist(weights))))
}

summary_output <- msPurity::combineAnnotations(sm_resultPth,
                             opt$metfrag_resultPth,
                             opt$sirius_csi_resultPth,
                             opt$probmetab_resultPth,
                             weights = weights)

write.table(summary_output, file.path(opt$outdir, 'combined_annotations.tsv'), sep = '\t', row.names = FALSE)
