<!--
SPDX-License-Identifier: MIT
Source code licensed under MIT. Explanatory text licensed under CC BY 4.0.
-->

# FUMD-AI Simulation Workflow

## Installing, Patching and Running the OMNeT++ 5G Urban Simulation Environment

[![FAIR](https://img.shields.io/badge/FAIR-Findable%20%7C%20Accessible%20%7C%20Interoperable%20%7C%20Reusable-blue)](https://www.go-fair.org/fair-principles/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.txt)
[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](LICENSE-CC-BY-4.0.txt)
[![Project: FUMD-AI](https://img.shields.io/badge/Project-FUMD--AI-green)](https://eosc.eu/horizon-europe-projects/fumd-ai)

**Part of:** [FUMD-AI](https://github.com/FUMD-AI) — Federated Urban Mobility Data for AI
**Related workflow:** [fumd-ai-preprocessing-workflow](https://github.com/FUMD-AI/fumd-ai-preprocessing-workflow)

---

## 📖 Full Workflow Documentation

> **[➜ FAIR_OMNeT_Workflow.md](FAIR_OMNeT_Workflow.md)** — Complete step-by-step guide covering installation, source patching, IDE configuration, terminal execution, and all source code fixes with before/after code.

---

## Overview

This repository provides all files needed to install, patch, configure and run
the 5G NR urban vehicular simulation environment used by the FUMD-AI project
to generate synthetic network performance data for AI-based handover prediction.

The simulation combines:

| Tool | Version | Role |
|---|---|---|
| OMNeT++ | 6.3.0 | Discrete event simulation framework |
| Simu5G | 1.4.4 | 5G NR network simulation |
| INET | 4.5.4 | Network protocol library |
| Veins | 5.3.1 | Vehicular network / SUMO bridge |
| SUMO | 1.22.0 | Microscopic traffic simulator |

It models **9 NR gNodeBs** at real locations in the **Alicante city centre**,
connected in a full X2 mesh, with SUMO-driven vehicle mobility and downlink VoIP
traffic. Output feeds directly into the
[fumd-ai-preprocessing-workflow](https://github.com/FUMD-AI/fumd-ai-preprocessing-workflow).

---

## Quick Start

> Full procedure: **[FAIR_OMNeT_Workflow.md](FAIR_OMNeT_Workflow.md)**

```bash
# 1. Install the simulation stack
mkdir <omnet_install_dir> && cd <omnet_install_dir>
opp_env init && opp_env install simu5g-1.4.4 inet-4.5.4 veins-5.3.1
opp_env shell

# 2. Deploy patched source files (see patches/README.md)
scp -r patches/ <user>@<eosc-node>:~/fumd-ai-patches/
# then copy each file to its target on the server (see patches/README.md §Deploy)

# 3. Rebuild
cd <omnet_install_dir>/simu5g-1.4.4 && make clean && make -j$(nproc)
cd <omnet_install_dir>/veins-5.3.1/subprojects/veins_inet && make -j$(nproc)

# 4. Deploy scenario and scripts
scp patches/simu5g-1.4.4/simulations/nr/UrbanALCsimu5G/* \
    scripts/* \
    <user>@<eosc-node>:<omnet_install_dir>/simu5g-1.4.4/simulations/nr/UrbanALCsimu5G/

# 5. Run
<omnet_install_dir>/veins-5.3.1/bin/veins_launchd -vv -c /usr/bin/sumo &
cd <omnet_install_dir>/simu5g-1.4.4/simulations/nr/UrbanALCsimu5G
./run_all.sh VoipDl_900_1 VoipDl_900_2 VoipDl_900_3
```

---

## Repository Structure

```
fumd-ai-simulation-workflow/
│
├── README.md                        This file
├── FAIR_OMNeT_Workflow.md           ← Complete workflow documentation (start here)
├── CITATION.cff                     Citation metadata
├── LICENSE.txt                      MIT Licence (source code)
├── LICENSE-CC-BY-4.0.txt            CC BY 4.0 Licence (documentation)
├── ro-crate-metadata.json           RO-Crate FAIR packaging metadata
├── .gitattributes                   Git LFS tracking for *.vec files
│
├── scripts/                         Launch scripts
│   ├── README.md
│   ├── run_all.sh                   Primary launcher — one or more configs
│   └── run.sh                       Single-config launcher (called by run_all.sh)
│
├── patches/                         Patched source files — deploy before building
│   ├── README.md
│   ├── simu5g-1.4.4/
│   │   ├── simulations/nr/UrbanALCsimu5G/
│   │   │   ├── omnetpp.ini          Documented simulation configuration
│   │   │   └── NRSeveralBSALC.ned   Documented network topology
│   │   └── src/simu5g/
│   │       ├── common/              LteCommon.msg, LteCommon_m.h — expanded UE ID range
│   │       ├── common/binder/       Binder.cc — disabled unsafe RRC check
│   │       ├── nodes/               NrUe.ned — updated MAC Node ID counter
│   │       ├── stack/pdcp/          LtePdcp.cc — null entity guard post-handover
│   │       └── stack/rlc/tm/        LteRlcTm.cc — INET 3→4 migration fix
│   └── veins-5.3.1/
│       └── subprojects/veins_inet/src/veins_inet/
│           ├── VeinsInetMobility.cc  SUMO↔Veins ID mapping + carNumSUMO signal
│           ├── VeinsInetMobility.h   Header additions
│           └── VeinsInetMobility.ned Signal and statistic declaration
│
└── examples/                        Example simulation output
    └── VoipDl-Urban-900_1_60s/      60-second reference run (900 vehicles)
        ├── README.md                Run parameters and signal descriptions
        ├── scalar-0.sca             Summary statistics (7 MB)
        ├── vector-0.vec             Time-series vectors (101 MB — Git LFS)
        ├── vector-0.vci             Vector index (3.8 MB)
        └── sumo_veins_mapping.txt   SUMO↔Veins vehicle ID mapping
```

---

## Source Code Patches Summary

All changes are marked with `// [FUMD-AI patch]` comment blocks. Full before/after
code is in [FAIR_OMNeT_Workflow.md](FAIR_OMNeT_Workflow.md) Part 5.

| File | Fix |
|---|---|
| `LteRlcTm.cc` | INET 3.x `removeControlInfo()`/`decapsulate()` → INET 4.x direct forward |
| `LtePdcp.cc` | Null RX entity guard for post-handover orphan packets |
| `LteCommon.msg` + `LteCommon_m.h` | NR UE ID range expanded: 1024 → 4096 vehicles |
| `NrUe.ned` | MAC Node ID counter aligned with expanded range |
| `Binder.cc` | Disabled unsafe RRC check during UE registration |
| `VeinsInetMobility.cc/.h/.ned` | SUMO↔Veins ID mapping file + `carNumSUMO` signal |

---

## Example Output

A 60-second reference run is in [`examples/VoipDl-Urban-900_1_60s/`](examples/VoipDl-Urban-900_1_60s/).
Key per-vehicle signals: `servingCell`, `measuredSinrDl`, `averageCqiDl`,
`rlcThroughputDl`, `harqErrorRateDl`, `distance`, `voipFrameDelay`.

> ⚠ `vector-0.vec` (101 MB) is tracked by **Git LFS**.
> Run `git lfs install` before cloning, or the file will appear as a pointer stub.

---

## Git LFS

```bash
sudo apt install git-lfs
git lfs install
git clone https://github.com/FUMD-AI/fumd-ai-simulation-workflow.git
```

---

## Authors

| Name | Affiliation | ORCID |
|---|---|---|
| Cristina Bernad | Miguel Hernandez University | [0000-0001-9537-415X](https://orcid.org/0000-0001-9537-415X) |
| Sonja Filiposka | Ss. Cyril and Methodius University in Skopje | [0000-0003-0034-2855](https://orcid.org/0000-0003-0034-2855) |
| Katya Gilly | Miguel Hernandez University | [0000-0002-8985-0639](https://orcid.org/0000-0002-8985-0639) |

## Acknowledgement

Funded by the **FUMD-AI project** — EOSC GRAVITY Grant **25-EOSC-GRV-INTER-013**
<https://eosc.eu/horizon-europe-projects/fumd-ai>

## Licence

- Source code (scripts, patches): [MIT License](LICENSE.txt)
- Documentation: [CC BY 4.0](LICENSE-CC-BY-4.0.txt)
