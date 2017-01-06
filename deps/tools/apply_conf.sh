#!/bin/bash

conffile=$1
infile=$2
outfile=$3

confsub="-e 's#@CONFFILE@#${conffile}#g'"

while IFS='' read -r line || [[ -n "${line}" ]]; do
    check=$(echo ${line} | sed -e "s#.*=.*#=#")
    
    if [ "x${check}" = "x=" ]; then
        # get the variable and its value
        var=$(echo ${line} | sed -e "s#\([^=]*\)=.*#\1#" | awk '{print $1}')
        val=$(echo ${line} | sed -e "s#[^=]*= *\(.*\)#\1#")
        
        # add to list of substitutions
        confsub="${confsub} -e 's#@${var}@#${val}#g'"
    fi

done < "${conffile}"

rm -f "${outfile}"

while IFS='' read -r line || [[ -n "${line}" ]]; do
    echo "${line}" | eval sed ${confsub} >> "${outfile}"
done < "${infile}"



