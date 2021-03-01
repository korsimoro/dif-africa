#!/bin/bash
BASE=~/Desktop/dif-apac
DATA=$BASE/data-processing
NOTION=$DATA/scopes/notion
SITE=$BASE/static-site
ASSETS=$SITE/assets
JSON=$ASSETS/json

mkdir -p $JSON
for name in Schedule Countries Companies People; do
	csv2json < $NOTION/$name*.csv > $JSON/$name.json
	json2yaml $JSON/$name.json > $SITE/_data/$name.yml
done
echo 0
