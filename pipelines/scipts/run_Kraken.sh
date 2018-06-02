#!/bin/bash
CUFLAG=0
THREADS=1
while getopts k:b:i:o:n:w:p:d:c opts; do
   case ${opts} in
      k) KRAKEN_DIR=${OPTARG} ;;
      b) DB=${OPTARG} ;;
      i) INPUT=${OPTARG} ;;
      o) OUTPUT_DIR=${OPTARG} ;;
      n) SAMPLE=${OPTARG} ;;
      c) CUFLAG=1 ;;
      w) WORK_DIR=${OPTARG} ;;
      p) THREADS=${OPTARG} ;;
      d) DB_DIR=${OPTARG} ;;
   esac
done
if [ "$CUFLAG" -eq 1 ];then
    CU="--classified-out $OUTPUT_DIR$SAMPLE.kraken.classified.fasta --unclassified-out $OUTPUT_DIR$SAMPLE.kraken.unclassified.fasta"
fi
cd $WORK_DIR
mkdir -p $OUTPUT_DIR
${KRAKEN_DIR}/bin/kraken --db "$DB_DIR$DB" $CU --threads $THREADS $INPUT > $OUTPUT_DIR$SAMPLE.kraken.output.tsv
