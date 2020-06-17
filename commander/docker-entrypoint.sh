#!/usr/bin/env bash

FOLDER="$(realpath "$(dirname "$0")")"

function usage() {
	echo "docker-entrypoint.sh {cmd1} {arg1_1} ... {arg1_N} --- {cmd2} {arg2_1} ... {arg2_N}"
	echo "  {cmd_X}    				command you want run"
	echo "  {arg_X1} ... {arg_XN}	Command Arguments arg1 ... argN"
	echo "  ---						Command separator"
}

LOGFILE="/var/log/commander.log"

echo "" > $LOGFILE

if [ "-h" = "$1" ] || [ "--help" = "$1" ]; then
	echo "Usage:"
	echo "$(usage)"
	echo "COMMANDER: Exit!!"
	exit 0
fi
if [ $# -gt 0 ]; then
	command=""
	for arg in $@; do
		if [ "x$arg" != "x---" ]; then
			# not separator
			command="$command $arg"
		else
			# separator
			echo " " >> $LOGFILE
			echo "COMMANDER: Running command: $command" >> $LOGFILE
			bash -c "$command" >> $LOGFILE
			command=""
		fi
	done
	if [ "x" != "x$command" ]; then
		echo " " >> $LOGFILE
		echo "COMMANDER: Running command: $command" >> $LOGFILE
		bash -c "$command" >> $LOGFILE
	fi
	tail -f $LOGFILE
else 
	echo "COMMANDER: No command given ..."
fi
echo "COMMANDER: Exit!!"
exit 0