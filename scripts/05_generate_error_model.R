# load file of functions and check installed packages
source("scripts/functions.R")

# parse command line options
option_list = list(
  make_option(c("-E", "--email"), type="character", default=FALSE,
              help="Provide an email address to receive an email notification when the job has finished.", metavar="character"),
  make_option(c("-C", "--marker"), type="character", default=NULL,
              help="Optionally provide the marker name and the plot will be given a more informative name", metavar="character")

)

## Parse arguments
opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

# get path
path<-getwd()

## read in the lists of filtered reads
filtFs <- readRDS(file = paste(path, "/R_objects/04_fnFs.filtN.rds" ,sep=""))
filtRs <- readRDS(file = paste(path, "/R_objects/04_fnRs.filtN.rds" ,sep=""))
out <- readRDS(file = paste(path, "/R_objects/04_out.rds", sep=""))

## learn the error rates
errF <- learnErrors(filtFs, multithread = TRUE)
errR <- learnErrors(filtRs, multithread = TRUE)

## write out error rates for use later
saveRDS(errF, file = paste(path,"/R_objects/05_errF.rds",sep=""))
saveRDS(errR, file = paste(path,"/R_objects/05_errR.rds",sep=""))

## write plot to file for inspection
if (!is.null(opt$marker)){
        pdf(file = paste(path,"/working_data/05_", opt$marker, "error_rate_plots.pdf", sep=""),   # The directory you want to save the file into
    width = 10, # The width of the plot in inches
    height = 10)
}

if (is.null(opt$marker)){
        pdf(file = paste(path,"/working_data/05_error_rate_plots.pdf", sep=""),   # The directory you want to save the file into
    width = 10, # The width of the plot in inches
    height = 10)
}

## generate the plots in the file above
plotErrors(errF, nominalQ = TRUE)
plotErrors(errR, nominalQ = TRUE)
dev.off()

if (!is.null(opt$marker)){
        email_plot_command <- paste("echo \"", opt$marker, "Error_rate_plots\" | mail -s \"", opt$marker, "Error_rate_plots\" -a ", paste("working_data/05_", opt$marker, "error_rate_plots.pdf", sep=""), opt$email, sep=" ")
}

if (is.null(opt$marker)){
        email_plot_command <- paste("echo \"Error_rate_plots\" | mail -s \"Error_rate_plots\" -a working_data/05_error_rate_plots.pdf", opt$email, sep=" ")
}
system(email_plot_command)
