###### FUNCTIONS #####

guess_file_extension<-function(input_directory){
  extensions <- list()
  n=1
  kill="0"
  while(kill=="0"){
    curr_char=NULL
    for (input_file in basename(list.files(input_directory))){
      if (is.null(curr_char)){
        curr_char=substr(input_file,(nchar(input_file)+1)-n,nchar(input_file))
      }
      else{
	result = substr(input_file,(nchar(input_file)+1)-n,nchar(input_file))
        if (result!=curr_char){
          kill="1"
        }else{previous=substr(input_file,(nchar(input_file)+1)-n,nchar(input_file))}
      }
    }
    n=n+1
  }
  extensions$R1<-previous
  extensions$R2<-substr(input_file,(nchar(input_file)+2)-n,nchar(input_file))
  return(extensions)
}

# Extract sample names
get.sample.name <- function(fname) strsplit(basename(fname), "_")[[1]][2]

## calc reads for tracking table
getN <- function(x) sum(getUniques(x))

### check all packages are installed (run in every script)
### archived as now installed using mamba

#requiredpackages <- c("ShortRead",
#                      "Biostrings",
#                      #"devtools",
#                      "ggplot2",
#                      "optparse")

#if ("Biostrings" %in% rownames(installed.packages()) == FALSE){
# if (!requireNamespace("BiocManager", quietly = TRUE))
#    install.packages("BiocManager", repos="https://www.stats.bris.ac.uk/R/")
# BiocManager::install("Biostrings")
#}
#if ("ShortRead" %in% rownames(installed.packages()) == FALSE){
# if (!requireNamespace("BiocManager", quietly = TRUE))
#    install.packages("BiocManager", repos="https://www.stats.bris.ac.uk/R/")
# BiocManager::install("ShortRead", force=TRUE)
#}

## install packages if required
#for (pkg in requiredpackages) {
#  if (pkg %in% rownames(installed.packages()) == FALSE)
#  {install.packages(pkg, dependencies=TRUE, repos="https://www.stats.bris.ac.uk/R/")}
#  if (pkg %in% rownames(.packages()) == FALSE)
#  {suppressPackageStartupMessages(library(pkg, character.only=T))}
#}
#if ("dada2" %in% rownames(installed.packages()) == FALSE)
# {devtools::install_github("benjjneb/dada2")} #install dada2 if required
#suppressPackageStartupMessages(library("dada2"))
#if ("dada2" %in% rownames(installed.packages()) == FALSE){
#  if (!requireNamespace("BiocManager", quietly = TRUE))
#    install.packages("BiocManager", repos="https://www.stats.bris.ac.uk/R/")
#  BiocManager::install("dada2", force=TRUE)
#}