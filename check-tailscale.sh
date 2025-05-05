#!/bin/bash

log() {
	echo "$(date +"%Y-%m-%d %T.%N") | $@"
}

setup_env() {
	#Detect the name of the display in use
	export display=":$(ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"
	
	#Detect the user using such display
	export user=$(who | grep '('$display')' | awk '{print $1}' | head -n 1)
	
	#Detect the id of the user
	export uid=$(id -u $user)
	
	log "display: ${display}"
	log "user using display: ${user} [${uid}]"

	export DISPLAY=${display}
	export XAUTHORITY=/home/${user}/.Xauthority
}

displaytime() {
	local T=$1
	local D=$((T/60/60/24))
	local H=$((T/60/60%24))
	local M=$((T/60%60))
	local S=$((T%60))
	(( $D > 0 )) && printf '%d days ' $D
	(( $H > 0 )) && printf '%d hours ' $H
	(( $M > 0 )) && printf '%d minutes ' $M
	(( $D > 0 || $H > 0 || $M > 0 )) && printf 'and '
	printf '%d seconds\n' $S
}

printrunning() {
	if [ $1 -eq 0 ]; then
		echo "Running"
	else
		echo "Stopped"
	fi
}

printcond() {
	if [ $1 -eq 0 ]; then
		echo "true"
	else
		echo "false"
	fi
}

notify-send() {
	sudo -u $user DISPLAY=$display DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus notify-send "$@"
}

main() {
	if [ "$EUID" -ne 0 ]; then
		echo "Please run as root"
		exit 1
	fi

	setup_env

	TICK=${TICK:-300}
	IDLE_TIME=${IDLE_TIME:-1800}

	log "Tick rate: ${TICK}"
	log "Idle time: ${IDLE_TIME}"

	while true; do
		# Check if factorio is running
		pgrep factorio &> /dev/null
		factorio_running=$?
		
		# Check if the machine is idle enough
		idle_time_ms=$(xprintidle)
		idle_time=$((idle_time_ms / 1000))
		
		# Check if tailscale is running
		tailscale status &> /dev/null
		tailscale_running=$?
		
		log "Tailscale: $(printrunning ${tailscale_running}) | Factorio: $(printrunning ${factorio_running}) | Idle: $(displaytime ${idle_time})"
		
		if [[ ${tailscale_running} -eq 0 && ${factorio_running} -ne 0 && ${idle_time} -ge ${IDLE_TIME} ]]; then
			log "Shutting down tailscale"
			log $(tailscale down)
			log "Notifying user..."
			notify-send -c network -u critical "Tailscale has been disconnected" "Tailscale was left running without Factorio or user activity"
		fi

		sleep ${TICK}
	done
}

main
