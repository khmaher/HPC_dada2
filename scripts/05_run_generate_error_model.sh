#!/bin/bash

#SBATCH --job-name=05_error_models
#SBATCH --output=05_error_models.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH -A molecolb
#SBATCH -p molecolb
#SBATCH --mem-per-cpu=8GB
#SBATCH --time=24:00:00

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
source ~/.bash_profile
conda activate /usr/local/extras/Genomics/apps/mambaforge/envs/metabarcoding
Rscript $PWD/scripts/05_generate_error_model.R $ARGS

 
