#!/usr/bin/env bash

APPDIR=$PWD
APPNAME=$(basename $APPDIR)
SYSID=$2

if [[ -z ${SYSID-} ]]; then
   echo "-s SysID must be set."
   exit 1
fi

declare -A dataFileNames=(
#["RDO"]="SLN"
["USRSEC"]="USRSEC"
["ACCTDAT"]="ACCDATA"
["CARDDAT"]="CARDDATA"
["CUSTDAT"]="CUSTDATA"
["CCXREF"]="CARDXREF"
["TRANSACT"]="DALYTRAN"
)

cd ..
echo "
*** POPULATE RDO TABLES ***
"
$OKDIR/bin/okpoprdo install $APPNAME $SYSID
$OKDIR/bin/okpoprdo USRSEC $APPNAME $SYSID
$OKDIR/bin/okpoprdo ACCTDAT $APPNAME $SYSID
$OKDIR/bin/okpoprdo CARDDAT $APPNAME $SYSID
$OKDIR/bin/okpoprdo CUSTDAT $APPNAME $SYSID
$OKDIR/bin/okpoprdo CCXREF $APPNAME $SYSID
$OKDIR/bin/okpoprdo TRANSACT $APPNAME $SYSID
$OKDIR/bin/okpoprdo alt $APPNAME $SYSID

cd $APPDIR
echo "
*** POPULATE VSAM TABLES ***
"
for file in src/rdo/*
    do
	BASENAME=$(basename $file)
	NAMENOEXT="${BASENAME%.rdo}"
	DATAFILE=${dataFileNames[$NAMENOEXT]}
	DATAFILEEXT="${DATAFILE}.sln"

        if [[ -z ${DATAFILE-} ]]; then
            echo "No data file for $file, skip"
  	else
 	    $OKDIR/bin/okpopfile $file src/data/$DATAFILEEXT $NAMENOEXT $SYSID
 	fi
    done

echo "
*** CREATE TDQ_* TABLES ***
"
$OKDIR/bin/okregion -e -s $SYSID

echo "
*** MASSCOMP ***
"
$OKDIR/bin/okmasscomp -s $SYSID $APPNAME
