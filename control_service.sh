#!/bin/bash

PID_FILE="/tmp/custom_keybind.pid"
STATUS_FILE="/tmp/custom_keybind.status"
BINARY_PATH="./custom_keybind"

case "$1" in
	start)
		if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
			echo "Service already running (PID: $(cart $PID_FILE))"
		else
			echo "Starting service..."
			nohup $BINARY_PATH > /dev/null 2>&1 &
			sleep 1
			if [ -f "$PID_FILE" ]; then
				echo "Service started (PID: $(cat $PID_FILE))"
			else
				echo "Error when starting"
			fi
		fi
		;;
	stop)
		if [ -f "$PID_FILE" ]; then
			PID=$(cat $PID_FILE)
			if kill -0 $PID 2>/dev/null; then
				kill $PID
				echo "Service stopped"
			else
				echo "Service not found"
				rm -f $PID_FILE $STATUS_FILE
			fi
		else
			echo "Service not running"
		fi
		;;
	status)
		if [ -f "$PID_FILE" ] && kill -0 $(cat $PID_FILE) 2>/dev/null; then
			STATUS=$(cat $STATUS_FILE 2>/dev/null || echo "UNKNOWN")
			echo "Service running (PID: $cat $PID_FILE), Status: $STATUS)"
		else
			echo "Service stopped"
		fi
		;;
	restart)
		$0 stop
		sleep 2
		$0 start
		;;
	*)
		echo "Usage: $0 {start|stop|status|restart}"
		exit 1
		;;
esac
