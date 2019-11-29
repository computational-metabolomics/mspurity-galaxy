library(msPurity)
library(optparse)
print(sessionInfo())
option_list <- list(
  make_option(c("-o", "--out_dir"), type="character", default=getwd(),
              help="Output folder for resulting files [default = %default]"
  ),
  make_option(c("-x", "--xset_path"), type="character", default=file.path(getwd(),"xset.rds"),
              help="The path to the xcmsSet object [default = %default]"
  ),
  make_option("--polarity", default=NA,
              help="polarity (just used for naming purpose for files being saved) [positive, negative, NA] [default %default]"
  ),
  make_option("--rsd_i_blank", default=100,
              help="RSD threshold for the blank [default = %default]"
  ),
  make_option("--minfrac_blank", default=0.5,
              help="minimum fraction of files for features needed for the blank [default = %default]"
  ),
  make_option("--rsd_rt_blank", default=100,
              help="RSD threshold for the RT of the blank [default = %default]"
  ),

  make_option("--ithres_blank", default=0,
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
  make_option("--rsd_i_sample", default=100,
              help="RSD threshold for the samples [default = %default]"
  ),
  make_option("--minfrac_sample", default=0.8,
              help="minimum fraction of files for features needed for the samples [default = %default]"
  ),
  make_option("--rsd_rt_sample", default=100,
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

  make_option("--samplelist",  type="character", help="Sample list to determine the blank class")





)

  #make_option("--multilist", action="store_true"
  #            help="NOT CURRENTLY IMPLEMENTED: If paired blank removal is to be performed a - multilist -  sample list file has to be provided"
  #),

# store options
opt<- parse_args(OptionParser(option_list=option_list))

opt <- replace(opt, opt == "NA", NA)




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


print(opt)

getxcmsSetObject <- function(xobject) {
    # XCMS 1.x
    if (class(xobject) == "xcmsSet")
        return (xobject)
    # XCMS 3.x
    if (class(xobject) == "XCMSnExp") {
        # Get the legacy xcmsSet object
        suppressWarnings(xset <- as(xobject, 'xcmsSet'))
        sampclass(xset) <- xset@phenoData$sample_group
        return (xset)
    }
}


loadRData <- function(rdata_path, name){
#loads an RData file, and returns the named xset object if it is there
    load(rdata_path)
    return(get(ls()[ls() %in% name]))
}

xset <- getxcmsSetObject(loadRData(opt$xset_path, c('xset','xdata')))

print(xset)
if (is.null(opt$samplelist)){
    blank_class <- opt$blank_class
}else{
    samplelist <- read.table(opt$samplelist, sep='\t', header=TRUE)
    samplelist_blank <- unique(samplelist$sample_class[samplelist$blank=='yes'])

    chosen_blank <- samplelist_blank[samplelist_blank %in% xset@phenoData$class]
    if (length(chosen_blank)>1){
        print('ERROR: only 1 blank is currently allowed to be used with this tool')
        quit()
    }
    blank_class <- as.character(chosen_blank)
    print(blank_class)
}


if (is.null(opt$multilist)){
    ffrm_out <- flag_remove(xset,
                        pol=opt$polarity,
                        rsd_i_blank=opt$rsd_i_blank,
                        minfrac_blank=opt$minfrac_blank,
                        rsd_rt_blank=opt$rsd_rt_blank,
                        ithres_blank=opt$ithres_blank,
                        s2b=opt$s2b,
                        ref.class=blank_class,
                        egauss_thr=opt$egauss_thr,
                        rsd_i_sample=opt$rsd_i_sample,
                        minfrac_sample=opt$minfrac_sample,
                        rsd_rt_sample=opt$rsd_rt_sample,
                        ithres_sample=opt$ithres_sample,
                        minfrac_xcms=opt$minfrac_xcms,
                        mzwid=opt$mzwid,
                        bw=opt$bw,
                        out_dir=opt$out_dir,
                        temp_save=temp_save,
                        remove_spectra=remove_spectra,
                        grp_rm_ids=unlist(strsplit(as.character(opt$grp_rm_ids), split=", "))[[1]])
    print('flag remove finished')
    xset <- ffrm_out[[1]]
    grp_peaklist <- ffrm_out[[2]]
    removed_peaks <- ffrm_out[[3]]

    save.image(file=file.path(opt$out_dir, 'xset_filtered.RData'), version=2)

    # grpid needed for mspurity ID needed for deconrank... (will clean up at some up)
    peak_pth <- file.path(opt$out_dir, 'peaklist_filtered.tsv')
    print(peak_pth)
    write.table(data.frame('grpid'=rownames(grp_peaklist), 'ID'=rownames(grp_peaklist), grp_peaklist),
                peak_pth, row.names=FALSE, sep='\t')

    removed_peaks <- data.frame(removed_peaks)
    write.table(data.frame('ID'=rownames(removed_peaks),removed_peaks),
        file.path(opt$out_dir, 'removed_peaks.tsv'), row.names=FALSE, sep='\t')

}else{

   
   # TODO
   #xsets <- split(xset, multilist_df$multlist)
   #
   #mult_grps <- unique(multilist_df$multlist)
   #
   #for (mgrp in mult_grps){
   #   xset_i <- xsets[mgrp]
   #   xcms::group(xset_i, 
   #
   # }



}


