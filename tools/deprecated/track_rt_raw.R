library(optparse)

print(sessionInfo())

option_list <- list(
  make_option(c("--xset_path"), type="character"),
  make_option(c("-o", "--out_dir"), type="character"),
  make_option(c("--extract_peaks"), action="store_true")
)

# store options
opt<- parse_args(OptionParser(option_list=option_list))

load(opt$xset_path)

print(xset)

rtraw <- xset@peaks[,c('rt', 'rtmin', 'rtmax')]
colnames(rtraw) <- c('rt_raw','rtmin_raw','rtmax_raw')
xset@peaks <- cbind(xset@peaks, rtraw)


print('saving RData')
save.image(file.path(opt$out_dir, 'xset_rt_raw_tracked.RData'))

if(!is.null(opt$extract_peaks)){
    write.table(xset@peaks, file.path(opt$out_dir, 'xset_peaks.tsv'), row.names=FALSE, sep='\t')
}
