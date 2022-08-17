
## load functions and check packages installed
source("scripts/functions.R")

# parse command line options
option_list = list(
  make_option(c("-E", "--email"), type="character", default=FALSE,
              help="Provide an email address to receive an email notification when the job has finished.", metavar="character"),
  make_option(c("-C", "--marker"), type="character", default=NULL,
              help="OPTIONAL - give the marker name adn the plot will include this info. Useful if processing multiple markers", metavar="character")
)

## Parse arguments
opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

## get cwd
path<-getwd()

## read in the lists of cutadapt files
fnFs.cut <- readRDS(file = paste(path,"/R_objects/02_fnFs.cut.rds",sep=""))
fnRs.cut <- readRDS(file = paste(path,"/R_objects/02_fnRs.cut.rds",sep=""))

# extract sample names and write to R object
sample.names <- unname(sapply(fnFs.cut, get.sample.name))
saveRDS(sample.names, file=paste(path, "/R_objects/03_sample_names.rds", sep=""))


## write plot to file for inspection
pdf(file = paste(path,"/working_data/03_pre_trim_quality_plots.pdf", sep=""),   # The directory you want to save the file into
    width = 10, # The width of the plot in inches
    height = 10)

## inspect read quality plots
plotQualityProfile(fnFs.cut[1:2])
plotQualityProfile(fnRs.cut[1:2])
dev.off()

if (!is.null(opt$marker)){
        email_plot_command <- paste("echo \"Pre_QC_quality_plots\" | mail -s \"", opt$marker, "Pre_QC_quality_plots\" -a working_data/03_pre_trim_quality_plots.pdf", opt$email, sep=" ")
}

if (is.null(opt$marker)){
        email_plot_command <- paste("echo \"Pre_QC_quality_plots\" | mail -s \"Pre_QC_quality_plots\" -a working_data/03_pre_trim_quality_plots.pdf", opt$email, sep=" ")
}

system(email_plot_command)
