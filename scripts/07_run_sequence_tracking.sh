#!/bin/bash

#SBATCH --job-name=07_track_reads
#SBATCH --output=07_track_reads.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=8GB
#SBATCH --time=24:00:00

usage="$(basename "$0") [-E email] [-C marker name] You may supply an email for the table to be sent to.
\n\nYou also may optionally supply the name of the marker which helps clarity when analysing multiple markers.
\n\n\n"


## parse arguments
while getopts E: flag
do
	case "${flag}" in
		E) email=${OPTARG};;
	esac
done

## build up arg string to pass to R script
ARGS=""
if [ "$email" ]; then ARGS="$ARGS -E $email"; fi
if [ "$marker" ]; then ARGS="$ARGS -C $marker"; fi


## load R and call Rscript
module load R/4.0.0-foss-2020a
Rscript $PWD/scripts/07_sequence_tracking.R $ARGS
