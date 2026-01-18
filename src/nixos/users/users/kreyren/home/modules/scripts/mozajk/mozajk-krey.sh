#@ This POSIX Shell Script is executed in an isolated reproducible environment managed by Nix <https://github.com/NixOS/nix>, which handles dependencies, ensures deterministic function imports, sets any needed variables and performs strict linting prior to script execution to capture common issues for quality assurance.

# shellcheck disable=SC2154 # Do not trigger SC2154 for variables provided to the environment by Nix
# { }

### [START] Export this outside [START] ###

# FIXME-QA(Krey): This should be a runtimeInput
die() { printf "FATAL: %s\n" "$2"; exit ;} # Termination Helper

# FIXME-QA(Krey): This should be a runtimeInput
status() { printf "STATUS: %s\n" "$1" ;} # Status Helper

# FIXME-QA(Krey): This should be a runtimeInput
warn() { printf "WARNING: %s\n" "$1" ;} # Warning Helper

### [END] Export this outside [END] ###

###! # Mozajk
###! The MOZAJK is a custom-made informational panel mounted in the Base48 Hackerspace composed out of neopixels in 5x8(?) pixels per 8 panels which is usually used to show useful informations e.g. if someone's at the door, temperature, humidity and also useless things like the cost of BTCUSD.. This script is used to send custom texts to the panel.
###!
###! ## FIVE Seconds intervals are important
###! MOZAJK only shows whatever is in it's buffer every 5 sec so if you try to send something faster then it won't be shown until MOZAJK refreshes itself again.. This should be solvable by adjusting the weird golang code at https://github.com/base48/ticker2
###!
###! ## Designs constraints
###! * Max 8 letters at once with FIVE seconds delay in-between updates
###! * Tested functional characters: [a-z][0-9]._
###! * The character '+' can be used for spacer

# Must be connected on local Base48 WiFi to work right now
## FIXME(Krey): Figure out a way to connect from external network like TAKT hackerspace is doing to trolls us
# case "$(nmcli -t -f active,ssid dev wifi | awk -F: '$1 == "yes" { print $2 }')" in
# 	"Base48-2"|"Base48-5") true ;;
# 	*) die 1 "Not connected on local network of Base48 Hackerspace"
# esac

# Join all arguments, replace spaces with '+'
input="${*// /+}"

status "Got input: $input"

# Loop through the string in chunks of 8 characters
# FIXME(Krey): Implement word-aware chunking
while [ -n "$input" ]; do
		chunk="${input:0:8}" # Take first 8 characters
		input="${input:8}" # Remove first 8 characters

		status "Sending: $chunk"

		curl "http://10.48.0.13:10001/?text=$chunk" # Send the chunk

		[ -z "$input" ] || sleep 5 # Wait for next update
done
