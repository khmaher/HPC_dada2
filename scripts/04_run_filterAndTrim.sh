#!/bin/bash

#SBATCH --job-name=04_filterAndTrim
#SBATCH --output=04_filterAndTrim.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=8GB
#SBATCH --time=24:00:00

usage="$(basename "$0") [-E email] [-T read 1 truncation length] [-S read 2 truncation length] [-G read 1 maxEE] [-H read 2 maxEE] [-Q truncQ] [-L minlength] [-U subset] \n
Wrapper for the filterAndTrim section of the dada2 workflow.\n 
The user MUST supply an email address for quality plots to be sent to. \n
The user may OPTIONALLY supply the truncation lengths for both read 1 and read 2, the maxEE trimming value for both read 1 and read 2,
the truncQ value for quality based truncation, and also the minimum length of reads to be retained. For speed testing trimming parameters, you can choose to just trim the first 2 samples by specifying -U TRUE.
You may also specify a file of parameters as previously (-A and -C).

Where:
    -E  email address
    -T  read 1 (R1) truncation length
    -S  read 2 (R2) truncation length
    -G  read 1 (R1) maxEE
    -H  read 2 (R2) maxEE
    -Q  truncQ
    -L  minimum length
    -U  filter just a subset of samples
    -C  marker name (to be used for Fluidigm type runs below)
    -A  File of marker details (used for Fluidigm type runs)\n\n\n"

## parse arguments
while getopts E:T:S:G:H:Q:L:U:C:A: flag
do
	case "${flag}" in
		E) email=${OPTARG};;
		T) trunclen1=${OPTARG};;
		S) trunclen2=${OPTARG};;
		G) maxEE1=${OPTARG};;
		H) maxEE2=${OPTARG};;
		Q) truncQ=${OPTARG};;
		L) minlength=${OPTARG};;
		U) subset=${OPTARG};;
		C) marker=${OPTARG};;
		A) marker_file=${OPTARG};;
	esac
done

## check mandatory arguments
if [ ! "$email" ] ; then
        printf "\n\nERROR: Argument -E (an email address must be provided (to send the quality plots to)"
	printf "\n\n$usage" >&2; exit 1
fi

if [ "$marker" ] & [ "$marker_file" ] ; then
	trunclen1=$(awk -v marker="$marker" -F, '$1 == marker {print $7}' $marker_file) ; echo $FandT_R1_trunc
	trunclen2=$(awk -v marker="$marker" -F, '$1 == marker {print $8}' $marker_file) ; echo $FandT_R2_trunc
	maxEE1=$(awk -v marker="$marker" -F, '$1 == marker {print $9}' $marker_file) ; echo $FandT_R1_maxEE
	maxEE2=$(awk -v marker="$marker" -F, '$1 == marker {print $10}' $marker_file) ; echo $FandT_R2_maxEE
	truncQ=$(awk -v marker="$marker" -F, '$1 == marker {print $11}' $marker_file) ; echo $FandT_truncQ
	minlength=$(awk -v marker="$marker" -F, '$1 == marker {print $12}' $marker_file) ; echo $FandT_minlen
fi

## build up arg string to pass to R script
ARGS=""
if [ "$email" ]; then ARGS="$ARGS -E $email"; fi
if [ "$trunclen1" ]; then ARGS="$ARGS -T $trunclen1"; fi
if [ "$trunclen2" ]; then ARGS="$ARGS -S $trunclen2"; fi
if [ "$maxEE1" ]; then ARGS="$ARGS -G $maxEE1"; fi
if [ "$maxEE2" ]; then ARGS="$ARGS -H $maxEE2"; fi
if [ "$truncQ" ]; then ARGS="$ARGS -Q $truncQ"; fi
if [ "$minlength" ]; then ARGS="$ARGS -L $minlength"; fi
if [ "$subset" ]; then ARGS="$ARGS -U $subset"; fi
if [ "$marker" ]; then ARGS="$ARGS -C $marker"; fi

## load R and call Rscript
module load R/4.0.0-foss-2020a
Rscript $PWD/scripts/04_filterAndTrim.R $ARGS
