#!/bin/bash

#SBATCH --job-name=03_raw_quality_plots
#SBATCH --output=03_raw_quality_plots.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH -A molecolb
#SBATCH -p molecolb
#SBATCH --mem-per-cpu=8GB
#SBATCH --time=24:00:00

usage="$basename "$0") [-E email address to send the plot pdf to] [-C marker name] 
Where:
    -E  an email address to send the quality plots to
    -C  the name of the marker being analysed (optional)\n\n\n"

## parse arguments
while getopts E:C: flag
do
	case "${flag}" in
		E) email=${OPTARG};;
		C) marker=${OPTARG};;
	esac
done

## check mandatory arguments
if [ ! "$email" ] ; then
        printf "\n\nERROR: Argument -E (an email address must be provided (to send the quality plots to)"
	printf "\n\n$usage" >&2; exit 1
fi

## build up arg string to pass to R script
ARGS=""
if [ "$email" ]; then ARGS="$ARGS -E $email"; fi
if [ "$marker" ]; then ARGS="$ARGS -C $marker"; fi

## load R and call Rscript
conda activate /usr/local/extras/Genomics/apps/mambaforge/envs/metabarcoding
Rscript $PWD/scripts/03_raw_quality_plots.R $ARGS
