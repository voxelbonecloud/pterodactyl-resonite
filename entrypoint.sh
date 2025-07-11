#!/bin/bash
#
# Copyright (c) 2021 Matthew Penner
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
# INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
#export INTERNAL_IP

# Switch to the container's working directory
cd /home/container || exit 1

# Update Resonite headless
STEAMCMD_BETA_PASSWORD=""
if [ ! "${BETA_CODE}" = "" ]; then
	STEAMCMD_BETA_PASSWORD="-betapassword ${BETA_CODE}"
fi

# Handle if we have no Steam branch
# - we will run into this with people using older eggs
if [ "${STEAM_BRANCH}" = "" ]; then
	echo "Manually adding Steam branch!"
	STEAM_BRANCH="headless"
fi

./steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASSWORD} ${STEAM_AUTH} +force_install_dir /home/container +app_license_request 2519830 +app_update 2519830 -beta ${STEAM_BRANCH} ${STEAMCMD_BETA_PASSWORD} validate +quit

# Modding stuff
HEADLESS_DIRECTORY="/home/container"

if [ "${ENABLE_MODS}" = "true" ] || [ "${ENABLE_MODS}" = "1" ]; then
	echo "Mods are enabled."

	mkdir -p ${HEADLESS_DIRECTORY}/Libraries

	mkdir -p ${HEADLESS_DIRECTORY}/rml_mods
	mkdir -p ${HEADLESS_DIRECTORY}/rml_libs
	mkdir -p ${HEADLESS_DIRECTORY}/rml_config

	# Download ResoniteModLoader
	echo "Downloading ResoniteModLoader and 0Harmony"

	# Make sure we don't have older versions of 0Harmony
	rm ${HEADLESS_DIRECTORY}/rml_libs/0Harmony-Net8.dll
	rm ${HEADLESS_DIRECTORY}/rml_libs/0Harmony.dll

	curl -SslL https://github.com/resonite-modding-group/ResoniteModLoader/releases/latest/download/0Harmony-Net9.dll -o ${HEADLESS_DIRECTORY}/rml_libs/0Harmony-Net9.dll
	curl -SslL https://github.com/resonite-modding-group/ResoniteModLoader/releases/latest/download/ResoniteModLoader.dll -o ${HEADLESS_DIRECTORY}/Libraries/ResoniteModLoader.dll

	# Install mods
	if [ "${MOD_PROMETHEUS}" = "1" ]; then
		echo "Installing HeadlessPrometheusExporter by J4"
		curl -SslL https://i.j4.lc/resonite/mods/latest/HeadlessPrometheusExporter.dll -o ${HEADLESS_DIRECTORY}/rml_mods/HeadlessPrometheusExporter.dll
	fi

	if  [ "$MOD_HEADLESSTWEAKS" = "1" ]; then
		echo "Installing HeadlessTweaks by New_Project_Final_Final_WIP"
		curl -SslL https://github.com/New-Project-Final-Final-WIP/HeadlessTweaks/releases/latest/download/HeadlessTweaks.dll -o ${HEADLESS_DIRECTORY}/rml_mods/HeadlessTweaks.dll
	fi

	if [ "$MOD_HEADLESSUSERCULLING" = "1" ]; then
		echo "Installing HeadlessUserCulling by Raidriar"
		curl -SslL https://github.com/Raidriar796/HeadlessUserCulling/releases/latest/download/HeadlessUserCulling.dll -o ${HEADLESS_DIRECTORY}/rml_mods/HeadlessUserCulling.dll
	fi

	if [ "$MOD_STRESSLESSHEADLESS" = "1" ]; then
		echo "Installing StresslessHeadless by Raidriar"
		curl -SslL https://github.com/Raidriar796/StresslessHeadless/releases/latest/download/StresslessHeadless.dll -o ${HEADLESS_DIRECTORY}/rml_mods/StresslessHeadless.dll
	fi

fi

# Convert all of the "{{VARIABLE}}" parts of the command into the expected shell
# variable format of "${VARIABLE}" before evaluating the string and automatically
# replacing the values.
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

# Display the command we're running in the output, and then execute it with the env
# from the container itself.
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0m%s\n" "$PARSED"
# shellcheck disable=SC2086
exec env ${PARSED}
