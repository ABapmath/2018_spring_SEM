#!/bin/bash
WORK_DIR="${HOME}/"
THREADS=1
IFS=$'\r\n' GLOBIGNORE='*' command eval  'CONFIG=($(cat ./config))'
for i in "${CONFIG[@]}"; do
    #echo $i
    VAR=$( echo $i | cut -d= -f1 )
    VAL=$( echo $i | cut -d= -f2 )
    if [ "$VAR" == "threads" ]; then
        if [[ $VAL =~ ^[1-9][0-9]*$ ]]; then
            THREADS=$VAL
        else
            zenity --warning --text="\"threads\" parameter must be an integer.\nSpecified as ${VAL}.\nWill use ${THREADS}."
        fi
    fi
    if [ "$VAR" == "WORK_DIR" ]; then
        if [ -d "$VAL" ]; then
            WORK_DIR="$VAL"
        else
            zenity --warning --text="\"WORK_DIR\" parameter must be a path to an existing directory.\nSpecified as ${VAL}.\nWill use ${WORK_DIR}."
        fi
    fi
    if [ "$VAR" == "METAPHLAN_DIR" ]; then
        if [ -d "$VAL" ]; then
            METAPHLAN_DIR=$VAL
        else
            zenity --warning --text="\"METAPHLAN_DIR\" parameter must be a path to an existing directory.\nSpecified as ${VAL}.\nWill use ${METAPHLAN_DIR}."
        fi
    fi
done
echo "threads=$THREADS"

INPUT_ZEN=$(zenity --file-selection --filename=$WORK_DIR --multiple --title="Open")
if [ "$INPUT_ZEN" = "" ]; then
    exit
