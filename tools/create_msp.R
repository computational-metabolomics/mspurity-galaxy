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
  make_option(c("-x","--xcms_groupids"),type="character")
)
opt <- parse_args(OptionParser(option_list=option_list))

print(opt)

load(opt$purity_dataset)

metadata <- read.table(opt$metadata,  header = TRUE, sep='\t', stringsAsFactors = FALSE, check.names = FALSE)

msPurity::createMSP(pa, 
                    msp_file_pth = 'lcmsms.msp',
                    metadata = metadata,
                    metadata_cols = opt$metadata_cols,
                    method = opt$method, 
                    adduct_split = opt$adduct_split)
