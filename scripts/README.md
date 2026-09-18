# scripts/

Bash scripts for launching the OMNeT++ simulation from the terminal.

## Files

| File | Purpose |
|---|---|
| `run_all.sh` | **Primary entry point.** Runs one or more named simulation configurations in sequence. Logs each run to `./logs/<config>_run<N>.log` and prints a pass/fail summary with elapsed time at the end. |
| `run.sh` | Single-configuration launcher, called internally by `run_all.sh`. Can also be used directly for a single run. Constructs the full `opp_run` command with all required library and NED paths. |

## Prerequisites

Before running either script:

1. The `opp_env` shell must be active — run `opp_env shell` from `<omnet_install_dir>`
2. The SUMO TraCI daemon must be running:
   ```bash
   <omnet_install_dir>/veins-5.3.1/bin/veins_launchd -vv -c /usr/bin/sumo &
   ```
3. The EOSC storage mount must be available (for result output):
   ```bash
   ls /mnt/oneclient/FUMD-AI/
   ```

## Setup

Copy both scripts to the simulation directory and make them executable:

```bash
cp run_all.sh run.sh <omnet_install_dir>/simu5g-1.4.4/simulations/nr/UrbanALCsimu5G/
chmod +x <omnet_install_dir>/simu5g-1.4.4/simulations/nr/UrbanALCsimu5G/run_all.sh
chmod +x <omnet_install_dir>/simu5g-1.4.4/simulations/nr/UrbanALCsimu5G/run.sh
```

Replace `<omnet_install_dir>` in both scripts with the actual installation path before deploying.

## Usage

```bash
cd <omnet_install_dir>/simu5g-1.4.4/simulations/nr/UrbanALCsimu5G

# Run a single configuration
./run_all.sh VoipDl_900_1

# Run multiple configurations in sequence
./run_all.sh VoipDl_900_1 VoipDl_900_2 VoipDl_900_3

# Run specific config:seed combinations
./run_all.sh VoipDl_900_1:0 VoipDl_900_1:1 VoipDl_900_2:0

# Background batch run
nohup ./run_all.sh VoipDl_900_1 VoipDl_900_2 VoipDl_900_3 > nohup.out 2>&1 &
```

Available configuration names are defined in `patches/simu5g-1.4.4/simulations/nr/UrbanALCsimu5G/omnetpp.ini`.

## Licence

MIT — see [../../LICENSE.txt](../../LICENSE.txt)
