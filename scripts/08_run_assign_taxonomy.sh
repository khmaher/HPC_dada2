#!/bin/bash

#SBATCH --job-name=08_assign_taxonomy
#SBATCH --output=08_assign_taxonomy.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
##SBATCH -A molecolb
##SBATCH -p molecolb
#SBATCH --mem-per-cpu=16GB
#SBATCH --time=24:00:00

usage="$(basename "$0") [-B database] [-E email] \n
Wrapper for the assignTaxonomy section of the dada2 workflow.\n The user MUST supply the formatted .fasta database and can OPTIONALLY supply an email address to receive job notifications.
Where:
    -B  Full path to database
    -E  email address\n\n\n"

## parse arguments
while getopts B:E:C:A: flag
do
	case "${flag}" in
		B) database=${OPTARG};;
		E) email=${OPTARG};;
		C) marker=${OPTARG};;
		A) marker_file=${OPTARG};;
	esac
done

if [ ! "$marker" ] || [ ! "$marker_file" ]; then
	## check mandatory arguments
	if [ ! "$database" ] ; then
		printf "\n\nERROR: Argument -B (database) must be provided"
		printf "\n\n$usage" >&2; exit 1
	fi
fi

if [ "$marker" ] || [ "$marker_file" ]; then
	database=$(awk -v marker="$marker" -F, '$1 == marker {print $13}' $marker_file) ; echo $reference_database
fi

## build up arg string to pass to R script
ARGS=""
if [ "$database" ]; then ARGS="$ARGS -B $database"; fi
if [ "$email" ]; then ARGS="$ARGS -E $email"; fi

## load R and call Rscript
source ~/.bash_profile
conda activate metabarcoding
Rscript $PWD/scripts/08_assign_taxonomy.R $ARGS

 
