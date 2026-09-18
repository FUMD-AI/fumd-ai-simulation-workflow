# patches/

Modified source files for Simu5G 1.4.4 and Veins 5.3.1, ready to deploy to
the OMNeT++ installation before building.

The directory structure mirrors the target installation paths exactly, so each
file can be copied directly to the corresponding location under
`<omnet_install_dir>/` using the commands in the workflow (§2.3).

## Contents

| Subdirectory | Library | Files |
|---|---|---|
| `simu5g-1.4.4/src/simu5g/common/` | Simu5G | `LteCommon.msg`, `LteCommon_m.h` — expanded NR UE ID range |
| `simu5g-1.4.4/src/simu5g/common/binder/` | Simu5G | `Binder.cc` — disabled unsafe RRC check |
| `simu5g-1.4.4/src/simu5g/nodes/` | Simu5G | `NrUe.ned` — updated MAC Node ID counter |
| `simu5g-1.4.4/src/simu5g/stack/pdcp/` | Simu5G | `LtePdcp.cc` — null entity guard post-handover |
| `simu5g-1.4.4/src/simu5g/stack/rlc/tm/` | Simu5G | `LteRlcTm.cc` — INET 3→4 migration fix |
| `simu5g-1.4.4/simulations/nr/UrbanALCsimu5G/` | Simu5G | `omnetpp.ini`, `NRSeveralBSALC.ned` — simulation scenario |
| `veins-5.3.1/subprojects/veins_inet/src/veins_inet/` | Veins | `VeinsInetMobility.cc/.h/.ned` — SUMO↔Veins ID mapping |

## All changes are marked with `[FUMD-AI patch]` comment blocks

Every modification is identified by a standardised comment:

```cpp
// [FUMD-AI patch] <short description>
// Reason: <explanation>
// Reference: https://github.com/FUMD-AI/fumd-ai-simulation-workflow
```

## Deployment

```bash
# Transfer to EOSC node
scp -r patches/ <user>@<eosc-node>:~/fumd-ai-patches/

# Then on the server, copy each file to its target (see workflow §2.3)
```

After deploying `LteCommon.msg` or `LteCommon_m.h`, a full clean rebuild is required:

```bash
cd <omnet_install_dir>/simu5g-1.4.4 && make clean && make -j$(nproc)
```

For all other files, an incremental rebuild is sufficient:

```bash
cd <omnet_install_dir>/simu5g-1.4.4 && make -j$(nproc)
cd <omnet_install_dir>/veins-5.3.1/subprojects/veins_inet && make -j$(nproc)
```

## Licence

MIT — see [../LICENSE.txt](../LICENSE.txt)
