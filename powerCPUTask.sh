#!/bin/bash

### BEGIN PROGRAM INFO
# Author: Rafael Tessarolo
# Name: powerCPUTask
# Description: Verifies a Process Using Too Much CPU and Changes its Priority.
### END PROGRAM INFO

PROGRAMNAME="powerCPUTask"
CDATE=$(date "+%d-%m-%Y %H:%M:%S")
TIME=$(date "+%H:%M")
LOG="| $CDATE | $PROGRAMNAME | LOG | "
PID=""
PTIME=""
NICE=""
PRI=""

function verifyHighCPUProcess() {
        echo "$LOG Verifying process using too much CPU..."
        PID=$(ps aux | sort -k 4 -r | head -n 2 | awk 'END{print $2}')
}

function datediff() {
    d1=$(date -d "$1" +%s)
    d2=$(date -d "$2" +%s)
    echo $(( (d1 - d2) / 86400 ))
}

function verifyProcessTime() {
        echo "$LOG Verifying time of the process (PID: $PID) using CPU the most..."
        PTIME=$(ps aux | sort -k 4 -r | head -n 2 | awk 'END{print $9}')

        echo "$LOG Time found in the process (PID: $PID): $PTIME"
        DIFF=$(datediff $TIME $PTIME)
        if [[ $DIFF > 86400‬ ]]
        then
                echo "$LOG Time of the process is too high (PTIME: $PTIME)"
                PRI="TOO HIGH"
                NICE="-20"
        else
                echo "$LOG Time of the process is normal (PTIME: $PTIME)"
                PRI="HIGH"
                NICE="-10"
        fi
}

function prioritizeProcess() {
        PID=$1
        echo "$LOG Prioritizing process (PID: $PID) with priority $PRI..."
        renice $NICE -p $PID
}

function main() {
        while [[ true ]]; do
                echo "$LOG Starting Programa..."
                verifyHighCPUProcess
                verifyProcessTime
                prioritizeProcess $PID
                echo "$LOG Ending Programa..."
                sleep 60m
        done
}

main
