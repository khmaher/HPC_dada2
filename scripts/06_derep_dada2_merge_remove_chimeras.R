# load file of functions and check installed packages
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

# get path
path<-getwd()

## read in the filt files
filtFs <- readRDS(file = paste(path, "/R_objects/04_fnFs.filtN.rds", sep=""))
filtRs <- readRDS(file = paste(path, "/R_objects/04_fnRs.filtN.rds", sep=""))

## read in the error models
errF <- readRDS(file = paste(path, "/R_objects/05_errF.rds", sep=""))
errR <- readRDS(file = paste(path, "/R_objects/05_errR.rds", sep=""))

## check files exist
exists <- file.exists(filtFs)

## dereplicate the reads
derepFs <- derepFastq(filtFs[exists])
derepRs <- derepFastq(filtRs[exists])

# get sample names
sample.names <- readRDS(file = paste(path, "/R_objects/03_sample_names.rds", sep=""))

## name the derep class objects
names(derepFs) <- sample.names[exists]
names(derepRs) <- sample.names[exists]

## perform dada2 sample inference
dadaFs <- dada(derepFs, err = errF, multithread=TRUE)
dadaRs <- dada(derepRs, err = errR, multithread=TRUE)

## merge paired reads
mergers <- mergePairs(dadaFs, derepFs, dadaRs, derepRs, verbose=TRUE)

## make ASV table
seqtab <- makeSequenceTable(mergers)

## remove chimeras
seqtab.nochim <- removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE, verbose=TRUE)

## write out ASV sequences
sequences <- colnames(seqtab.nochim)
headers <- vector(dim(seqtab.nochim)[2], mode="character")

for (i in 1:dim(seqtab.nochim)[2]) {
  headers[i] <- paste(">ASV", i, sep="_")
}

output_fasta <- c(rbind(headers, sequences))

if (!is.null(opt$marker)){
	write(output_fasta, paste(path, "/working_data/06_", opt$marker, "ASV_seqs.fasta", sep=""))
}
if (is.null(opt$marker)){
	write(output_fasta, paste(path, "/working_data/06_ASV_seqs.fasta", sep=""))
}

# write out ASV counts
tab <- t(seqtab.nochim)

if (!is.null(opt$marker)){
        write.table(tab, file = paste(path, "/working_data/06_", opt$marker, "ASV_counts.tsv", sep=""), sep="\t", quote=F, col.names=NA)
}

if (is.null(opt$marker)){
	write.table(tab, file = paste(path, "/working_data/06_ASV_counts.tsv", sep=""), sep="\t", quote=F, col.names=NA)
}

## write out R objects for use later
saveRDS(dadaFs, file = paste(path, "/R_objects/06_dadaFs.rds", sep=""))
saveRDS(dadaRs, file = paste(path, "/R_objects/06_dadaRs.rds", sep=""))
saveRDS(mergers, file = paste(path, "/R_objects/06_mergers.rds", sep=""))
saveRDS(seqtab.nochim, file = paste(path, "/R_objects/06_seqtab.nochim.rds", sep=""))

if (!is.null(opt$marker)){
        email_plot_command <- paste("echo \"", opt$marker, "Dereplication_and_sample_inference_complete\" | mail -s \"", opt$marker, "Dereplication_and_sample_inference_complete\"", opt$email, sep=" ")
}

if (is.null(opt$marker)){
	email_plot_command <- paste("echo \"Dereplication_and_sample_inference_complete\" | mail -s \"Dereplication_and_sample_inference_complete\"", opt$email, sep=" ")
}
system(email_plot_command)
