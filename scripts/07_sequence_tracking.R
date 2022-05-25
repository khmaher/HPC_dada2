# load file of functions and check installed packages
source("scripts/functions.R")

# parse command line options
option_list = list(
  make_option(c("-E", "--email"), type="character", default=FALSE,
              help="Provide an email address to receive an email notification when the job has finished.", metavar="character")
)

## Parse arguments
opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

# get path
path<-getwd()

## read in the R objects
out <- readRDS(file = paste(path, "/R_objects/04_out.rds", sep=""))
dadaFs <- readRDS(file = paste(path, "/R_objects/06_dadaFs.rds", sep=""))
dadaRs <- readRDS(file = paste(path, "/R_objects/06_dadaRs.rds", sep=""))
mergers	<- readRDS(file = paste(path, "/R_objects/06_mergers.rds", sep=""))
seqtab.nochim <- readRDS(file = paste(path, "/R_objects/06_seqtab.nochim.rds", sep=""))
filtFs <- readRDS(file = paste(path, "/R_objects/04_fnFs.filtN.rds", sep=""))

track <- cbind(
	out[,1],
	out[,2],
	sapply(dadaFs, getN),
	sapply(dadaRs, getN),
	sapply(mergers, getN),
	rowSums(seqtab.nochim))
colnames(track) <- c(
	"input", 
	"filtered",
	"denoisedF",
	"denoisedR",
	"merged",
	"nochim")

# get sample names
sample.names <- unname(sapply(filtFs, get.sample.name))
rownames(track) <- sample.names

write.table(track, file = paste(path, "/working_data/07_track_reads_table.csv", sep=""))

email_plot_command <- paste("echo \"Track reads table\" | mail -s \"Track reads table\" -a working_data/07_track_reads_table.csv", opt$email, sep=" ")
system(email_plot_command)
