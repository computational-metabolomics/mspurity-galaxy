library(optparse)
library(msPurity)
library(xcms)
print(sessionInfo())


option_list <- list(
  make_option("--out_rdata", type = "character"),
  make_option("--out_peaklist_prec", type = "character"),
  make_option("--out_peaklist_frag", type = "character"),
  make_option("--pa", type = "character"),
  make_option("--ilim", default = 0.0),
  make_option("--plim", default = 0.0),
  make_option("--ra", default = 0.0),
  make_option("--snr", default = 0.0),
  make_option("--rmp", action = "store_true"),
  make_option("--snmeth", default = "median", type = "character"),
  make_option("--allfrag", action = "store_true")
)

opt <- parse_args(OptionParser(option_list = option_list))
print(opt)


loadRData <- function(rdata_path, name) {
  # loads an RData file, and returns the named xset object if it is there
  load(rdata_path)
  return(get(ls()[ls() %in% name]))
}

# Requires
pa <- loadRData(opt$pa, "pa")

if (is.null(opt$rmp)) {
  opt$rmp <- FALSE
} else {
  opt$rmp <- TRUE
}

if (is.null(opt$allfrag)) {
  opt$allfrag <- FALSE
} else {
  opt$allfrag <- TRUE
}

pa <- filterFragSpectra(pa,
  ilim = opt$ilim,
  plim = opt$plim,
  ra = opt$ra,
  snr = opt$snr,
  rmp = opt$rmp,
  allfrag = opt$allfrag,
  snmeth = opt$snmeth
)

print(pa)
save(pa, file = opt$out_rdata)

# get the msms data for grpid from the purityA object
msmsgrp <- function(grpid, pa) {
  msms <- pa@grped_ms2[grpid]

  grpinfo <- pa@grped_df[pa@grped_df$grpid == grpid, ]

  grpinfo$subsetid <- seq_len(nrow(grpinfo))
  result <- plyr::ddply(grpinfo, ~subsetid, setid, msms = msms)
  return(result)
}

# Set the relevant details
setid <- function(grpinfo_i, msms) {
  msms_i <- msms[[1]][[grpinfo_i$subsetid]]
  n <- nrow(msms_i)
  msms_i <- data.frame(msms_i)
  colnames(msms_i)[1:2] <- c("mz", "i")
  m <- cbind("grpid" = rep(grpinfo_i$grpid, n), "pid" = rep(grpinfo_i$pid, n), "fileid" = rep(grpinfo_i$fileid, n), msms_i)
  return(m)
}



if (length(pa) > 0) {
  if (length(pa@grped_ms2) == 0) {
    message("No spectra available")
  } else {
    # get group ids
    grpids <- unique(as.character(pa@grped_df$grpid))

    # loop through all the group ids
    df_fragments <- plyr::adply(grpids, 1, msmsgrp, pa = pa)
    df_fragments <- merge(df_fragments, pa@puritydf[, c("pid", "acquisitionNum", "precursorScanNum")], by = "pid")
    df_fragments <- df_fragments[order(df_fragments$grpid, df_fragments$pid, df_fragments$mz), ]
    # select and reorder columns
    df_fragments <- df_fragments[, c("grpid", "pid", "precursorScanNum", "acquisitionNum", "fileid", "mz", "i", "snr", "ra", "purity_pass_flag", "intensity_pass_flag", "ra_pass_flag", "snr_pass_flag", "pass_flag")]

    pa@grped_df$filename <- sapply(as.character(pa@grped_df$fileid), function(x) names(pa@fileList)[as.integer(x)])

    print(head(pa@grped_df))
    write.table(pa@grped_df, opt$out_peaklist_prec, row.names = FALSE, sep = "\t")
    print(head(df_fragments))
    write.table(df_fragments, opt$out_peaklist_frag, row.names = FALSE, sep = "\t")
  }
}
