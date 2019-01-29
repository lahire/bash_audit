#!/bin/bash
##      CONFIG
#Influx that we will use
INFLUX="http://grafana.local:8086/write?db"
#Database to use
DB="data"
#Measurement to use. If does not exist, the first audit creates it.
#more info in
# https://docs.influxdata.com/influxdb/v1.7/guides/writing_data/
MEASUREMENT="bash_audit"
##
# This is the command that we will insert onto influx
# $last_command is exported on the TRAP on the .bashrc
#!!! we NEED the .bashrc configured for this to work!
COMMAND=$last_command
# with $last_command exported from the .bashrc, we don't need it to 
#pass it as a parameter.
#This allows us to pass the string comment as the first parameter of
#this script, hence the $1 bellow.
COMMENT="$1"
#

######
#--data-binary has this structure
# Measurement,keys,keys,(...) field,field,field(...)
# Keys & Fields are separated from each other with a whitespace
# All the specific values are separated with commas.
#
#Add your tags and fields here!
#TAGS
USER=$(echo $(who am i) | cut -d" " -f1)
HOSTNAME=$(echo $(cat /etc/hostname))
#FIELDS
#Command
PWD=$(echo $(pwd))


#And then put them here!
DATABINARY="$MEASUREMENT,user=$USER,hostname=$HOSTNAME command=\"$COMMAND\",comment=\"$COMMENT\",pwd=\"$PWD\""
#Beware the alien, the mutant, the scaped character

#Send the values to influx with curl
curl --silent -XPOST "$INFLUX=$DB" --data-binary "$DATABINARY"
