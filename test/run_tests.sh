#!/bin/sh

set -ex

BOLD="\e[1m"
RESET="\e[0m"
LIGHT_RED="\e[91m"
LIGHT_GREEN="\e[92m"
LIGHT_CYAN="\e[96m"

logging(){
	local type=$1; shift
	printf "${LIGHT_CYAN}${BOLD}run_tests${RESET} [%b] : %b\n" "$type" "$*"
}
log_info(){
	logging "${LIGHT_GREEN}info${RESET}" "$@"
}
log_error(){
	logging "${LIGHT_RED}error${RESET}" "$@" >&2
	exit 1
}

PID=""

# to properly kill child process executed in background on exit
at_exit() {
	[ $? -eq 0 ] && log_info "Seem all went well" && exit 0
	# Code for non-zero exit:
	if ! kill -s TERM "$PID" || ! wait "$PID" ; then
		log_error "Something went wrong. Failed to kill pid" "$PID"
	fi
	log_error "Something went wrong. Pid $PID has been killed"
}
# to properly quit ctrl+c
int_handler(){
	kill -s TERM "$PID"
	wait
	log_info "Tests abort"
	exit 1
}

# look at test/main.c and run ./mlx-test to understand what this function does
test_default_main(){
	./mlx-test &
	PID="$!"
	log_info "./mlx-test running in background, pid:" $PID
	
	i=30		# waiting 30s mlx-test to be ready for inputs.
	while [ $i -gt 0 ]; do
		# ready="$(graal command? || true)"
		# if [ "$ready" ]; then
		# 	break
		# fi
		log_info "countdown" $i
		sleep 1
		i=$((i - 1))
	done
	log_info "Ready to \"just play\" using xdotool"
	wid1=$(xdotool search --name Title1)
	wid2=$(xdotool search --name Title2)
	wid3=$(xdotool search --name Title3)
	
	xdotool windowfocus $wid3
	log_info "Focus Win3: Testing move mouse"
	xdotool mousemove 100 100
	xdotool mousemove 200 200
	log_info "Focus Win3: Pressing escape to destroy window \"Win3\""
	xdotool key Escape
	
	log_info "Focus Win2: Pressing escape to stop program"
	xdotool windowfocus $wid2
	xdotool key Escape

}

main(){
	log_info "DISPLAY=$DISPLAY"

	trap at_exit		EXIT
	trap int_handler	INT

	test_default_main
	# add more and proper (unit)tests ? (a test function must exit 1 if it fail)
	# test/ hierarchy files should probably be refactorised if more main tests are added
	# and this script too need some refactorisation to be extensible.
	# But for now it is better than nothing
}

main "$@"