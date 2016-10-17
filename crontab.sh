#!/bin/bash

ROOT_PATH=/home/nico/Documents/ClaroMono
LOGS_DIR=/home/nico/Downloads/estp
CSV_DIR=/home/nico/Downloads/estp
EMAIL=nicolas.godfraind@gmail.com

#ROOT_PATH=/var/www/html/claroline
#LOGS_DIR=/home/exploitation/Rapport_logs
#CSV_DIR=/home/exploitation/Depot_fichiers_csv
#EMAIL=nicolas.godfraind@gmail.com

CONSOLE=$ROOT_PATH/app/console
TRAITE=$CSV_DIR/Traite
ELEVES_FILE=$CSV_DIR/import_eleves.csv
TEACHERS_FILE=$CSV_DIR/import_enseignants.csv

MONTHS=( ZERO Janvier Fevrier Mars Avril Mai Juin Juillet Aout Septembre Octobre Novembre Decembre )

# Define a timestamp function
timestamp() {
    date "+%Y-%m-%d"
}

month() {
    date "+%m"
}

year() {
   date  "+%Y"
}

sendmail() {
    cat $1 | mail -s "Compte rendu cron" $EMAIL
}

MONTHLY_LOGS_DIR=${LOGS_DIR}/${MONTHS[$(month)]}_$(year)

mkdir -p $MONTHLY_LOGS_DIR

if [ -f $ELEVES_FILE ];
then
    LOGFILE=$MONTHLY_LOGS_DIR/$(timestamp)-eleves.log
    php $CONSOLE claroline:csv:user $ELEVES_FILE 2>&1 | tee -a $LOGFILE
    cp $ELEVES_FILE $TRAITE/import_eleves-$(timestamp).csv 
    sendmail "$LOGFILE"
fi

if [ -f $TEACHERS_FILE ];
then
    LOGFILE=$MONTHLY_LOGS_DIR/$(timestamp)-enseignants.log
    php $CONSOLE claroline:csv:user -i $TEACHERS_FILE 2>&1 | tee -a $LOGFILE
    mv $CSV_DIR/import_enseignants.csv $TRAITE/import_enseignants-$(timestamp).csv
    sendmail "$LOGFILE"
fi

