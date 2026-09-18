# patches/veins-5.3.1/subprojects/veins_inet/src/veins_inet/

Three coordinated patches to `VeinsInetMobility` adding two FUMD-AI features:

## Feature 1 — SUMO↔Veins vehicle ID mapping file

Written by `setInitialPosition()` in `VeinsInetMobility.cc` at the moment each
vehicle first enters the simulation.

Output file: `<result-dir>/sumo_veins_mapping.txt`  
Format: one line per vehicle — `SUMO=<sumo_string_id> VEINS=<omnetpp_module_index>`

This file is a **required input** to the
[fumd-ai-preprocessing-workflow](https://github.com/FUMD-AI/fumd-ai-preprocessing-workflow)
Step 4 (merge), where it is used to align OMNeT++ output vectors with SUMO
trajectory data by matching vehicle identifiers across the two simulators.

**Why written to file rather than EV log:** OMNeT++ suppresses `EV<<` output
during `initialize()` regardless of log level settings. Writing directly to a
file guarantees capture for all vehicles.

## Feature 2 — SUMO numeric ID as OMNeT++ signal

Registered in `initialize()` and emitted once per vehicle as `carNumSUMO`.
Captured in `.sca`/`.vec` output via the `@statistic` declaration in the NED file.

## Files

| File | Changes |
|---|---|
| `VeinsInetMobility.cc` | `#include <fstream>`; signal registration and emit in `initialize()`; mapping file write in `setInitialPosition()` |
| `VeinsInetMobility.h` | `#include "string"` and `"iostream"`; `simsignal_t carNumSUMOSignalId` private member |
| `VeinsInetMobility.ned` | `@signal[carNumSUMO](type="int")` and `@statistic[carNumSUMO](...)` |

## Deploy to

```
<omnet_install_dir>/veins-5.3.1/subprojects/veins_inet/src/veins_inet/
```

Then rebuild:

```bash
cd <omnet_install_dir>/veins-5.3.1/subprojects/veins_inet
make -j$(nproc)
```
