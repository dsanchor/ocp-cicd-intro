#!/bin/bash

CICD_NS=$1
USERS_LIST=$2

ADMIN_USER=$3
OCP_API=$4

oc login -u $ADMIN_USER $OCP_API

for line in `cat $USERS_LIST`
do
  IFS='#' read -r -a array <<< "$line"
  echo "Bootstraping user => ${array[0]}  ${array[1]}"
  ./bootstrap-user.sh $CICD_NS ${array[0]}  ${array[1]} 
  echo "-------------------------------"
done 