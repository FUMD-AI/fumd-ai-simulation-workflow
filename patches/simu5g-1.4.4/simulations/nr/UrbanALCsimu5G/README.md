# patches/simu5g-1.4.4/simulations/nr/UrbanALCsimu5G/

Simulation scenario files for the FUMD-AI Alicante city-centre deployment.

## Files

| File | Description |
|---|---|
| `omnetpp.ini` | Simulation configuration: engine settings, VeinsManager, PHY parameters, gNodeB IDs, handover, X2 mesh, VoIP application, and named run configurations. Fully documented in blocks. |
| `NRSeveralBSALC.ned` | Network topology: 9 NR gNodeBs at Alicante city-centre locations, 1 UPF, 1 router, 1 content server, and a dynamic vehicle population driven by SUMO. Full X2 mesh (36 bidirectional links). Fully documented. |

## Deployment

Copy to the simulation directory on the EOSC node:

```bash
scp omnetpp.ini NRSeveralBSALC.ned \
    <user>@<eosc-node>:<omnet_install_dir>/simu5g-1.4.4/simulations/nr/UrbanALCsimu5G/
```

These files also require the following additional files in the same directory
(not included in this repository — generated separately):

| File | Description |
|---|---|
| `demo.xml` | Static IPv4 routing table (addresses and routes for all nodes) |
| `Alicante_<N>_<V>.launchd.xml` | SUMO scenario launch config for each named run |

## Named configurations in omnetpp.ini

| Config | Vehicles | Variant |
|---|---|---|
| `VoipDl_900_1` | 900 | 1 |
| `VoipDl_900_2` | 900 | 2 |
| `VoipDl_900_3` | 900 | 3 |
| `VoipDl_1000_1` | 1000 | 1 |
| `VoipDl_1000_2` | 1000 | 2 |
| `VoipDl_1000_3` | 1000 | 3 |
| `VoipDl_1200_1` | 1200 | 1 |
| `VoipDl_1200_2` | 1200 | 2 |
| `VoipDl_1200_3` | 1200 | 3 |
| `VoipDl_1400_1` | 1400 | 1 |
| `VoipDl_1400_2` | 1400 | 2 |
| `VoipDl_1400_3` | 1400 | 3 |
