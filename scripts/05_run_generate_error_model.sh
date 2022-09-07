#!/bin/bash

#SBATCH --job-name=05_error_models
#SBATCH --output=05_error_models.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=8GB
#SBATCH --time=24:00:00

usage="$(basename "$0") [-E email] [-C marker name] You MUST supply an email to which the output plots will be sent. 
\n\nYou may optionally supply the name of the marker which helps clarity when analysing multiple markers. 
\n\n\n"

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
        printf "\n\nERROR: Argument -E (an email address must be provided (to send the error modelling plots to)"
        printf "\n\n$usage" >&2; exit 1
fi

## build up arg string to pass to R script
ARGS=""
if [ "$email" ]; then ARGS="$ARGS -E $email"; fi
if [ "$marker" ]; then ARGS="$ARGS -C $marker"; fi

## load R and call Rscript
module load R/4.0.0-foss-2020a
Rscript $PWD/scripts/05_generate_error_model.R $ARGS

 
