#!/bin/bash
set -xe

if [ -n "$1" ]; then
    echo "Currently, only data from 2018 is verified."
    echo "Run '$0' without parameters to download the 2018 data."
    exit 0
fi

YEAR=$1
MONTH=$2

if [ -z $YEAR ]; then
    YEAR=2018
fi

if [ -z $MONTH ]; then
    MONTH=$(seq 1 12)
fi

DOWNLOAD_FOLDER=_download
mkdir -p ${DOWNLOAD_FOLDER}

for m in $MONTH
do
    zip_file_name=On_Time_Reporting_Carrier_On_Time_Performance_1987_present_${YEAR}_${m}
    wget -P $DOWNLOAD_FOLDER https://transtats.bts.gov/PREZIP/$zip_file_name.zip
    unzip ${DOWNLOAD_FOLDER}/$zip_file_name.zip -d ${DOWNLOAD_FOLDER}/$zip_file_name
    mv ${DOWNLOAD_FOLDER}/$zip_file_name/On_Time_Reporting_Carrier_On_Time_Performance_\(1987_present\)_${YEAR}_$m.csv data/On_Time_Reporting_Carrier_On_Time_Performance_${YEAR}_$m.csv
done
