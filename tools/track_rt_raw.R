library(optparse)
library(xcms)
print(sessionInfo())

option_list <- list(
  make_option(c("--xset_path"), type="character"),
  make_option(c("-o", "--out_dir"), type="character")
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
