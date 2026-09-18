# VoipDl-Urban-900_1_60s — Example Simulation Output

Example output from a **60-second** run of the `VoipDl_900_1_60s` configuration,
generated on 2026-08-31 using the scripts and patched source files in this repository.

This is a short reference run intended for workflow validation and preprocessing
pipeline testing. Full production runs use `sim-time-limit = 1800s`.

## Run parameters

| Parameter | Value |
|---|---|
| Configuration | `VoipDl_900_1_60s` |
| Network | `NRSeveralBSALC` — Alicante city centre, 9 gNodeBs |
| SUMO scenario | `Alicante_900_1.launchd.xml` |
| Simulation duration | 60 seconds |
| Configured vehicles | 900 |
| Active vehicles (present during 60 s) | 30 (car[0]..car[29]) |
| Vehicles in SUMO mapping | 61 (SUMO IDs 0..60) |
| Run number / seed | 0 |
| Run date | 2026-08-31 |

## Files

| File | Size | Description |
|---|---|---|
| `scalar-0.sca` | 7 MB | Summary statistics: 31,501 scalar values across all network modules |
| `vector-0.vec` | 101 MB | Time-series vectors: 4,320 signals (⚠ Git LFS — see below) |
| `vector-0.vci` | 3.8 MB | Index into `vector-0.vec`; lists all signal names, module paths, and byte offsets |
| `sumo_veins_mapping.txt` | 1 KB | SUMO vehicle string ID ↔ OMNeT++ module index (one line per vehicle) |

> ⚠ **`vector-0.vec` is tracked by Git LFS.** Run `git lfs install` before
> cloning, or download it directly from the GitHub release assets.

## Key signals recorded (per vehicle)

The following signals are the primary inputs to the
[fumd-ai-preprocessing-workflow](https://github.com/FUMD-AI/fumd-ai-preprocessing-workflow):

| Signal | Module | Description |
|---|---|---|
| `servingCell:vector` | `car[N].cellularNic.nrPhy` | ID of the serving gNodeB at each timestamp |
| `measuredSinrDl:vector` | `car[N].cellularNic.nrPhy` | Measured downlink SINR (dB) |
| `rcvdSinrDl:vector` | `car[N].cellularNic.nrPhy` | Received downlink SINR after combining |
| `averageCqiDl:vector` | `car[N].cellularNic.nrMac` | Average downlink Channel Quality Indicator |
| `rlcThroughputDl:vector` | `car[N].cellularNic.rlc` | RLC layer downlink throughput (bps) |
| `rlcDelayDl:vector` | `car[N].cellularNic.rlc` | RLC layer downlink packet delay (s) |
| `rlcPacketLossDl:vector` | `car[N].cellularNic.rlc` | RLC packet loss indicator |
| `harqErrorRateDl:vector` | `car[N].cellularNic.nrMac` | HARQ downlink error rate |
| `macDelayDl:vector` | `car[N].cellularNic.nrMac` | MAC layer downlink delay (s) |
| `distance:vector` | `car[N].cellularNic.nrPhy` | Distance to serving gNodeB (m) |
| `voipFrameDelay:vector` | `car[N].app[0]` | End-to-end VoIP frame delay (s) |
| `voipReceivedThroughput:vector` | `car[N].app[0]` | Received VoIP throughput (bps) |

## SUMO↔Veins vehicle mapping

`sumo_veins_mapping.txt` maps each SUMO vehicle string ID to its OMNeT++ module
index. In this short scenario, IDs are sequential (SUMO=0 → car[0], SUMO=1 → car[1], ...),
but this is not guaranteed for longer runs where vehicles enter and leave
at different times.

```
SUMO=0 VEINS=0
SUMO=1 VEINS=1
...
SUMO=60 VEINS=60
```

This file is a required input to Step 4 (merge) of the
[fumd-ai-preprocessing-workflow](https://github.com/FUMD-AI/fumd-ai-preprocessing-workflow).

## How to reproduce this run

```bash
# Add a 60s config to omnetpp.ini (or use the existing VoipDl_900_1_60s config):
# sim-time-limit = 60s

# Start SUMO and run
<omnet_install_dir>/veins-5.3.1/bin/veins_launchd -vv -c /usr/bin/sumo &
cd <omnet_install_dir>/simu5g-1.4.4/simulations/nr/UrbanALCsimu5G
./run_all.sh VoipDl_900_1_60s 0
```

See [../../FAIR_OMNeT_Workflow.md](../../FAIR_OMNeT_Workflow.md) for the complete
installation and configuration procedure.
