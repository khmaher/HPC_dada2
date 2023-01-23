#!/bin/bash

#SBATCH --job-name=02_cutadapt
#SBATCH --output=02_cutadapt.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH -A molecolb
#SBATCH -p molecolb
#SBATCH --mem-per-cpu=16GB
#SBATCH --time=24:00:00

usage="$(basename "$0") [-D directory of raw data] [-F forward primer] [-R reverse primer] [-M minimum read size to be retained] [-N max number of copies of an adapter to be removed] [-E email] \n
Wrapper for the cutadapt section of the dada2 workflow.\n The user MUST supply the directory of raw data, and both the forward and reverse primer sequences to trimmed. Optionally, the user
can specify a minimum size threshold to retain reads, and the maximum number of copies of an adapter to be removed during the trim.
Where:
    -D  directory containing raw data files
    -F  forward primer sequence
    -R  reverse primer sequence
    -M  minimum size of read to be retained
    -N  maximum number of occurrences of an adapter to be trimmed
    -E  email address
    -C  marker name (to be used for Fluidigm type runs below)
    -A  File of marker details (used for Fluidigm type runs)\n\n\n"


## parse arguments
while getopts D:F:R:M:N:E:C:A: flag
do
  	case "${flag}" in
		D) directory=${OPTARG};;
                F) forward=${OPTARG};;
                R) reverse=${OPTARG};;
		M) minimum=${OPTARG};;
		N) copies=${OPTARG};;
		E) email=${OPTARG};;
		C) marker=${OPTARG};;
		A) marker_file=${OPTARG};;
        esac
done

## providing the DB of marker details can over-ride the need for some of these other required arguments

if [ ! "$directory" ] || [ ! "$marker" ] || [ ! "$marker_file" ]; then
	## check mandatory arguments
	if [ ! "$directory" ] || [ ! "$forward" ] || [ ! "$reverse" ]; then
	        printf "\n\nERROR: Argument -D (directory of raw data files) must be provided"
		printf "\n\nERROR: Argument -F (forward primer sequence) must be provided"
		printf "\n\nERROR: Argument -R (reverse primer sequence) must be provided"
		printf "\nOR, you may supply a file of parameters using marker name (-C) and path to parameter file (-A)"
	        printf "\n\n$usage" >&2; exit 1
	fi
fi
if [ "$marker" ] & [ "$marker_file" ] ; then
	forward=$(awk -v marker="$marker" -F, '$1 == marker {print $3}' $marker_file) ; echo $F_primer	
	reverse=$(awk -v marker="$marker" -F, '$1 == marker {print $4}' $marker_file) ; echo $R_primer
	minimum=$(awk -v marker="$marker" -F, '$1 == marker {print $5}' $marker_file) ; echo $cutadapt_min_size
	copies=$(awk -v marker="$marker" -F, '$1 == marker {print $6}' $marker_file) ; echo $cutadapt_no_adapters
fi

## build up arg string to pass to R script
ARGS=""
if [ "$directory" ]; then ARGS="$ARGS -D $directory"; fi
if [ "$forward" ]; then ARGS="$ARGS -F $forward"; fi
if [ "$reverse" ]; then ARGS="$ARGS -R $reverse"; fi
if [ "$minimum" ]; then ARGS="$ARGS -M $minimum"; fi
if [ "$copies" ]; then ARGS="$ARGS -N $copies"; fi
if [ "$email" ]; then ARGS="$ARGS -E $email"; fi	
if [ "$marker" ]; then ARGS="$ARGS -C $marker"; fi

## load R and call Rscript
source ~/.bash_profile
conda activate cutadapt
module load R/4.0.0-foss-2020a
Rscript $PWD/scripts/02_cutadapt.R $ARGS
