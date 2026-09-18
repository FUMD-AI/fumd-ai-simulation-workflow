<!--
SPDX-License-Identifier: MIT
Source code in this document is licensed under the MIT License.
Explanatory text is licensed under CC BY 4.0.
-->

# FUMD-AI Simulation Workflow: Installing, Patching and Running the OMNeT++ 5G Simulation Environment

**Part of:** [FUMD-AI / fumd-ai-simulation-workflow](https://github.com/FUMD-AI)  
**Related workflow:** [fumd-ai-preprocessing-workflow](https://github.com/FUMD-AI/fumd-ai-preprocessing-workflow)  
**FAIR Principles:** Findable · Accessible · Interoperable · Reusable  
**Status:** Validated  
**Last updated:** July 2026

---

## Authors

| Name | Affiliation | ORCID |
|---|---|---|
| Cristina Bernad | Miguel Hernandez University | [0000-0001-9537-415X](https://orcid.org/0000-0001-9537-415X) |
| Sonja Filiposka | Ss. Cyril and Methodius University in Skopje | [0000-0003-0034-2855](https://orcid.org/0000-0003-0034-2855) |
| Katja Gilly | Miguel Hernandez University | [0000-0002-8985-0639](https://orcid.org/0000-0002-8985-0639) |

## Acknowledgement

This work has been funded by the **FUMD-AI project**, an EOSC GRAVITY – Inter Project
with Grant Number **25-EOSC-GRV-INTER-013**.
See: <https://eosc.eu/horizon-europe-projects/fumd-ai>

## Licence

- Source code: [MIT License](LICENSE.txt)
- Explanatory text and figures: [CC BY 4.0](LICENSE-CC-BY-4.0.txt)

---

## Overview

This workflow documents the complete procedure to install, patch, configure and run the
5G NR urban vehicular simulation environment used to generate the raw SUMO and OMNeT++
data consumed by the
[fumd-ai-preprocessing-workflow](https://github.com/FUMD-AI/fumd-ai-preprocessing-workflow).

The simulation models a multi-cell NR downlink VoIP scenario with dynamic handover and
SUMO-driven vehicle mobility, producing:

- OMNeT++ vector output (`.vec`) — per-vehicle per-timestep network metrics
- OMNeT++ scalar output (`.sca`) — simulation summary statistics
- `sumo_veins_mapping.txt` — SUMO vehicle ID ↔ OMNeT++/Veins module index mapping

---

## Validated Software Versions

| Tool | Version | Source |
|---|---|---|
| OMNeT++ | 6.3.0 | <https://omnetpp.org/download/old> |
| Simu5G | 1.4.4 | <https://github.com/Unipisa/Simu5G/releases/tag/v1.4.4> |
| INET | 4.5.4 | <https://inet.omnetpp.org/2024-10-29-INET-4.5.4-released.html> |
| Veins | 5.3.1 | <https://veins.car2x.org/download/> |
| SUMO | 1.22.0 | <https://sumo.dlr.de/releases/1.22.0/> |

---

## About the EOSC Node Server

The simulation runs on a compute node provided through the EOSC infrastructure for the
FUMD-AI project. Throughout this document, server access is written as:

```
<user>@<eosc-node>
```

where `<user>` is your account username and `<eosc-node>` is the hostname or IP address
of the EOSC compute node assigned to the project. These credentials are provided to
project members separately and are not included in this public document.

All commands in this workflow are run on the EOSC node via SSH unless explicitly stated
otherwise.

---

## Repository Structure

This workflow repository contains:

```
fumd-ai-simulation-workflow/
├── README.md                        this document
├── CITATION.cff                     citation metadata
├── LICENSE.txt                      MIT (source code)
├── LICENSE-CC-BY-4.0.txt            CC BY 4.0 (text/figures)
├── ro-crate-metadata.json           FAIR/WorkflowHub packaging metadata
├── scripts/
│   ├── run_all.sh                   launch one or more simulation configs (primary entry point)
│   └── run.sh                       single-config launcher called internally by run_all.sh
└── patches/
    ├── LteRlcTm.cc                  patched Simu5G RLC TM source
    ├── LtePdcp.cc                   patched Simu5G PDCP source
    ├── LteCommon.msg                patched Simu5G common message definitions
    ├── LteCommon_m.h                corresponding auto-generated header
    ├── NrUe.ned                     patched Simu5G NR UE NED definition
    ├── Binder.cc                    patched Simu5G binder source
    ├── VeinsInetMobility.cc         patched Veins mobility source
    ├── VeinsInetMobility.h          patched Veins mobility header
    └── VeinsInetMobility.ned        patched Veins mobility NED definition
```

All patch files carry a standardised comment block identifying the change,
the reason, and the relevant FUMD-AI workflow (see §Patch Comment Convention below).

---

## Part 1 — Installation

### 1.1 Prepare the Base Environment

Install Micromamba for Python environment management:

```bash
"${SHELL}" <(curl -L micro.mamba.pm/install.sh)
# Accept all defaults when prompted
source ~/.bashrc
micromamba activate
micromamba install -n base -c conda-forge python=3.9
```

Install Nix (required by opp_env) — log out and back in after this step:

```bash
curl -L https://nixos.org/nix/install | sh
# Log out and back in, then:
micromamba activate
```

> **Note on rebooting a shared server:** If other users are logged in, a
> full reboot may not be available. For Nix, logging out and back in is
> sufficient — a reboot is not required.

Install pip and opp_env:

```bash
sudo apt install python3-pip
pip install opp-env
```

### 1.2 Install All OMNeT++ Libraries via opp_env

```bash
mkdir <omnet_install_dir> && cd <omnet_install_dir>
opp_env init
opp_env install simu5g-1.4.4 inet-4.5.4 veins-5.3.1
```

This installs OMNeT++ 6.3.0 + INET 4.5.4 + Simu5G 1.4.4 + Veins 5.3.1 into
`<omnet_install_dir>`.

Activate the environment for all subsequent work:

```bash
cd <omnet_install_dir>
opp_env shell
# Prompt confirms active versions:
# omnetpp-6.3.0+inet-4.5.4+simu5g-1.4.4+veins-5.3.1:~$
```

### 1.3 Build the veins_inet Subproject

The `veins_inet` subproject (INET 4.x bridge for Veins) must be compiled separately:

```bash
cd <omnet_install_dir>/veins-5.3.1/subprojects/veins_inet
make -j$(nproc)
```

Verify the library was built:

```bash
find <omnet_install_dir>/veins-5.3.1/subprojects/veins_inet -name "libveins_inet.so"
# Expected: .../src/libveins_inet.so
```

### 1.4 Install SUMO 1.22.0 from Source

**Install build dependencies in this order** (each resolves a specific cmake error):

```bash
# Core build tools and libraries
sudo apt-get install cmake python g++ libxerces-c-dev libfox-1.6-dev \
  libgdal-dev libproj-dev libgl2ps-dev swig

# Google Test — required by SUMO cmake
sudo apt install libgtest-dev

# Xerces XML parser — required; causes cmake failure if absent
sudo apt install libxerces-c-dev
```

**Download and build SUMO 1.22.0:**

```bash
curl -O https://sumo.dlr.de/releases/1.22.0/sumo-src-1.22.0.tar.gz
tar -xzf sumo-src-1.22.0.tar.gz
cd sumo-1.22.0
export SUMO_HOME="$PWD"

cmake -B build -S .
cmake --build build -j$(nproc)

# Make sumo available system-wide
sudo cp $SUMO_HOME/bin/sumo /usr/bin
```

> **Expected cmake output:** Several "Could NOT find" warnings (Proj, Fox,
> Freetype, X11, SWIG, etc.) are normal and non-fatal — they disable optional
> GUI features not needed for TraCI-based co-simulation. The build is correct
> as long as cmake generates build files and the final binary appears at
> `build/bin/sumo`.

---

## Part 2 — Deploying Patched Source Files

### 2.1 Complete List of Patched Files

| File | Component | Patch |
|---|---|---|
| `LteRlcTm.cc` | Simu5G RLC | INET 3→4 decapsulation fix |
| `LtePdcp.cc` | Simu5G PDCP | Null entity guard post-handover |
| `LteCommon.msg` | Simu5G common | Expanded NR UE ID range |
| `LteCommon_m.h` | Simu5G common | Corresponding generated header |
| `NrUe.ned` | Simu5G nodes | Updated MAC Node ID counter start |
| `Binder.cc` | Simu5G binder | Disabled dual-tech RRC check causing runtime error at UE registration |
| `VeinsInetMobility.cc` | Veins veins_inet | SUMO↔Veins ID mapping output |
| `VeinsInetMobility.h` | Veins veins_inet | Header update for mapping feature |
| `VeinsInetMobility.ned` | Veins veins_inet | NED declaration update |
| `omnetpp.ini` | Simulation config | Scenario parameters, initial UE registration, X2 topology |

All patched files are in the `patches/` directory of this repository.

### 2.2 Transfer Files to the EOSC Node

From your **local machine**, copy the patched files to a staging directory on the server:

```bash
scp patches/* <user>@<eosc-node>:~/fumd-ai-patches/
```

### 2.3 Copy Files to Their Correct Directories

On the **EOSC node**, copy each file to its target location:

```bash
cd ~/fumd-ai-patches

# Simu5G binder
cp Binder.cc \
   <omnet_install_dir>/simu5g-1.4.4/src/simu5g/common/binder/

# Simu5G common — msg and generated header
cp LteCommon.msg LteCommon_m.h \
   <omnet_install_dir>/simu5g-1.4.4/src/simu5g/common/

# Simu5G PDCP
cp LtePdcp.cc \
   <omnet_install_dir>/simu5g-1.4.4/src/simu5g/stack/pdcp/

# Simu5G RLC TM
cp LteRlcTm.cc \
   <omnet_install_dir>/simu5g-1.4.4/src/simu5g/stack/rlc/tm/

# Simu5G NED node definition
cp NrUe.ned \
   <omnet_install_dir>/simu5g-1.4.4/src/simu5g/nodes/

# Veins inet mobility (3 files)
cp VeinsInetMobility.cc VeinsInetMobility.h VeinsInetMobility.ned \
   <omnet_install_dir>/veins-5.3.1/subprojects/veins_inet/src/veins_inet/
```

### 2.4 Rebuild After Deploying

Because `LteCommon.msg` was changed, a full clean rebuild is required:

```bash
cd <omnet_install_dir>/simu5g-1.4.4
make clean && make -j$(nproc)

# Also rebuild veins_inet (VeinsInetMobility files changed)
cd <omnet_install_dir>/veins-5.3.1/subprojects/veins_inet
make -j$(nproc)
```

---

## Part 3 — Simulation Project Setup

### 3.1 Deploy the Simulation Scenario

Transfer the simulation scenario archive from your local machine:

```bash
scp UrbanALCsimu5G.tar.gz <user>@<eosc-node>:<omnet_install_dir>/
```

Extract on the EOSC node — use this exact `-C` target to avoid path duplication:

```bash
cd <omnet_install_dir>/simu5g-1.4.4/simulations/nr/
tar -xzf <omnet_install_dir>/UrbanALCsimu5G.tar.gz -C .
```

Verify:

```bash
ls <omnet_install_dir>/simu5g-1.4.4/simulations/nr/UrbanALCsimu5G/
# Should contain: omnetpp.ini, NRSeveralBSALC.ned, *.launchd.xml, run_all.sh, run.sh
```

### 3.2 NED Package Declaration

The NED file declares its package to match its filesystem location:

```ned
package simu5g.simulations.nr.UrbanALCsimu5G;
```

The `omnetpp.ini` references it as:

```ini
network = simu5g.simulations.nr.UrbanALCsimu5G.NRSeveralBSALC
```


---

## Part 3b — OMNeT++ IDE Project Configuration (optional)

If using the OMNeT++ IDE (Eclipse-based) rather than the terminal workflow,
configure each project as follows before building.

### Project References

Each project must declare which other projects it depends on:

| Project | References |
|---|---|
| simu5g | inet-4.5.4, veins_inet |
| veins-5.3.1 | *(none)* |
| veins_inet | inet-4.5.4, veins-5.3.1 |
| inet-4.5.4 | *(none)* |

To set: right-click project → *Properties* → *Project References* → tick the relevant projects.

### NED Source Folders

Each project must declare which folders contain NED files:

| Project | NED Source Folders |
|---|---|
| simu5g | `emulation`, `simulations`, `src` |
| veins-5.3.1 | `src/veins` |
| veins_inet | `examples/veins_inet`, `src/veins_inet` |
| inet-4.5.4 | `examples`, `showcases`, `src`, `tests/networks`, `tests/validation`, `tutorials` |

To set: right-click project → *Properties* → *OMNeT++* → *NED Source Folders*.

### Project Features

Enable only the features required for this simulation:

| Project | Features to enable |
|---|---|
| simu5g | Simu5G Cars |
| veins-5.3.1 | *(none — use defaults)* |
| veins_inet | *(none — use defaults)* |
| inet-4.5.4 | *(default set — includes VoIP)* |

To set: right-click project → *Properties* → *Project Features* → tick the relevant features.

> **Note:** These IDE settings are only needed when building from the IDE.
> The terminal workflow in Part 4 uses explicit `-l` and `-n` flags that
> replicate this configuration directly on the command line.

---

## Part 4 — Running the Simulation

### 4.1 Start the SUMO TraCI Daemon

Before launching OMNeT++, start the SUMO launcher in background:

```bash
cd <omnet_install_dir>/veins-5.3.1/bin
./veins_launchd -vv -c /usr/bin/sumo &
```

Check port 9999 is free (required by Veins TraCI):

```bash
netstat -ano -p tcp | grep 9999
# If occupied: fuser 9999/tcp → kill <PID>
```

### 4.2 Run Simulations with run_all.sh

`run_all.sh` (from `scripts/` in this repository) is the primary entry point
for launching simulations. It accepts one or more configuration names, runs
them in sequence, logs each run to `./logs/<config>_run<N>.log`, and prints
a pass/fail summary with elapsed time at the end.

Make it executable and place it alongside `run.sh` in the simulation directory:

```bash
chmod +x run_all.sh run.sh
```

Usage:

```bash
# Run a single config at run number 0 (default)
./run_all.sh VoipDl_900_1

# Run multiple configs in sequence, all at run number 0
./run_all.sh VoipDl_900_1 VoipDl_900_2 VoipDl_900_3

# Run specific config:run combinations
./run_all.sh VoipDl_900_1:0 VoipDl_900_1:1 VoipDl_900_2:0
```

`run_all.sh` calls `run.sh` internally for each config. `run.sh` handles the
`opp_run` invocation with the correct library and NED paths:

```bash
#!/bin/bash
# run.sh — Internal launcher called by run_all.sh
# Direct use: ./run.sh <config_name> <run_number>

SIMDIR="<omnet_install_dir>/simu5g-1.4.4/simulations/nr/UrbanALCsimu5G"
VEINS="<omnet_install_dir>/veins-5.3.1"

opp_run \
  -u Cmdenv \
  -l <omnet_install_dir>/inet-4.5.4/src/INET \
  -l $VEINS/src/veins \
  -l $VEINS/subprojects/veins_inet/src/veins_inet \
  -l <omnet_install_dir>/simu5g-1.4.4/src/simu5g \
  -n "<omnet_install_dir>/inet-4.5.4/src;\
$VEINS/src/veins;\
$VEINS/subprojects/veins_inet/src/veins_inet;\
<omnet_install_dir>/simu5g-1.4.4/src;\
<omnet_install_dir>/simu5g-1.4.4/simulations" \
  --image-path="$VEINS/images" \
  -f "$SIMDIR/omnetpp.ini" \
  -c "${1:-VoipDl_900_1}" \
  -r "${2:-0}"
```

> **Important:** In the `-n` (NED path) flag, use absolute paths or `$HOME/...`
> rather than `~/...` — OMNeT++ does not expand the tilde in NED paths.

The script exits with a non-zero code if any run failed, making it suitable
for use in batch jobs or `nohup`:

```bash
nohup ./run_all.sh VoipDl_900_1 VoipDl_900_2 VoipDl_900_3 > nohup.out 2>&1 &
```

### 4.3 Key opp_run Flag Reference

| Flag | Purpose | Note |
|---|---|---|
| `-u Cmdenv` | Headless mode — no GUI | Required on servers without a display |
| `-l` | Load shared library | Use absolute paths or `~/` (shell expands this) |
| `-n` | NED search path, semicolon-separated | Use `$HOME/...`, not `~/` |
| `-n .../veins/src/veins` | Veins NED root | Must point to `src/veins`, not `src` |
| `-n .../veins_inet/src/veins_inet` | veins_inet NED root | Must point to `src/veins_inet`, not `src` |
| `-n .../simulations` | Simu5G simulation NED root | Must be `simulations/`, not the specific subfolder |

---

## Part 4b — Example Output

A validated 60-second reference run of configuration `VoipDl_900_1_60s` is
included in [`examples/VoipDl-Urban-900_1_60s/`](examples/VoipDl-Urban-900_1_60s/)
in this repository. It was produced on 2026-08-31 using the exact scripts and
patched files documented here, and can be used to:

- Verify that a new installation produces equivalent output
- Test the [fumd-ai-preprocessing-workflow](https://github.com/FUMD-AI/fumd-ai-preprocessing-workflow) without running a full simulation
- Understand the structure of the output files before processing a production run

### Output files

| File | Size | Description |
|---|---|---|
| `scalar-0.sca` | 7 MB | 31,501 summary scalars across all network modules |
| `vector-0.vec` | 101 MB | 4,320 time-series vector signals — tracked by Git LFS |
| `vector-0.vci` | 3.8 MB | Index into `vector-0.vec`; lists all signal names and byte offsets |
| `sumo_veins_mapping.txt` | 1 KB | SUMO vehicle string ID ↔ OMNeT++ module index (61 vehicles) |

> **Git LFS:** `vector-0.vec` and all `*.vec` files are tracked with Git LFS.
> Run `git lfs install` before cloning, or the vector file will appear as a
> small pointer file rather than the actual data.

### Key signals in this run (per vehicle, 30 active vehicles)

| Signal | Source module | Role in handover prediction |
|---|---|---|
| `servingCell:vector` | `nrPhy` | Ground truth: which gNodeB serves the vehicle at each timestep |
| `measuredSinrDl:vector` | `nrPhy` | Primary feature: downlink SINR from serving cell |
| `rcvdSinrDl:vector` | `nrPhy` | Received SINR after combining |
| `averageCqiDl:vector` | `nrMac` | Channel quality indicator (1–15 scale) |
| `rlcThroughputDl:vector` | `rlc` | Downlink throughput at RLC layer (bps) |
| `rlcDelayDl:vector` | `rlc` | Downlink packet delay at RLC layer (s) |
| `harqErrorRateDl:vector` | `nrMac` | HARQ block error rate (handover degradation indicator) |
| `macDelayDl:vector` | `nrMac` | MAC scheduling delay (s) |
| `distance:vector` | `nrPhy` | Distance to serving gNodeB (m) |
| `voipFrameDelay:vector` | `app[0]` | End-to-end application delay (s) |

---

All patches address bugs in Simu5G 1.4.4 arising from an incomplete migration
from INET 3.x to INET 4.x, plus one handover race condition. Ready-to-deploy
files are in the `patches/` directory of this repository.

### Patch Comment Convention

All changes in the patched files are marked with a standardised comment block:

```cpp
// [FUMD-AI patch] <short description>
// Reason: <explanation of the bug and why this fixes it>
// Reference: https://github.com/FUMD-AI/fumd-ai-simulation-workflow
```

---

### Patch 1 — LteRlcTm.cc

**Function:** `handleLowerMessage()`  
**Symptom:** `Cannot cast nullptr to type 'simu5g::FlowControlInfo *'` in `LteRlcTm` at ~t=300s

In INET 4.x, `removeControlInfo()` and `decapsulate()` always return `nullptr` —
they are INET 3.x APIs. The `handleUpperMessage()` function was already migrated
to store control information as INET 4.x tags with no encapsulation, so
`handleLowerMessage()` must simply forward the packet upward as-is.

```cpp
// BEFORE (INET 3.x — broken in INET 4.x):
FlowControlInfo *lteInfo = check_and_cast<FlowControlInfo *>(pkt->removeControlInfo());
cPacket *upPkt  = check_and_cast<cPacket *>(pkt->decapsulate());
cPacket *upUpPkt = check_and_cast<cPacket *>(upPkt->decapsulate());
upUpPkt->setControlInfo(lteInfo);
delete upPkt;
EV << "LteRlcTm : Sending packet " << upUpPkt->getName() << " to port TM_Sap_up$o\n";
emit(sentPacketToUpperLayerSignal_, upUpPkt);
send(upUpPkt, upOutGate_);

// AFTER (INET 4.x):
// [FUMD-AI patch] Forward packet directly — no unwrapping needed in INET 4.x
// Reason: handleUpperMessage() no longer encapsulates packets; FlowControlInfo
// is stored as a tag. The INET 3.x removeControlInfo()/decapsulate() calls
// always return nullptr in INET 4.x and must be removed.
// Reference: https://github.com/FUMD-AI/fumd-ai-simulation-workflow
else {
    auto inetPkt = check_and_cast<inet::Packet *>(pkt);
    EV << "LteRlcTm : Sending packet " << inetPkt->getName()
       << " to port TM_Sap_up$o\n";
    emit(sentPacketToUpperLayerSignal_, inetPkt);
    drop(inetPkt);
    send(inetPkt, upOutGate_);
    return;  // skip drop/delete below — send() has taken ownership
}
drop(pkt);
delete pkt;
```

---

### Patch 2 — LtePdcp.cc

**Function:** `fromLowerLayer()`  
**Symptom:** Segfault at `take(pkt)` in `LteRxPdcpEntity::handlePacketFromLowerLayer` at ~t=300s

During handover, in-flight downlink packets carry `FlowControlInfo` referencing
the old source gNodeB. After handover completes, `lookupRxEntity(cid)` finds no
entity for that connection and returns `nullptr`. The existing
`ASSERT(entity != nullptr)` is compiled out in release builds, causing a null
virtual function dispatch (segfault). The correct behaviour is to silently drop
these post-handover orphan packets.

```cpp
// BEFORE:
ASSERT(entity != nullptr);
entity->handlePacketFromLowerLayer(pkt);

// AFTER:
// [FUMD-AI patch] Guard against null entity in RX path
// Reason: During handover, in-flight packets from the previous serving cell
// arrive after the PDCP RX entity for that connection has been torn down.
// lookupRxEntity() returns nullptr; ASSERT is compiled out in release builds
// causing a segfault. Orphan packets must be dropped gracefully.
// Reference: https://github.com/FUMD-AI/fumd-ai-simulation-workflow
if (entity == nullptr) {
    EV << "LtePdcp::fromLowerLayer - No RX entity for CID " << cid
       << " (post-handover orphan packet) - dropping\n";
    drop(pkt);
    delete pkt;
    return;
}
entity->handlePacketFromLowerLayer(pkt);
```

> **Note:** The `ASSERT(entity != nullptr)` in the TX path (`fromDataPort`,
> line ~171) must not be changed — there, a null entity correctly triggers
> dynamic connection creation.

---

### Patch 3 — LteCommon.msg

**Symptom:** `Wrong macNodeId: Technology (LTE/NR) mismatch` when vehicle count exceeds 1024

The NR UE MAC Node ID range was hardcoded for a maximum of 1024 NR UEs.
With larger SUMO scenarios, IDs overflow outside the validated range.

```cpp
// BEFORE (max 1024 NR UEs):
constexpr unsigned short NR_UE_MIN_ID = 2049;
constexpr unsigned short BGUE_MIN_ID  = 4097;

// AFTER (max 4096 NR UEs):
// [FUMD-AI patch] Expand NR UE ID range to support up to 4096 NR UEs
// Reason: Default range (2049-4096) allows only 1024 NR UEs. Large SUMO
// scenarios with >1024 simultaneous vehicles overflow this range causing
// Binder registration failure. NrUe.ned counter start must also be updated.
// Reference: https://github.com/FUMD-AI/fumd-ai-simulation-workflow
constexpr unsigned short NR_UE_MIN_ID = 5121;   // 1024 + 4096 LTE UEs + 1
constexpr unsigned short BGUE_MIN_ID  = 9217;   // NR_UE_MIN_ID + 4096
```

> A full clean rebuild (`make clean && make -j$(nproc)`) is required after
> this change since `LteCommon_m.h` is auto-generated from `LteCommon.msg`.
> The pre-generated `LteCommon_m.h` is included in `patches/` to avoid
> requiring the full rebuild on the EOSC node.

---

### Patch 4 — NrUe.ned

**Symptom:** `Wrong macNodeId 2049: Technology (LTE/NR) mismatch` for the first vehicle after Patch 3

The NR UE ID counter start is hardcoded in the NED file independently of
`LteCommon.msg` and must be kept in sync.

```ned
// BEFORE:
int nrMacNodeId = default(2049+simu5g_seq("NrUe_macNodeId"));

// AFTER:
// [FUMD-AI patch] Align NR UE MAC Node ID counter with expanded NR_UE_MIN_ID
// Reason: NrUe.ned hardcodes the starting ID independently of LteCommon.msg.
// After expanding NR_UE_MIN_ID to 5121 in LteCommon.msg, this counter must
// match; otherwise the first vehicle is assigned ID 2049 which the Binder
// now rejects as below the NR range.
// Reference: https://github.com/FUMD-AI/fumd-ai-simulation-workflow
int nrMacNodeId = default(5121+simu5g_seq("NrUe_macNodeId"));
```


---

### Patch 5 — Binder.cc

**Function:** `isNrInDualConnectivitySetup()` (line ~985)  
**Symptom:** Runtime error during UE registration — `check_and_cast<Rrc*>` returns null

During the initial registration of an NR UE, calling `getRrcByNodeId()` inside
`isNrInDualConnectivitySetup()` fails because the RRC module is not yet fully
initialised at that point in the startup sequence. The dual-technology check is
disabled; `ueIsDualTech` remains false. This does not affect the primary
downlink VoIP simulation use case.

```cpp
// BEFORE:
if (ue != NODEID_NONE) {
    Rrc *rrc = check_and_cast<Rrc*>(getRrcByNodeId(ue));
    ueIsDualTech = rrc->isDualTechnology();
}

// AFTER:
// [FUMD-AI patch] Disabled dual-technology RRC check
// Reason: Calling getRrcByNodeId() at this point during handover causes
// a runtime error — the RRC module pointer is not yet available when
// this function is first invoked for NR UEs joining the simulation.
// ueIsDualTech remains false; this disables dual-connectivity detection
// for multicast but does not affect the primary simulation use case.
// Reference: https://github.com/FUMD-AI/fumd-ai-simulation-workflow
```

---

### Patch 6 — VeinsInetMobility (.cc / .h / .ned)

**Purpose:** Emit SUMO vehicle ID as OMNeT++ signal and write SUMO↔Veins mapping file

Three coordinated changes across the mobility module:

**VeinsInetMobility.h** — add signal declaration and required headers:
```cpp
// [FUMD-AI patch] Headers and signal for SUMO vehicle ID recording
#include "string"
#include "iostream"
// ...
private:
    simsignal_t carNumSUMOSignalId;
```

**VeinsInetMobility.cc** — register signal in `initialize()` and write mapping in `setInitialPosition()`:
```cpp
// In initialize():
// [FUMD-AI patch] Emit SUMO vehicle ID as OMNeT++ signal
carNumSUMOSignalId = registerSignal("carNumSUMO");
int carNumSUMO = stoi(getExternalId());
emit(carNumSUMOSignalId, (int)carNumSUMO);

// In setInitialPosition():
// [FUMD-AI patch] Write SUMO<->Veins vehicle ID mapping to result directory
std::string sumoId = getExternalId();
int veinsId = getParentModule()->getIndex();
std::string resultDir = getEnvir()->getConfig()
                          ->getConfigEntry("result-dir").getValue();
if (resultDir.empty()) resultDir = ".";
std::ofstream mapFile(resultDir + "/sumo_veins_mapping.txt", std::ios::app);
if (mapFile.is_open()) {
    mapFile << "SUMO=" << sumoId << " VEINS=" << veinsId << "\n";
    mapFile.flush();
}
```

**VeinsInetMobility.ned** — declare signal and statistic:
```ned
// [FUMD-AI patch] Signal and statistic for SUMO vehicle ID recording
@signal[carNumSUMO](type="int");
@statistic[carNumSUMO](title="SUMO car number"; source="carNumSUMO"; record=stats; interpolationmode=none);
```

Output: `<result-dir>/sumo_veins_mapping.txt` — one line per vehicle spawned,
written at the moment each vehicle enters the simulation. Required input to
[fumd-ai-preprocessing-workflow](https://github.com/FUMD-AI/fumd-ai-preprocessing-workflow) Step 4.

---

## Part 7 — omnetpp.ini: Required Settings

```ini
[General]
# Initial serving cell registration — required even with dynamic association enabled.
# Simu5G uses nrServingNodeId during INITSTAGE_NETWORK_LAYER before dynamic
# association activates. Without it, the Binder receives a null module reference
# on first UE attachment, causing a cascade failure in the PDCP layer.
*.car[*].servingNodeId = 0       # LTE anchor: none
*.car[*].nrServingNodeId = 1     # initial NR cell: gNodeB closest to vehicle entry point

# Output control
cmdenv-express-mode = true       # print progress only, suppress per-event log
cmdenv-log-level = OFF           # silence all modules by default
```

---

## Part 8 — Rebuild Reference

| Change type | Command |
|---|---|
| `.cc` or `.h` Simu5G source | `cd <omnet_install_dir>/simu5g-1.4.4 && make -j$(nproc)` |
| `.msg` file | `cd <omnet_install_dir>/simu5g-1.4.4 && make clean && make -j$(nproc)` |
| `VeinsInetMobility.*` | `cd <omnet_install_dir>/veins-5.3.1/subprojects/veins_inet && make -j$(nproc)` |
| `.ned` or `.ini` file | No recompile needed — loaded at runtime |

---

## Appendix A — Troubleshooting

| Error | Cause | Section |
|---|---|---|
| `Cannot resolve module type 'VeinsInetManager'` | `veins_inet` not in `-n` NED path | §4.3 |
| `Declared package does not match expected package` | Wrong NED root — use `src/veins`, not `src` | §4.3 |
| `Cannot cast nullptr to type 'simu5g::Rrc *'` | Missing `nrServingNodeId` in ini | §7 |
| `Cannot cast nullptr to type 'simu5g::FlowControlInfo *'` | INET 3.x API in LteRlcTm | Patch 1 |
| `Segfault at take(pkt)` in PDCP | Null entity post-handover | Patch 2 |
| `Wrong macNodeId: Technology mismatch` | NR UE ID range too small | Patches 3+4 |
| `Aborted (core dumped)` with no error | Qtenv fails without display — `-u Cmdenv` is set in `run.sh` | §4.2 |
| `cmake: Could NOT find GTest` | Missing `libgtest-dev` | §1.4 |
| `cmake: Could NOT find XercesC` | Missing `libxerces-c-dev` | §1.4 |
| Files extracted to wrong path | Wrong `-C` target in tar — see §3.1 | §3.1 |

---

## Appendix B — FAIR Compliance

| Principle | Implementation |
|---|---|
| **Findable** | All software versions pinned with source URLs; workflow registered on WorkflowHub under the FUMD-AI team; DOI assigned on Zenodo registration |
| **Accessible** | Plain Markdown; terminal-only workflow (no IDE required); EOSC node access documented for project members |
| **Interoperable** | All patches documented with before/after code and standardised comment blocks; file copy paths fully explicit |
| **Reusable** | Patches isolated by file and function; scripts parameterised; `<omnet_install_dir>` and `<user>@<eosc-node>` clearly identified as substitution placeholders |

---

*Part of the FUMD-AI project — EOSC GRAVITY Grant 25-EOSC-GRV-INTER-013*  
*<https://eosc.eu/horizon-europe-projects/fumd-ai>*  
*<https://github.com/FUMD-AI>*
