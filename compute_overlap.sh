#!/bin/bash

# This script requires a corpus file as input. The corpus file should
# be tokenized and cleaned up (if required) with one token per line.

corpus=$1
base_corpus=`basename ${corpus}`
corpus_len=`wc -l < ${corpus}`
output_dir=$2

# Create the output directory if it does not exist.
mkdir -p ${output_dir}

echo "Generate top N words for percentages of entire corpus"
# Generate top N words for the percentages of the entire corpus
# top N words go from 10 to 1000 in steps of 10

# Create a temporary directory and remove it when the script is done.
TMPDIR=$(mktemp -d "${TMPDIR:-/tmp/}$(basename "$0").XXXXXXXXXXXX")
trap 'rm -fr "${TMPDIR}"' EXIT

# Compute this for parts of the full corpus (from 10$ to 100% in steps
# of 10%).
for perc in `seq 10 10 100`; do
    # Randomly order the tokens in the corpus.
    cat ${corpus} \
        | shuf - \
        > ${TMPDIR}/${base_corpus}_shuf
    # Grab the correct percentage of tokens in the shuffled corpus,
    # sort, count token frequency and order based on token frequency.
    cat ${TMPDIR}/${base_corpus}_shuf \
        | head -n $((corpus_len*perc/100)) \
        | sort \
        | uniq -c \
        | sort -n -r \
        > ${TMPDIR}/${base_corpus}_shuf_${perc}

    # Compute this for the top N words where N goes from 10 to 1000 in
    # steps of 10.
    for top_n in `seq 10 10 1000`; do
    # Extract the top top_n words and remove frequency information.
    cat ${TMPDIR}/${base_corpus}_shuf_${perc} \
        | head -n ${top_n} \
        | sed "s/^ *[0-9]* //" \
        > ${output_dir}/${base_corpus}_${top_n}n_${perc}p.txt
    done
done

echo "top_n,percentage,jaccard" > ${output_dir}/${base_corpus}_output.csv
echo "Compute overlap for all top N words"
# Compute overlap
# Do this for all top N words
for top_n in `seq 10 10 1000`; do
    # Do this for all percentages
    for perc in `seq 10 10 90`; do
        s1=${output_dir}/${base_corpus}_${top_n}n_${perc}p.txt
        s2=${output_dir}/${base_corpus}_${top_n}n_100p.txt
        echo "COMPARE ${base_corpus}_${top_n}n_${perc}p.txt with ${base_corpus}_${top_n}n_100p.txt"
        # Store sizes
        INTERSECTION=$(comm -12 <(sort ${s1}) <(sort ${s2}) | wc -l)
        UNION=$(cat ${s1} ${s2} | sort -u | wc -l)

        # Calculate using bc (basic calculator) for float precision
        echo -n "${top_n},${perc}," >> ${output_dir}/${base_corpus}_output.csv
        echo "$INTERSECTION / $UNION" | bc -l >> ${output_dir}/${base_corpus}_output.csv
    done
done
