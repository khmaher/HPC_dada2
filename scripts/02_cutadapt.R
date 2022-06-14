# load file of functions and check installed packages
source("scripts/functions.R")

## get command line arguments (primer sequences in this case, and cutadapt parameters in this case)
option_list = list(
  make_option(c("-D", "--dir"), type="character", default=NULL,
              help="Directory of raw data files.", metavar="character"),
  make_option(c("-F", "--Fprimer"), type="character", default=NULL, 
              help="Forward primer sequence", metavar="character"),
  make_option(c("-R", "--Rprimer"), type="character", default=NULL, 
              help="Reverse primer", metavar="character"),
  make_option(c("-E", "--email"), type="character", default=NULL,
              help="Email address to receive job notifications.", metavar="character"),
  make_option(c("-N", "--copies"), type="character", default=NULL,
              help="Number of copies of a primer to be removed as sometimes dulication can occur. Recommended minimum is 2", metavar="character"),
  make_option(c("-M", "--minimum"), type="character", default=NULL,
              help="Minimum read length cutoff. Recommend >0", metavar="character")
); 
 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

## get cwd and the directory of data from the -D flag.
path<-getwd()
input_files <- paste(path,"/", opt$dir, sep="")

## figure out the universal section of the file names (I.e. something like 001_R1.fastq.gz)
file_exts <- guess_file_extension(input_files)

FWD <- opt$Fprimer
REV <- opt$Rprimer

## primers might be in both reads, in different orientations
# opposite primer region, meaning a single read can have both primers on it.
# all this orientation stuff gives all the possible variants of primer and checks for them all


allOrients <- function(primer) {
  # Create all orientations of the input sequence
  require(Biostrings)
  dna <- DNAString(primer)  # The Biostrings works w/ DNAString objects rather than character vectors
  orients <- c(Forward = dna, Complement = complement(dna), Reverse = reverse(dna), 
               RevComp = reverseComplement(dna))
  return(sapply(orients, toString))  # Convert back to character vector
}

FWD.orients <- allOrients(FWD)
REV.orients <- allOrients(REV)

## count primer occurrences
primerHits <- function(primer, fn) {
  # Counts number of reads in which the primer is found
  nhits <- vcountPattern(primer, sread(readFastq(fn)), fixed = FALSE)
  return(sum(nhits > 0))
}

## redefine filtNs based on what is actually in the dirs (sometimes an input sample is completely removed by filterAndTrim previously)
fnFs.filtN <- sort(list.files(paste(path, "/working_data/filtN", sep=""), pattern = glob2rx(paste("*", file_exts$R1, sep="")), full.names = TRUE))
fnRs.filtN <- sort(list.files(paste(path, "/working_data/filtN", sep=""), pattern = glob2rx(paste("*", file_exts$R2, sep="")),  full.names = TRUE))

## write these out in case different from the filtN lists generated from the raw inputs
saveRDS(fnFs.filtN, file = paste(path, "/R_objects/02_fnFs.filtN.rds", sep=""))
saveRDS(fnRs.filtN, file = paste(path, "/R_objects/02_fnRs.filtN.rds", sep=""))

pre_trim_primer_counts <- rbind(FWD.ForwardReads = sapply(FWD.orients, primerHits, fn = fnFs.filtN[[1]]), 
      FWD.ReverseReads = sapply(FWD.orients, primerHits, fn = fnRs.filtN[[1]]), 
      REV.ForwardReads = sapply(REV.orients, primerHits, fn = fnFs.filtN[[1]]), 
      REV.ReverseReads = sapply(REV.orients, primerHits, fn = fnRs.filtN[[1]]))

write.table(pre_trim_primer_counts, paste(path, "/working_data/02_pre_trim_primer_counts.tsv", sep=""), col.names=NA, sep="\t")

# create directory for cutadapt
path.cut <- file.path(paste(path, "/working_data/cutadapt", sep=""))
if(!dir.exists(path.cut)) dir.create(path.cut)

FWD.RC <- dada2:::rc(FWD)
REV.RC <- dada2:::rc(REV)

# Trim FWD and the reverse-complement of REV off of R1 (forward reads)
R1.flags <- paste("-g", FWD, "-g", REV.RC, "-g", FWD.RC, "-g", REV)
# Trim REV and the reverse-complement of FWD off of R2 (reverse reads)
R2.flags <- paste("-G", FWD, "-G", REV.RC, "-G", FWD.RC, "-G", REV)

## redefine the cut dirs based on what is going in
fnFs.cut <- gsub("/filtN", "/cutadapt", fnFs.filtN)
fnRs.cut <- gsub("/filtN", "/cutadapt", fnRs.filtN)

## write the cut objects out
## write objects to pass to next script
saveRDS(fnFs.cut, file = paste(path, "/R_objects/02_fnFs.cut.rds", sep=""))
saveRDS(fnRs.cut, file = paste(path, "/R_objects/02_fnRs.cut.rds", sep=""))

## check the order of files going in/out
if (isFALSE(identical(sapply(strsplit(fnFs.cut,"cutadapt/"), `[`, 2), sapply(strsplit(fnFs.filtN,"filtN/"), `[`, 2)))){
print("List of input files to cutadapt does not match the proposed list of output files.")
print("Quitting.")
quit()
}

# decode arguments for cutadapt
all_args <- ""
if ((!is.null(opt$minimum))){
        minimum_args <- paste("\"-m ", opt$minimum, "\"", sep="")
        all_args <- paste(all_args, minimum_args, sep=",")
}

if ((!is.null(opt$copies))){
        copies_args <- paste("\"-n ", opt$copies, "\"", sep="")
        all_args <- paste(all_args, copies_args, sep=",")
}

# run cutadapt
for (i in seq_along(fnFs.filtN)) {
  print(fnFs.filtN[i])
  print(fnFs.cut[i])
  eval(parse(text = paste("system2(\"cutadapt\", args=c(R1.flags, R2.flags, \"-o\", fnFs.cut[i], \"-p\", fnRs.cut[i], fnFs.filtN[i], fnRs.filtN[i], \"-j 0\" ", as.character(all_args), "))", sep="")))}

post_trim_primer_counts <- rbind(FWD.ForwardReads = sapply(FWD.orients, primerHits, fn = fnFs.cut[[1]]), 
      FWD.ReverseReads = sapply(FWD.orients, primerHits, fn = fnRs.cut[[1]]), 
      REV.ForwardReads = sapply(REV.orients, primerHits, fn = fnFs.cut[[1]]), 
      REV.ReverseReads = sapply(REV.orients, primerHits, fn = fnRs.cut[[1]]))

write.table(post_trim_primer_counts, paste(path, "/working_data/02_post_trim_primer_counts.tsv", sep=""), col.names=NA)

email_command <- paste("echo \"Cutadapt is complete.\" | mail -s \"Cutadapt is complete.\"", opt$email, sep=" ")
system(email_command)

