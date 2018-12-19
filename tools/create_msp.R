library(optparse)
library(msPurity)
print(sessionInfo())

# Get the parameter
option_list <- list(
  make_option(c("-i","--rdata_input"),type="character"),
  make_option(c("-m","--method"),type="character"),
  make_option(c("-meta","--metadata"),type="character"),
  make_option(c("-metac","--metadata_cols"),type="character"),
  make_option(c("-a","--adduct_split"),type="character"),
  make_option(c("-x","--xcms_groupids"),type="character"),
  make_option(c("-o","--out_dir"),type="character", default=".")
)
opt <- parse_args(OptionParser(option_list=option_list))

print(opt)

load(opt$rdata_input)

if (is.null(opt$metadata)){
  metadata <- NULL
}else{
  metadata <- read.table(opt$metadata,  header = TRUE, sep='\t', stringsAsFactors = FALSE, check.names = FALSE) 
  print(head(metadata))
}

if(is.null(opt$adduct_split)){
  adduct_split <- FALSE
}else{
  adduct_split <- TRUE
}

if (is.null(opt$xcms_groupids)){
  xcms_groupids <- NULL
}else{
  xcms_groupids <- trimws(strsplit(opt$xcms_groupids, ',')[[1]])  
}


msPurity::createMSP(pa, 
                    msp_file_pth = file.path(opt$out_dir, 'lcmsms_spectra.msp'),
                    metadata = metadata,
                    metadata_cols = opt$metadata_cols,
                    method = opt$method, 
                    adduct_split = adduct_split,
                    xcms_groupids = xcms_groupids)

print('msp created')
