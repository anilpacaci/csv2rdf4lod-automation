#!/bin/bash

CSV2RDF4LOD_HOME=${CSV2RDF4LOD_HOME:?"not set; source csv2rdf4lod/source-me.sh or see https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD-not-set"}

# cr:data-root cr:source cr:directory-of-datasets cr:dataset cr:directory-of-versions cr:conversion-cockpit
ACCEPTABLE_PWDs="cr:directory-of-versions cr:conversion-cockpit"
if [ `${CSV2RDF4LOD_HOME}/bin/util/is-pwd-a.sh $ACCEPTABLE_PWDs` != "yes" ]; then
   ${CSV2RDF4LOD_HOME}/bin/util/pwd-not-a.sh $ACCEPTABLE_PWDs
   exit 1
fi

if [ `$CSV2RDF4LOD_HOME/bin/util/is-pwd-a.sh cr:conversion-cockpit` == "yes" ]; then
   echo TODO
elif [ `$CSV2RDF4LOD_HOME/bin/util/is-pwd-a.sh cr:directory-of-versions` == "yes" ]; then
   for version in `find . -depth 1 -type d | grep -v "...svn"`; do
      let count=0
      for csv in $version/source/*.csv; do
         let count=count+1
         if [ $count -eq 1 ]; then
            header_filename="$version/manual/headers.txt"
         else
            header_filename="$version/manual/headers.$count.txt"
         fi
         echo "$csv -> $header_filename"
         if [ "$1" == "-w" ]; then
            java edu.rpi.tw.data.csv.impl.CSVHeaders $csv --number | grep "^[^\s]" > $header_filename
         fi
      done
   done
else
   echo "huh"
fi