fi
declare -a NAME
declare -a LANE
declare -a READ
declare -a U_SAMPLE
declare -a SAMPLE_IDX
declare -a DONE
declare -a ERROR_NAME
SAMP_LEN=0
IFS='|' read -a arr <<<"$INPUT_ZEN"
arr_len=${#arr[@]}
echo $arr_len
COUNTER=0
#cut filenames into pieces
while [  $COUNTER -lt $arr_len ]; do
#    echo $COUNTER
    i=${arr[$COUNTER]}
#for i in "${arr[@]}"; do
#    echo $i
    FILENAME=$( echo $i | rev | cut -d/ -f1 | rev )
#    echo $FILENAME
    NAME[$COUNTER]=$( echo $FILENAME | cut -d_ -f1 )
    SAMPLE=$( echo $FILENAME | cut -d_ -f2 )
    LANE[$COUNTER]=$( echo $FILENAME | cut -d_ -f3 )
    READ[$COUNTER]=$( echo $FILENAME | cut -d_ -f4 )
    #set flags of files on 0
    DONE[$COUNTER]=0
#    echo ${NAME[$COUNTER]}
#    echo $SAMPLE
#    echo ${LANE[$COUNTER]}
#    echo ${READ[$COUNTER]}
    TRIG=0
    SAMP_COUNTER=0
    while [  $SAMP_COUNTER -lt $SAMP_LEN ]; do
        if [  ${U_SAMPLE[$SAMP_COUNTER]} == $SAMPLE ]; then
            TRIG=1
            break
        fi
        let SAMP_COUNTER=SAMP_COUNTER+1
    done
    if [  $TRIG -eq 0 ]; then
        U_SAMPLE[$SAMP_LEN]=$SAMPLE
#        echo ${U_SAMPLE[$SAMP_COUNTER]}
        let SAMP_LEN=SAMP_LEN+1
#        echo $SAMP_LEN
    fi
    SAMPLE_IDX[$COUNTER]=$SAMP_COUNTER
    # process "$i"
    let COUNTER=COUNTER+1 
done
#echo $SAMP_LEN
OUTPUT_ZEN=$(zenity --file-selection --filename=$WORK_DIR --directory --save --title="Save into")/
if [ "$OUTPUT_ZEN" == "" ]; then
    exit
fi
#was no / character in zenity return
echo Вывод в $OUTPUT_ZEN
SAMP_COUNTER=0
while [  $SAMP_COUNTER -lt $SAMP_LEN ]; do
    TRIG=0
    TEMP_NAME=""
    OUT_DIR=$OUTPUT_ZEN${U_SAMPLE[$SAMP_COUNTER]}/
    mkdir $OUT_DIR
    mkdir ${OUT_DIR}kneaddata/
    LANE_LEN=0
#    declare -a TEMP_LANES
    while [  $TRIG -eq 0 ]; do
        CUR_LANE=""
        R1=""
        R2=""
        COUNTER=0
        while [  $COUNTER -lt $arr_len ]; do
            if [  ${DONE[$COUNTER]} -eq 0 ]; then
            if [  ${SAMPLE_IDX[$COUNTER]} -eq $SAMP_COUNTER ]; then
                if [  "$CUR_LANE" == "" ]; then
                    CUR_LANE=${LANE[$COUNTER]}
                fi
                if [  "$CUR_LANE" == "${LANE[$COUNTER]}" ]; then
                    if [  "${READ[$COUNTER]}" == "R1" ]; then
                        R1=$COUNTER
                    elif [  "${READ[$COUNTER]}" == "R2" ]; then
                        R2=$COUNTER
                    else
                        DONE[$COUNTER]=1
                        ERROR_NAME[$COUNTER]=1
                    fi
                fi
            fi
            fi
            let COUNTER=COUNTER+1
        done
        if [  "$CUR_LANE" == "" ]; then
            TRIG=1
        else
            if [  "$R1" == "" ] || [  "$R2" == "" ]; then
                if [  "$R1" != "" ]; then
                    DONE[$R1]=1
                    ERROR_NAME[$R1]=2
                fi
                if [  "$R2" != "" ]; then
                    DONE[$R2]=1
                    ERROR_NAME[$R2]=2
                fi
            else
                DONE[$R1]=1
                DONE[$R2]=1
                if [  "$TEMP_NAME" == "" ]; then
                    TEMP_NAME=${NAME[$R1]}
                fi
#                TEMP_LANES[$LANE_LEN] = $CUR_LANE
                let LANE_LEN=LANE_LEN+1
                echo ${U_SAMPLE[$SAMP_COUNTER]}
                echo $CUR_LANE
                echo ${arr[$R1]}
                echo ${arr[$R2]}
                #do the actual thing
                kneaddata --input ${arr[$R1]} --input ${arr[$R2]} --output ${OUT_DIR}kneaddata/
            fi
        fi
    done
    if [  $LANE_LEN -eq 0 ]; then
        let SAMP_COUNTER=SAMP_COUNTER+1
        continue
    fi
    #concat and report
    echo "Concatenating trimmed reads"
    rm ${OUT_DIR}kneaddata/*.trimmed.single.1.fastq
    rm ${OUT_DIR}kneaddata/*.trimmed.single.2.fastq
    cat `find ${OUT_DIR}kneaddata/ -name '*.fastq' -print` > ${OUT_DIR}${TEMP_NAME}.fastq

    echo "Run HUMAnN2"
    humann2 --input ${OUT_DIR}${TEMP_NAME}.fastq --output ${OUT_DIR} --output-basename ${TEMP_NAME} --threads $THREADS --metaphlan ${METAPHLAN_DIR}
    chmod -R -x+X ${OUT_DIR}

    let SAMP_COUNTER=SAMP_COUNTER+1
done
#if ERROR then there is no pair for file ... or its name is not Illumina-esque 
#    i.e. name_S1_L001_R1_001.fastq.gz
COUNTER=0
while [  $COUNTER -lt $arr_len ]; do
    if [  -n "${ERROR_NAME[$COUNTER]}" ]; then
    if [  ${ERROR_NAME[$COUNTER]} -eq 1 ]; then
        zenity --warning --text="${arr[$COUNTER]} filename\ndoes not contain R1 or R2 in R# position. Example:\nname_S1_L001_R#_001.fastq.gz"
    elif [  ${ERROR_NAME[$COUNTER]} -eq 2 ]; then
        zenity --warning --text="${arr[$COUNTER]}\n have no paired file."
    fi
    fi
    let COUNTER=COUNTER+1
done

