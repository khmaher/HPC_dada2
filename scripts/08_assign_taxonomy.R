# load file of functions and check installed packages
source("scripts/functions.R")

# parse command line options
option_list = list(
  make_option(c("-E", "--email"), type="character", default=FALSE,
              help="Provide an email address to receive an email notification when the job has finished.", metavar="character"),
  make_option(c("-B", "--database"), type="character", default=FALSE,
              help="Reference database in appropriate format for dada2. See https://benjjneb.github.io/dada2/training.html for more details.", metavar="character"),
  make_option(c("-C", "--marker"), type="character", default=NULL,
              help="OPTIONAL - give the marker name adn the plot will include this info. Useful if processing multiple markers", metavar="character")

)

## Parse arguments
opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

# get path
path<-getwd()

## read in the R objects
seqtab.nochim <- readRDS(file = paste(path, "/R_objects/06_seqtab.nochim.rds", sep=""))

## assign taxonomy
taxa <- assignTaxonomy(seqtab.nochim, opt$database, multithread=TRUE, verbose=T)

## get db_name to add onto output
db_name <- basename(opt$database)

## write out
if (!is.null(opt$marker)){
        write.table(taxa, file = paste(path, "/working_data/08_", opt$marker, "_assigned_taxonomy_", db_name, ".csv", sep=""))
	email_plot_command <- paste("echo \"", opt$marker, "Taxonomy assignment\" | mail -s \"", opt$marker, "taxonomy assignment complete\" -a working_data/08_", opt$marker, "_assigned_taxonomy_", db_name, ".csv ", opt$email, sep="")
}

if (is.null(opt$marker)){
	write.table(taxa, file = paste(path, "/working_data/08_assigned_taxonomy_", db_name, ".csv", sep=""))
	email_plot_command <- paste("echo \"Taxonomy assignment\" | mail -s \"taxonomy assignment complete\" -a working_data/08_assigned_taxonomy_", db_name, ".csv ", opt$email, sep="")
}

system(email_plot_command)
