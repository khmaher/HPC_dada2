# load file of functions and check installed packages
source("scripts/functions.R")

# parse command line options
option_list = list(
  make_option(c("-E", "--email"), type="character", default=NULL,
              help="Provide an email address to receive an email notification when the job has finished.", metavar="character"),
  make_option(c("-T", "--trimlength1"), type="integer", default=NULL,
              help="truncLen value for read1", metavar="character"),
  make_option(c("-S", "--trimlength2"), type="integer", default=NULL,
              help="truncLen value for read2", metavar="character"),
  make_option(c("-G", "--maxEE_read1"), type="integer", default=NULL,
              help="maxEE value for read2", metavar="character"),
  make_option(c("-H", "--maxEE_read2"), type="integer", default=NULL,
              help="maxEE value for read2", metavar="character"),
  make_option(c("-Q", "--truncQ"), type="integer", default=NULL,
              help="truncQ value", metavar="character"),
  make_option(c("-L", "--minlength"), type="integer", default=NULL,
              help="Impose a minimum length cutoff", metavar="character"),
  make_option(c("-U", "--subset"), type="logical", default=FALSE,
              help="If TRUE, run filterAndTrim on the first two sample files and email plots", metavar="character"),
  make_option(c("-C", "--marker"), type="character", default=NULL,
              help="If specified will include marker name in output emails making it easier to see which plots apply to which markers", metavar="character")
)

## Parse arguments
opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

# get the directory containing the raw files from the -d argument
path<-getwd()

## read in the lists of cutadapt files for trimming
fnFs.cut <- readRDS(file = paste(path,"/R_objects/02_fnFs.cut.rds",sep=""))
fnRs.cut <- readRDS(file = paste(path,"/R_objects/02_fnRs.cut.rds",sep=""))

## set up filepaths for output files
fnFs.filtN <- file.path(path, "working_data/filterAndTrim", basename(fnFs.cut))
fnRs.filtN <- file.path(path, "working_data/filterAndTrim", basename(fnRs.cut))

## decode filterAndTrim options
all_args <- ""
if ((!is.null(opt$trimlength1)) & (!is.null(opt$trimlength2))){
	trimlength_args <- paste("truncLen=c(",opt$trimlength1,",",opt$trimlength2,")", sep="")
	all_args <- paste(all_args, trimlength_args, sep=",")
}	

if ((!is.null(opt$maxEE_read1)) & (!is.null(opt$maxEE_read2))){
        maxEE_args <- paste("maxEE=c(",opt$maxEE_read1,",",opt$maxEE_read2,")", sep="")
	all_args <- paste(all_args, maxEE_args, sep=",")
}

if ((!is.null(opt$truncQ))){
        truncQ_args <- paste("truncQ=",opt$truncQ, sep="")
        all_args <- paste(all_args, truncQ_args, sep=",")
}
if ((!is.null(opt$minlength))){
        minlength_args <- paste("minLen=",opt$minlength, sep="")
        all_args <- paste(all_args, minlength_args, sep=",")
}

# run filterAndTrim
if (opt$subset == "TRUE"){
	out <- eval(parse(text = paste("filterAndTrim(fnFs.cut[1:2], fnFs.filtN[1:2], fnRs.cut[1:2], fnRs.filtN[1:2], maxN = 0, ", all_args, ")")))
}
if (opt$subset == "FALSE"){
        out <- eval(parse(text = paste("filterAndTrim(fnFs.cut, fnFs.filtN, fnRs.cut, fnRs.filtN, maxN = 0, ", all_args, ")")))
}

## write objects to pass to next script
saveRDS(fnFs.filtN, file = paste(path, "/R_objects/04_fnFs.filtN.rds" ,sep=""))
saveRDS(fnRs.filtN, file = paste(path, "/R_objects/04_fnRs.filtN.rds" ,sep=""))
saveRDS(out, file = paste(path, "/R_objects/04_out.rds", sep=""))

## generate quality plots on the quality-trimmed data
# write plots for inspection
if (!is.null(opt$marker)){
        pdf(file = paste(path,"/working_data/04_", opt$marker, "post_trim_quality_plots.pdf", sep=""),   # The directory you want to save the file into
        width = 10, # The width of the plot in inches
        height = 10)
}

if (is.null(opt$marker)){
        pdf(file = paste(path,"/working_data/04_post_trim_quality_plots.pdf", sep=""),   # The directory you want to save the file into
        width = 10, # The width of the plot in inches
        height = 10)
}

## inspect read quality plots
plotQualityProfile(fnFs.filtN[1:2])
plotQualityProfile(fnRs.filtN[1:2])
dev.off()

if (!is.null(opt$marker)){
        email_plot_command <- paste("echo \"filterAndTrim is complete.\" | mail -s \"", opt$marker, "Post_QC_quality_plots\" -a ", paste("working_data/04_", opt$marker, "post_trim_quality_plots.pdf", sep=""), opt$email, sep=" ")
}

if (is.null(opt$marker)){
        email_plot_command <- paste("echo \"filterAndTrim is complete.\" | mail -s \"Post_QC_quality_plots\" -a working_data/04_post_trim_quality_plots.pdf", opt$email, sep=" ")
}

system(email_plot_command)
