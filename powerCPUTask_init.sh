#!/bin/bash

### BEGIN INIT INFO
# Author: Rafael Tessarolo
# Required-Start: $all
# Required-Stop: $local_fs
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Description: Verifies Process Using Too Much CPU.
### END INIT INFO

PROGRAMNAME="powerCPUTask"

DAEMON_PATH="/etc/$PROGRAMNAME"
DAEMON="$DAEMON_PATH/$PROGRAMNAME.sh"
NAME="$PROGRAMNAME"
LOGFILE="/var/log/$NAME.log"
DESC="$PROGRAMNAME Daemon"
PIDFILE=$DAEMON_PATH/pid/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME
RUNTIME="$2"

function start() {
	printf "%-50s" "Starting $NAME..."
	PID=`$DAEMON >> $LOGFILE 2>&1 & echo $!`
	# echo "Saving PID" $PID " to " $PIDFILE
    if [ -z $PID ]; then
        printf "%s\n" "Fail create PID File"
    else
        echo $PID > $PIDFILE
        printf "%s\n" "Create PID File"
    fi
}

function status() {
    printf "%-50s" "Checking $NAME..."
    if [ -f $PIDFILE ]; then
        PID=`cat $PIDFILE`
        if [ -z "`ps axf | grep ${PID} | grep -v grep`" ]; then
            printf "%s\n" "Process dead but pidfile exists"
        else
            echo "Running"
        fi
    else
        printf "%s\n" "Service not running"
    fi
}

function stop() {
    printf "%-50s" "Stopping $NAME"
        PID=`cat $PIDFILE`
        cd $DAEMON_PATH
    if [ -f $PIDFILE ]; then
        kill -9 $PID
        printf "%s\n" "Ok"
        rm -f $PIDFILE
    else
        printf "%s\n" "pidfile not found"
    fi
}

function runtime() {
	printf "%-50s" "Starting $NAME and modifying runtime..."
	echo $RUNTIME
	PID=`$DAEMON $RUNTIME >> $LOGFILE 2>&1 & echo $!`
	#echo "Saving PID" $PID " to " $PIDFILE
    if [ -z $PID ]; then
        printf "%s\n" "Fail"
    else
        echo $PID > $PIDFILE
        printf "%s\n" "Ok"
    fi
}

case "$1" in
	
	start)
		start
	;;
	
	status)
		status
	;;
	
	stop)
		stop
	;;

	restart)
	  	stop
	  	start
	;;
	
	runtime)
		if [[ -z $2 ]]; then
			echo "Invalid argument"
		else
			stop
			runtime
		fi
	;;
	
	log|stdout)
		if [ -f $LOGFILE ]; then
			tail -f -n 30 $LOGFILE
		else
			echo "No log output yet"
		fi
	;;

	help|?|--help|-h)
        echo "Usage: $0 {status|start|stop|restart|runtime|(log|stdout)}"
        exit 0
    ;;

    *)
		echo "Invalid argument"
		echo
		$0 help
esac
