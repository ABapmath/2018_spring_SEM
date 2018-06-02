#!/bin/bash
while getopts k:b:o:n:w:v:d: opts; do
   case ${opts} in
      k) KRAKEN_DIR=${OPTARG} ;;
      b) DB=${OPTARG} ;;
      o) OUTPUT_DIR=${OPTARG} ;;
      n) SAMPLE=${OPTARG} ;;
      w) WORK_DIR=${OPTARG} ;;
      v) FILTER=${OPTARG} ;;
      d) DB_DIR=${OPTARG} ;;
   esac
done
cd $WORK_DIR
${KRAKEN_DIR}/bin/kraken-filter --db $DB_DIR$DB $OUTPUT_DIR$SAMPLE.kraken.output.tsv --threshold "$FILTER" > $OUTPUT_DIR$SAMPLE.kraken.output.filter.tsv

