#!/bin/bash

# This script takes a list of files that are taken as corpora and for
# each of these, it cleans them up and then computes the overlap of
# these corpora by reducing the amount of data available.

# This takes all arguments and puts them in an array.
corpora=("$@")

# This is the default output directory. Perhaps this will need to be
# moved to a specific commandline argument.
output_dir="out"

# Create the output directory if it does not yet exist.
mkdir -p ${output_dir}

# For each corpus, do the cleanup and then compute the overlap.
for input in "${corpora[@]}"; do
    corpus_dir=`dirname ${input}`
    corpus_file=`basename ${input}`
    echo "Cleanup corpus"
    ./clean_up_corpus.sh ${corpus_dir}/${corpus_file} ${output_dir}/${corpus_file}

    echo "Compute overlap"
    ./compute_overlap.sh ${output_dir}/${corpus_file} ${output_dir}
done
