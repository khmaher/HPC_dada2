#!/bin/bash

#SBATCH --job-name=01_remove_Ns
#SBATCH --output=01_remove_Ns.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
##SBATCH -A molecolb
##SBATCH -p molecolb
#SBATCH --mem-per-cpu=8GB
#SBATCH --time=24:00:00

usage="$(basename "$0") [-D raw data directory] [-W R1 file extension] [-P R2 file extension] [-E email address] \n
Wrapper for the remove Ns section of the dada2 workflow.\n The user MUST supply the directory of raw data files and
can optionally supply the R1 and R2 specific file extensions (these are generally automatically detected by the script)
 and an email address to receive notiications, and the marker name to be used in notification emails and the like.
Where:
    -D directory containing the raw data files
    -W The R1 specific file extension
    -P The R2 specific file extnesion
    -E email address
    -C marker\n\n\n"

## parse arguments
while getopts D:R:P:E:C: flag
do
	case "${flag}" in
		D) directory=${OPTARG};;
		W) R1_extension=${OPTARG};;
		P) R2_extension=${OPTARG};;
		E) email=${OPTARG};;
		C) marker=${OPTARG};;
	esac
done

## check mandatory arguments
if [ ! "$directory" ] ; then
        printf "\n\nERROR: Argument -D (directory of raw data files) must be provided"
        printf "\n\n$usage" >&2; exit 1
fi

## build up arg string to pass to R script
ARGS=""
if [ "$directory" ]; then ARGS="$ARGS -D $directory"; fi
if [ "$R1_extension" ]; then ARGS="$ARGS -W $R1_extension"; fi
if [ "$R2_extension" ]; then ARGS="$ARGS -P $R2_extension"; fi
if [ "$email" ]; then ARGS="$ARGS -E $email"; fi
if [ "$marker" ]; then ARGS="$ARGS -C $marker"; fi

## load R and call Rscript
source ~/.bash_profile
conda activate metabarcoding
echo $ARGS
Rscript $PWD/scripts/01_remove_Ns.R $ARGS 
