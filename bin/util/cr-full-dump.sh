#!/bin/bash
#
#3> <> prov:specializationOf <https://github.com/timrdf/csv2rdf4lod-automation/blob/master/bin/util/cr-full-dump.sh>;
#3>    prov:wasDerivedFrom   <cr-publish-droid-to-endpoint.sh>;
#3>    rdfs:seeAlso          <https://github.com/timrdf/csv2rdf4lod-automation/wiki/One-click-data-dump> .
#
# Gather all versioned dataset dump files into one enormous dump file.
# This is highly redundant, but can be helpful for those that "just want the data"
# and don't want to crawl the VoID dataDumps to get it.

#see="https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD-not-set"
#CSV2RDF4LOD_HOME=${CSV2RDF4LOD_HOME:?"not set; source csv2rdf4lod/source-me.sh or see $see"}
HOME=$(cd ${0%/*/*} && echo ${PWD%/*})
export CLASSPATH=$CLASSPATH`$HOME/bin/util/cr-situate-classpaths.sh`
CSV2RDF4LOD_HOME=${CSV2RDF4LOD_HOME:?$HOME}
export PATH=$PATH`$HOME/bin/util/cr-situate-paths.sh`

see="https://github.com/timrdf/csv2rdf4lod-automation/wiki/Aggregating-subsets-of-converted-datasets"
CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID=${CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID:?"not set; see $see"}

see="https://github.com/timrdf/csv2rdf4lod-automation/wiki/Aggregating-subsets-of-converted-datasets"
CSV2RDF4LOD_BASE_URI=${CSV2RDF4LOD_BASE_URI:?"not set; see $see"}

see="https://github.com/timrdf/csv2rdf4lod-automation/wiki/Aggregating-subsets-of-converted-datasets"
CSV2RDF4LOD_PUBLISH_VARWWW_ROOT=${CSV2RDF4LOD_PUBLISH_VARWWW_ROOT:?"not set; see $see"}

# cr:data-root cr:source cr:directory-of-datasets cr:dataset cr:directory-of-versions cr:conversion-cockpit
ACCEPTABLE_PWDs="cr:data-root"
if [ `${CSV2RDF4LOD_HOME}/bin/util/is-pwd-a.sh $ACCEPTABLE_PWDs` != "yes" ]; then
   ${CSV2RDF4LOD_HOME}/bin/util/pwd-not-a.sh $ACCEPTABLE_PWDs
   exit 1
fi

TEMP="_"`basename $0``date +%s`_$$.tmp

sourceID=$CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID
datasetID=`basename $0 | sed 's/.sh$//'`
versionID='latest' # Doing it every day is a waste of space for this use case. `date +%Y-%b-%d`

cockpit="$sourceID/$datasetID/version/$versionID"
base=`echo $CSV2RDF4LOD_BASE_URI | perl -pi -e 's|http://||;s/\./-/g;s|/|-|g'` # e.g. lofd-tw-rpi-edu
dumpFileLocal=$base.nt.gz

if [[ "$1" == "--help" ]]; then
   echo "usage: `basename $0` [--target] [-n]"
   echo ""
   echo "  Gather all versioned dataset dump files into one enormous dump file."
   echo "    archive them into a versioned dataset 'latest'"
   echo ""
   echo "         --target : return the dump file location, then quit."
   echo "               -n : perform dry run only; do not load named graph."
   echo
   exit 1
fi

if [ "$1" == "--target" ]; then
   # a conversion:VersionedDataset:
   # e.g. http://purl.org/twc/health/source/tw-rpi-edu/dataset/cr-publish-dcat-to-endpoint/version/2012-Sep-07
   echo $cockpit/publish/$dumpFileLocal
   exit 0
fi

dryrun="false"
if [ "$1" == "-n" ]; then
   dryrun="true"
   dryrun.sh $dryrun beginning
   shift
fi

#for panel in 'source' 'automatic' 'publish' 'doc/logs'; do
#   if [ ! -d $cockpit/$panel ]; then
#      mkdir -p $cockpit/$panel
#   fi
#   echo "rm -rf $cockpit/$panel/*"
#   if [ "$dryrun" != "true" ]; then
#      rm -rf $cockpit/$panel/*
#   fi
#done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Collect source files into source/
#if [ "$dryrun" != "true" ]; then
#   for datadump in `cr-list-versioned-dataset-dumps.sh --warn-if-missing`; do
#      echo ln $datadump $cockpit/source/
#      if [ "$dryrun" != "true" ]; then
#         ln $datadump $cockpit/source/
#      fi
#   done
#fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Build up full dump file into publish/
#echo "$cockpit/publish/$dumpFileLocal"
#if [[ -n "`getconf ARG_MAX`" && \
#     `find $cockpit/source -type f | wc -l` -lt `getconf ARG_MAX` ]]; then
#   # Saves disk space, but shell can't handle infinite arguments.
#   echo "(as batch)"
#   if [ "$dryrun" != "true" ]; then
#      rdf2nt.sh --verbose `find $cockpit/source -type f` 2> $cockpit/doc/logs/rdf2nt-errors.log | gzip > $cockpit/publish/$dumpFileLocal 2> $cockpit/doc/logs/gzip-errors.log
#   fi
#else
#   echo "(incrementally)"
#   # Handles infinite source/* files, but uses disk space.
#   for datadump in `find $cockpit/source -type f`; do
#      if [ "$dryrun" != "true" ]; then
#         rdf2nt.sh $datadump >> $cockpit/publish/$dumpFileLocal.tmp
#      fi
#   done
#   if [ "$dryrun" != "true" ]; then
#      cat $cockpit/publish/$dumpFileLocal.tmp | gzip > $cockpit/publish/$dumpFileLocal
#      rm $cockpit/publish/$dumpFileLocal.tmp
#   fi
#fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## Pull out the RDF URI nodes from the full dump.
##echo $cockpit/automatic/$base-uri-node-occurrences.txt
##if [ "$dryrun" != "true" ]; then
##   uri-nodes.sh $cockpit/publish/$dumpFileLocal                                       > $cockpit/automatic/$base-uri-node-occurrences.txt
##fi

## no space left on device...
## echo $cockpit/automatic/$base-uri-node-occurrences-sorted.txt
## cat          $cockpit/automatic/$base-uri-node-occurrences.txt | sort    > $cockpit/automatic/$base-uri-node-occurrences-sorted.txt

for datadump in `find $cockpit/source -type f`; do
   if [ "$dryrun" != "true" ]; then
      # Do it piecemeal to avoid strain on sort's memory.
      echo "$cockpit/automatic/$base-uri-nodes.txt <-- $datadump"
      small=`find \`dirname $datadump\` -name \`basename $datadump\` -size -20M`
      echo $small
      if [[ -n "$small" ]]; then
         echo "(sort -u)"
         uri-nodes.sh $datadump | sort -u                                                                                            >> $cockpit/automatic/$base-uri-nodes.txt
      else
         echo "(avoiding sort -u)"
         uri-nodes.sh $datadump                                                                                                      >> $cockpit/automatic/$base-uri-nodes.txt
      fi
   fi
done
##Too big:
##if [ "$dryrun" != "true" ]; then
##   cat $TEMP | sort -u                                                                                                             > $cockpit/automatic/$base-uri-nodes.txt
##   rm -f $TEMP
##fi

pushd $cockpit &> /dev/null
   versionedDataset=`cr-dataset-uri.sh --uri`
   sourceID=`cr-source-id.sh`   # Saved for later
   datasetID=`cr-dataset-id.sh` # Saved for later
   versionID=`cr-version-id.sh` # Saved for later
   sdv=`cr-sdv.sh`
popd &> /dev/null
baseURI="${CSV2RDF4LOD_BASE_URI_OVERRIDE:-$CSV2RDF4LOD_BASE_URI}"
topVoID="${CSV2RDF4LOD_BASE_URI_OVERRIDE:-$CSV2RDF4LOD_BASE_URI}/void"

echo $cockpit/automatic/$base-uri-nodes.ttl
if [ "$dryrun" != "true" ]; then
   echo "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> ."                                                                  > $cockpit/automatic/$base-uri-nodes.ttl
   echo "@prefix foaf: <http://xmlns.com/foaf/0.1/> ."                                                                            >> $cockpit/automatic/$base-uri-nodes.ttl
   echo "@prefix void: <http://rdfs.org/ns/void#> ."                                                                              >> $cockpit/automatic/$base-uri-nodes.ttl
   echo "@prefix prov: <http://www.w3.org/ns/prov#> ."                                                                            >> $cockpit/automatic/$base-uri-nodes.ttl
   echo "#3> <> prov:wasAttributedTo [ foaf:name \"`basename $0`\" ]; ."                                                          >> $cockpit/automatic/$base-uri-nodes.ttl
   echo                                                                                                                           >> $cockpit/automatic/$base-uri-nodes.ttl
   cat $cockpit/automatic/$base-uri-nodes.txt | awk -v dataset=$versionedDataset '{print "<"$1"> void:inDataset <"dataset"> ."}'  >> $cockpit/automatic/$base-uri-nodes.ttl
   echo "<$topVoID> void:rootResource <$topVoID> ."                                                                               >> $cockpit/automatic/$base-uri-nodes.ttl
   echo "<$topVoID> void:dataDump     <$baseURI/source/$sourceID/file/$datasetID/version/$versionID/conversion/$dumpFileLocal> ." >> $cockpit/automatic/$base-uri-nodes.ttl
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ "$dryrun" != "true" ]; then

   pushd $cockpit &> /dev/null
      cr-pwd.sh
      aggregate-source-rdf.sh automatic/$base-uri-nodes.ttl
   popd &> /dev/null

   # Sneak the top-level VoID into the void file.
   # This will not be published by aggregate-source-rdf.sh, but 
   # will get picked up by cr-publish-void-to-endpoint.sh during cron.
   #
   #echo "$cockpit/publish/$base.void.ttl"
   echo "$cockpit/publish/$sdv.void.ttl +"
   #                                                                                                                              >> $cockpit/publish/$base.void.ttl
   mappings="$baseURI/source/$sourceID/file/cr-aggregated-params/version/latest/conversion/$sourceID-cr-aggregated-params-latest.ttl.gz"
   echo "#3> <> prov:wasAttributedTo [ foaf:name \"`basename $0`\" ]; ."                                                          >> $cockpit/publish/$sdv.void.ttl
   echo "@prefix foaf:       <http://xmlns.com/foaf/0.1/> ."                                                                      >> $cockpit/publish/$sdv.void.ttl
   echo "@prefix owl:        <http://www.w3.org/2002/07/owl#> ."                                                                  >> $cockpit/publish/$sdv.void.ttl
   echo "@prefix dcterms:    <http://purl.org/dc/terms/> ."                                                                       >> $cockpit/publish/$sdv.void.ttl
   echo "@prefix tag:        <http://www.holygoat.co.uk/owl/redwood/0.1/tags/> ."                                                 >> $cockpit/publish/$sdv.void.ttl
   echo "@prefix void:       <http://rdfs.org/ns/void#> ."                                                                        >> $cockpit/publish/$sdv.void.ttl
   echo "@prefix dcat:       <http://www.w3.org/ns/dcat#> ."                                                                      >> $cockpit/publish/$sdv.void.ttl
   echo "@prefix conversion: <http://purl.org/twc/vocab/conversion/> ."                                                           >> $cockpit/publish/$sdv.void.ttl
   echo "@prefix datafaqs:   <http://purl.org/twc/vocab/datafaqs#> ."                                                             >> $cockpit/publish/$sdv.void.ttl
   echo                                                                                                                           >> $cockpit/publish/$sdv.void.ttl
   echo "<$topVoID>"                                                                                                              >> $cockpit/publish/$sdv.void.ttl
   echo "   a void:Dataset, dcat:Dataset;"                                                                                        >> $cockpit/publish/$sdv.void.ttl
   echo "   void:rootResource <$topVoID>;"                                                                                        >> $cockpit/publish/$sdv.void.ttl
   echo "   void:dataDump     <$baseURI/source/$sourceID/file/$datasetID/version/$versionID/conversion/$dumpFileLocal>;"          >> $cockpit/publish/$sdv.void.ttl
   echo "   dcat:distribution <$baseURI/source/$sourceID/file/$datasetID/version/$versionID/conversion/$dumpFileLocal>;"          >> $cockpit/publish/$sdv.void.ttl
   if [[ "$CSV2RDF4LOD_PUBLISH_VIRTUOSO" == "true" && "$CSV2RDF4LOD_PUBLISH_VIRTUOSO_SPARQL_ENDPOINT" =~ http* ]]; then
      echo "   void:sparqlEndpoint <$CSV2RDF4LOD_PUBLISH_VIRTUOSO_SPARQL_ENDPOINT>;"                                              >> $cockpit/publish/$sdv.void.ttl
      echo "   dcat:distribution   <$CSV2RDF4LOD_PUBLISH_VIRTUOSO_SPARQL_ENDPOINT>;"                                              >> $cockpit/publish/$sdv.void.ttl
   fi
   echo "   foaf:page <$baseURI/source/$sourceID/file/cr-sitemap/version/latest/conversion/sitemap.xml>;"                         >> $cockpit/publish/$sdv.void.ttl
   echo "   tag:taggedWithTag <http://datahub.io/tag/lod>, <http://datahub.io/tag/prizms>,"                                       >> $cockpit/publish/$sdv.void.ttl
   echo "                     <http://datahub.io/tag/vocab-mappings>, <http://datahub.io/tag/deref-vocab>;"                       >> $cockpit/publish/$sdv.void.ttl
   echo "                     <http://datahub.io/tag/provenance-metadata>;"                                                       >> $cockpit/publish/$sdv.void.ttl
   echo "   void:uriSpace \"$baseURI/\";"                                                                                         >> $cockpit/publish/$sdv.void.ttl
   echo "   prov:wasDerivedFrom <$mappings>;"                                                                                     >> $cockpit/publish/$sdv.void.ttl
   echo "."                                                                                                                       >> $cockpit/publish/$sdv.void.ttl
   echo "<$mappings>"                                                                                                             >> $cockpit/publish/$sdv.void.ttl
   echo "   dcterms:description \"mappings/twc-conversion\";"                                                                     >> $cockpit/publish/$sdv.void.ttl
   echo "   a conversion:VocabularyMappings ."                                                                                    >> $cockpit/publish/$sdv.void.ttl
   echo "<$baseURI/source/$sourceID/file/$datasetID/version/$versionID/conversion/$dumpFileLocal>"                                >> $cockpit/publish/$sdv.void.ttl
   echo "   dcterms:format   <http://www.w3.org/ns/formats/N-Triples>;"                                                           >> $cockpit/publish/$sdv.void.ttl
   echo "   dcat:downloadURL <$baseURI/source/$sourceID/file/$datasetID/version/$versionID/conversion/$dumpFileLocal>;"           >> $cockpit/publish/$sdv.void.ttl
   echo "."                                                                                                                       >> $cockpit/publish/$sdv.void.ttl
   echo "<$baseURI/source/$sourceID/file/cr-sitemap/version/latest/conversion/sitemap.xml>"                                       >> $cockpit/publish/$sdv.void.ttl
   echo "   a <http://dbpedia.org/resource/Site_map>;"                                                                            >> $cockpit/publish/$sdv.void.ttl
   echo "   dcterms:subject <$topVoID>;"                                                                                          >> $cockpit/publish/$sdv.void.ttl
   echo "."                                                                                                                       >> $cockpit/publish/$sdv.void.ttl
   # TODO: <$topVoID> void:exampleResource ?x from:
   #
   pushd $cockpit/automatic &> /dev/null
      echo "prefix dcterms: <http://purl.org/dc/terms/>"                                                                                            > exampleResource.rq
      echo "prefix void:    <http://rdfs.org/ns/void#>"                                                                                            >> exampleResource.rq
      echo "select distinct ?ex ?date"                                                                                                             >> exampleResource.rq
      echo "where { "                                                                                                                              >> exampleResource.rq
      echo "  ?s void:exampleResource ?ex; dcterms:modified ?date ."                                                                               >> exampleResource.rq
      echo "  filter(!regex(str(?ex),'thing_'))"                                                                                                   >> exampleResource.rq
      echo " }"                                                                                                                                    >> exampleResource.rq
      echo "order by ?date"                                                                                                                        >> exampleResource.rq
      echo "limit 1"                                                                                                                               >> exampleResource.rq
   popd &> /dev/null
   if [[ -n "$CSV2RDF4LOD_PUBLISH_DATAHUB_METADATA_OUR_BUBBLE_ID" ]]; then
      echo "<$topVoID> owl:sameAs <http://datahub.io/dataset/$CSV2RDF4LOD_PUBLISH_DATAHUB_METADATA_OUR_BUBBLE_ID>;"               >> $cockpit/publish/$sdv.void.ttl
      echo "   a datafaqs:CKANDataset;"                                                                                           >> $cockpit/publish/$sdv.void.ttl
      echo "   dcterms:identifier \"$CSV2RDF4LOD_PUBLISH_DATAHUB_METADATA_OUR_BUBBLE_ID\";"                                       >> $cockpit/publish/$sdv.void.ttl
      echo "."                                                                                                                    >> $cockpit/publish/$sdv.void.ttl
   fi

   echo "$cockpit/publish/$sdv.ephemeral.ttl (void:triples)"
   triples=`rdf2nt.sh $cockpit/publish/$dumpFileLocal | rapper -i ntriples -c -I http://blah - 2>&1 | awk '$0~/Parsing returned/{print $4}'`
   if [[ ${#triples} -gt 0 && $triples == [0-9]* ]]; then # - - - - - - - - - - Avoid publish/*.void.ttl pattern so that cr-publish-void-to-endpoint.sh doesn't find it.
      echo "@prefix dcterms: <http://purl.org/dc/terms/> ."                                                                          >> $cockpit/publish/$sdv.ephemeral.ttl
      echo "@prefix void:    <http://rdfs.org/ns/void#> ."                                                                           >> $cockpit/publish/$sdv.ephemeral.ttl
      echo "@prefix dat:     <http://www.w3.org/ns/dcat#> ."                                                                         >> $cockpit/publish/$sdv.ephemeral.ttl
      echo "<$topVoID> void:triples $triples ."                                                                                      >> $cockpit/publish/$sdv.ephemeral.ttl
      echo "<$topVoID> dcterms:date `dateInXSDDateTime.sh --turtle` ."                                                               >> $cockpit/publish/$sdv.ephemeral.ttl
      echo $topVoID                                                                                                                   > $cockpit/publish/$sdv.ephemeral.ttl.sd_name
      pvdelete.sh $topVoID
      vload ttl $cockpit/publish/$sdv.ephemeral.ttl $topVoID -v
   fi

   #      __________________________""""""""_____________________""""""____________"""""""""______""""""""""""_________________________
   # e.g. http://purl.org/twc/health/source/healthdata-tw-rpi-edu/file/cr-full-dump/version/latest/conversion/purl-org-twc-health.nt.gz
   #
   #      hosted at:
   #                        ________""""""""_____________________""""""____________"""""""""______""""""""""""_________________________
   #                        /var/www/source/healthdata-tw-rpi-edu/file/cr-full-dump/version/latest/conversion/purl-org-twc-health.nt.gz


         # NOTE: this is repeated from bin/aggregate-source-rdf.sh - be sure to align with it.
         # (update: This might have been superceded by bin/aggregate-source-rdf.sh, check!)
         # (update 24 Apr 2013 - this is superceded by cr-ln-to-www-root.sh publish/lofd-tw-rpi-edu.nt.gz, but that's not working (below))
         sudo="sudo"
         if [[ `whoami` == root ]]; then
            sudo=""
         elif [[ "`stat --format=%U "$CSV2RDF4LOD_PUBLISH_VARWWW_ROOT/source"`" == `whoami` ]]; then
            sudo=""
         fi
         
         symbolic=""
         wd=""
         if [[ "$CSV2RDF4LOD_PUBLISH_VARWWW_LINK_TYPE" == "soft" ]]; then
           symbolic="-sf "
           wd=`pwd`/
         fi
         
         wwwFile="$CSV2RDF4LOD_PUBLISH_VARWWW_ROOT/source/$sourceID/file/$datasetID/version/$versionID/conversion/$dumpFileLocal"
         echo "$wwwFile"
         $sudo rm -f $wwwFile
         echo $sudo ln $symbolic "${wd}$cockpit/publish/$dumpFileLocal" $wwwFile
              $sudo ln $symbolic "${wd}$cockpit/publish/$dumpFileLocal" $wwwFile

   #pushd $cockpit &> /dev/null
   #   # Replaces duplication above:
   #   cr-ln-to-www-root.sh publish/$dumpFileLocal
   #   one_click_dump=`cr-ln-to-www-root.sh -n --url-of-filepath publish/$dumpFileLocal`
   #
   #   # In case the triples we snuck in didn't get published into /var/www
   #   #cr-ln-to-www-root.sh publish/$base.void.ttl
   #popd &> /dev/null
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

dryrun.sh $dryrun ending
