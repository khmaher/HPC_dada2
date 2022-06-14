# load file of functions and check installed packages
source("scripts/functions.R")

# parse command line options
option_list = list(
  make_option(c("-D", "--dir"), type="character", default=NULL,
              help="Directory containing the R1 and R2 (forward and reverse) paired sequence files in fastq.gz format", metavar="character"),
  make_option(c("-W", "--R1_ext"), type="character", default=NULL,
              help="Specify the R1 extension if the script couldn't automatically detect it", metavar="character"),
  make_option(c("-P", "--R2_ext"), type="character", default=NULL,
              help="Specify the	R2 extension if	the script couldn't automatically detect it", metavar="character"),
  make_option(c("-E", "--email"), type="character", default=FALSE,
              help="Provide an email address to receive an email notification when the job has finished.", metavar="character")
)

## Parse arguments
opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

# get the directory containing the raw files from the -d argument
path<-getwd()
input_files <- paste(path,"/", opt$dir, sep="")

## figure out the universal section of the file names (I.e. something like 001_R1.fastq.gz)
file_exts <- guess_file_extension(input_files)
print(paste("Automatically detected R1 and R2 file extensions are ", file_exts$R1, " and ", file_exts$R2, sep=""))

## group raw files into "forward" reads and "reverse" reads
fnFs <- sort(list.files(input_files, pattern = file_exts$R1, full.names = TRUE))
fnRs <- sort(list.files(input_files, pattern = file_exts$R2, full.names = TRUE))

## set up filepaths for output files
fnFs.filtN <- file.path(path, "working_data/filtN", basename(fnFs)) # Put N-filterd files in filtN/ subdirectory
fnRs.filtN <- file.path(path, "working_data/filtN", basename(fnRs))

# run filterAndTrim
eval(parse(text = paste("filterAndTrim(fnFs, fnFs.filtN, fnRs, fnRs.filtN, maxN = 0, ", ")")))

## write objects to pass to next script
saveRDS(fnFs.filtN, file = paste(path,"/R_objects/01_fnFs.filtN.rds",sep=""))
saveRDS(fnRs.filtN, file = paste(path,"/R_objects/01_fnRs.filtN.rds",sep=""))

email_command <- paste("echo \"remove Ns is complete.\" | mail -s \"remove Ns is complete.\"", opt$email, sep=" ")
system(email_command)
