#!/bin/bash

# This script takes a text file as input.  It assumes that the text
# file is already tokenized by separating each token using whitespace.
# The script then puts each word on a separate line and converts it to
# lowercase.  It also removes empty lines.  It also only takes lines
# with letters.  Note that it is currently unclear whether it also
# keeps words that only consist of letters with diacritics.

cat $1 \
    | sed "s///g" \
    | tr " " "\n" \
    | tr '[:upper:]' '[:lower:]' \
    | sed '/^\s*$/d' \
    | grep "[a-z]" \
    > $2

