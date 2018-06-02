#!/bin/bash
while getopts k:b:o:n:w:d: opts; do
   case ${opts} in
      k) KRAKEN_DIR=${OPTARG} ;;
      b) DB=${OPTARG} ;;
      o) OUTPUT_DIR=${OPTARG} ;;
      n) SAMPLE=${OPTARG} ;;
      w) WORK_DIR=${OPTARG} ;;
      d) DB_DIR=${OPTARG} ;;
   esac
done
cd $WORK_DIR
${KRAKEN_DIR}/bin/kraken-report --db $DB_DIR$DB $OUTPUT_DIR$SAMPLE.kraken.output.filter.tsv > $OUTPUT_DIR$SAMPLE.kraken.report.tsv

