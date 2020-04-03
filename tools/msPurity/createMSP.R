library(optparse)
library(msPurity)
print(sessionInfo())

# Get the parameter
option_list <- list(
  make_option("--rdata_input",type="character"),
  make_option("--method",type="character"),
  make_option("--metadata",type="character"),
  make_option("--metadata_cols",type="character"),
  make_option("--metadata_cols_filter",type="character"),
  make_option("--adduct_split", action="store_true"),
  make_option("--xcms_groupids",type="character"),
  make_option("--filter",action="store_true"),
  make_option("--intensity_ra",type="character"),
  make_option("--include_adducts",type="character"),
  make_option("--msp_schema",type="character"),
  make_option("--include_adducts_custom",type="character", default=""),
  make_option("--out_dir",type="character", default=".")
)
opt <- parse_args(OptionParser(option_list=option_list))

print(opt)

load(opt$rdata_input)

if (is.null(opt$metadata)){
  metadata <- NULL
}else{
  metadata <- read.table(opt$metadata,  header = TRUE, sep='\t', stringsAsFactors = FALSE, check.names = FALSE)

  if(!opt$metadata_cols_filter==''){
     metadata_cols_filter <- strsplit(opt$metadata_cols_filter, ',')[[1]]

     metadata <- metadata[,metadata_cols_filter, drop=FALSE]
     print(metadata)

     if (!"grpid" %in% colnames(metadata)){
       metadata$grpid <- 1:nrow(metadata)
     }

     print(metadata)

  }

}



if (is.null(opt$metadata_cols) || opt$metadata_cols==''){
    metadata_cols <- NULL
}else{
    metadata_cols <- opt$metadata_cols

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

if (opt$include_adducts=='None'){
  include_adducts <- ''
}else{
  include_adducts <- opt$include_adducts
}


include_adducts_all <- paste(include_adducts_custom, include_adducts, sep=",")

include_adducts_all <- gsub("__ob__", "[", include_adducts_all)
include_adducts_all <- gsub("__cb__", "]", include_adducts_all)
include_adducts_all <- trimws(include_adducts_all)
include_adducts_all <- gsub(",", " ", include_adducts_all






if(is.null(opt$filter)){
  filter <- FALSE
}else{
  filter <- TRUE
}



msPurity::createMSP(pa,
                    msp_file_pth = file.path(opt$out_dir, 'lcmsms_spectra.msp'),
                    metadata = metadata,
                    metadata_cols = metadata_cols,
                    method = opt$method,
                    adduct_split = adduct_split,
                    xcms_groupids = xcms_groupids,
                    filter = filter,
                    intensity_ra=opt$intensity_ra,
                    include_adducts=include_adducts_all,
                    msp_schema=opt$msp_schema)

print('msp created')
