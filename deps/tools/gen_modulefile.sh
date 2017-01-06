#!/bin/bash

infile=$1
outfile=$2
modinit=$3

rm -f "${outfile}"

while IFS='' read -r line || [[ -n "${line}" ]]; do
    if [[ "${line}" =~ @modload@ ]]; then
        cat "${modinit}" >> "${outfile}"
    else
        echo "${line}" >> "${outfile}"
    fi
done < "${infile}"


