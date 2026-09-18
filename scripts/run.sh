#!/bin/bash
# =============================================================================
# run.sh — Single-configuration OMNeT++ simulation launcher
#
# Called internally by run_all.sh. Can also be used directly for a single run.
#
# Usage:
#   ./run.sh <config_name> <run_number>
#   ./run.sh VoipDl_900_1 0
#
# Part of: FUMD-AI / fumd-ai-simulation-workflow
# Repository: https://github.com/FUMD-AI/fumd-ai-simulation-workflow
#
# Authors:
#   Cristina Bernad, Miguel Hernandez University (ORCID: 0000-0001-9537-415X)
#   Sonja Filiposka, Ss. Cyril and Methodius University (ORCID: 0000-0003-0034-2855)
#   Katya Gilly, Miguel Hernandez University (ORCID: 0000-0002-8985-0639)
#
# Acknowledgement: FUMD-AI project, EOSC GRAVITY Grant 25-EOSC-GRV-INTER-013
# https://eosc.eu/horizon-europe-projects/fumd-ai
#
# SPDX-License-Identifier: MIT
#
# Before running:
#   1. Activate the opp_env shell:  cd <omnet_install_dir> && opp_env shell
#   2. Start the SUMO TraCI daemon: <omnet_install_dir>/veins-5.3.1/bin/veins_launchd -vv -c /usr/bin/sumo &
#   3. Ensure the EOSC storage mount is available: ls /mnt/oneclient/FUMD-AI/
#
# Replace <omnet_install_dir> below with the actual path to your OMNeT++
# installation directory (e.g. /home/<user>/OMNET).
# =============================================================================

set -euo pipefail

SIMDIR="<omnet_install_dir>/simu5g-1.4.4/simulations/nr/UrbanALCsimu5G"
VEINS="<omnet_install_dir>/veins-5.3.1"

# CONFIG: simulation configuration name (default: VoipDl_900_1)
CONFIG="${1:-VoipDl_900_1}"

# RUN: OMNeT++ run/seed number (default: 0)
RUN="${2:-0}"

opp_run \
  -u Cmdenv \
  -l <omnet_install_dir>/inet-4.5.4/src/INET \
  -l "$VEINS/src/veins" \
  -l "$VEINS/subprojects/veins_inet/src/veins_inet" \
  -l <omnet_install_dir>/simu5g-1.4.4/src/simu5g \
  -n "<omnet_install_dir>/inet-4.5.4/src;$VEINS/src/veins;$VEINS/subprojects/veins_inet/src/veins_inet;<omnet_install_dir>/simu5g-1.4.4/src;<omnet_install_dir>/simu5g-1.4.4/simulations" \
  --image-path="$VEINS/images" \
  -f "$SIMDIR/omnetpp.ini" \
  -c "$CONFIG" \
  -r "$RUN"
