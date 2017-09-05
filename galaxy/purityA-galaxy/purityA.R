library(msPurity)
library(optparse)

option_list <- list(
  make_option(c("-o", "--out_dir"), type="character", default=getwd(),
              help="Output folder for resulting files [default = %default]"
  ),
  make_option(c("-i", "--files"), type="character", default=file.path(getwd(),"xset.rds"),
              help="list of files (comma separated) [default = %default]"
  ),
  make_option("--polarity", default='NA',
              help="polarity (just used for naming purpose for files being saved) [positive, negative, NA] [default %default]"
  ),
  make_option("--rsd_i_blank", default=NA,
              help="RSD threshold for the blank [default = %default]"
  ),
  make_option("--minfrac_blank", default=0.5,
              help="minimum fraction of files for features needed for the blank [default = %default]"
  ),
  make_option("--rsd_rt_blank", default=NA,
              help="RSD threshold for the RT of the blank [default = %default]"
  ),

  make_option("--ithres_blank", default=NA,
              help="Intensity threshold for the blank [default = %default]"
  ),
  make_option("--s2b", default=10,
              help="fold change (sample/blank) needed for sample peak to be allowed. e.g.
                    if s2b set to 10 and the recorded sample 'intensity' value was 100 and blank was 10.
                    1000/10 = 100, so sample has fold change higher than the threshold and the peak
                    is not considered a blank [default = %default]"
  ),
  make_option("--blank_class", default='blank', type="character",
              help="A string representing the class that will be used for the blank.[default = %default]"
  ),
  make_option("--egauss_thr", default=NA,
              help="Threshold for filtering out non gaussian shaped peaks. Note this only works
                            if the 'verbose columns' and 'fit gauss' was used with xcms
                            [default = %default]"
  ),
  make_option("--rsd_i_sample", default=NA,
              help="RSD threshold for the samples [default = %default]"
  ),
  make_option("--minfrac_sample", default=0.8,
              help="minimum fraction of files for features needed for the samples [default = %default]"
  ),
  make_option("--rsd_rt_sample", default=NA,
              help="RSD threshold for the RT of the samples [default = %default]"
  ),
  make_option("--ithres_sample", default=5000,
              help="Intensity threshold for the sample [default = %default]"
  ),
  make_option("--grp_rm_ids", default=NA,
              help="vector of grouped_xcms peaks to remove (corresponds to the row from xcms::group output)
              [default = %default]"
  ),
  make_option("--remove_spectra",  action="store_true",
              help=" TRUE if flagged spectra is to be removed [default = %default]"
  ),
  make_option("--minfrac_xcms", default=0.5,
              help="minfrac for xcms  grouping [default = %default]"
  ),
  make_option("--mzwid", default=0.001,
              help="mzwid for xcms  grouping [default = %default]"
  ),
  make_option("--bw", default=5,
              help="bw for xcms  grouping [default = %default]"
  ),

  make_option("--temp_save",  action="store_true",
              help="Assign True if files for each step saved (for testing purposes) [default = %default]"
  ),

  make_option("--xset_name",  default="xset",
              help="Name of the xcmsSet object within the RData file [default = %default]"
  )


)

# store options
opt<- parse_args(OptionParser(option_list=option_list))

if (is.null(opt$temp_save)){
    temp_save<-FALSE
}else{
    temp_save<-TRUE
}

if (is.null(opt$remove_spectra)){
    remove_spectra<-FALSE
}else{
    remove_spectra<-TRUE
}


pa <- msPurity::purityA(fileList,
                        cores = 1,
                        mostIntense = FALSE,
                        nearest = TRUE,
                        offsets = NA,
                        plotP = FALSE,
                        plotdir = NULL,
                        interpol = "linear",
                        iwNorm = FALSE,
                        iwNormFun = NULL,
                        ilim = 0.05,
                        mzRback = "pwiz",
                        isotopes = TRUE,
                        im = NULL))

# xset <- ffrm_out[[1]]
# grp_peaklist <- ffrm_out[[2]]
# removed_peaks <- ffrm_out[[3]]
#
# save(xset, file=file.path(opt$out_dir, 'xset_filtered.RData'))
#
# write.table(data.frame('ID'=rownames(grp_peaklist),grp_peaklist),
#         file.path(opt$out_dir, 'peaklist_filtered.txt'), row.names=FALSE, sep='\t')
#
# removed_peaks <- data.frame(removed_peaks)
# write.table(data.frame('ID'=rownames(removed_peaks),removed_peaks),
#         file.path(opt$out_dir, 'removed_peaks.txt'), row.names=FALSE, sep='\t')
