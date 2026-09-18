# patches/simu5g-1.4.4/

Patched source files for **Simu5G 1.4.4**. All changes fix bugs arising from
an incomplete migration from INET 3.x to INET 4.x in this version, plus one
handover race condition and one UE capacity limit.

## Patches in this directory

| File | Location in installation | Patch summary |
|---|---|---|
| `src/simu5g/common/LteCommon.msg` | `<omnet_install_dir>/simu5g-1.4.4/src/simu5g/common/` | Expands NR UE ID range to support >1024 vehicles |
| `src/simu5g/common/LteCommon_m.h` | same | Auto-generated header matching LteCommon.msg |
| `src/simu5g/common/binder/Binder.cc` | `<omnet_install_dir>/simu5g-1.4.4/src/simu5g/common/binder/` | Disables unsafe RRC check during UE registration |
| `src/simu5g/nodes/NrUe.ned` | `<omnet_install_dir>/simu5g-1.4.4/src/simu5g/nodes/` | Updates MAC Node ID counter start to match expanded range |
| `src/simu5g/stack/pdcp/LtePdcp.cc` | `<omnet_install_dir>/simu5g-1.4.4/src/simu5g/stack/pdcp/` | Guards against null RX entity on post-handover orphan packets |
| `src/simu5g/stack/rlc/tm/LteRlcTm.cc` | `<omnet_install_dir>/simu5g-1.4.4/src/simu5g/stack/rlc/tm/` | Replaces INET 3.x decapsulation with INET 4.x direct forward |
| `simulations/nr/UrbanALCsimu5G/omnetpp.ini` | `<omnet_install_dir>/simu5g-1.4.4/simulations/nr/UrbanALCsimu5G/` | Documented simulation configuration |
| `simulations/nr/UrbanALCsimu5G/NRSeveralBSALC.ned` | same | Documented network topology definition |

Full patch descriptions with before/after code are in
[../../FAIR_OMNeT_Workflow.md](../../FAIR_OMNeT_Workflow.md) Part 5.
