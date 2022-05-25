#!/bin/bash

#SBATCH --job-name=03_raw_quality_plots
#SBATCH --output=03_raw_quality_plots.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=8GB
#SBATCH --time=24:00:00


## parse arguments
while getopts E: flag
do
	case "${flag}" in
		E) email=${OPTARG};;
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

## load R and call Rscript
module load R/4.0.0-foss-2020a
Rscript $PWD/scripts/03_raw_quality_plots.R $ARGS

 
