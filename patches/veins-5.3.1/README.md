# patches/veins-5.3.1/

Patched Veins 5.3.1 source files adding SUMO↔Veins vehicle ID mapping and
SUMO numeric ID emission as an OMNeT++ signal.

## Contents

All patches are in:
```
subprojects/veins_inet/src/veins_inet/
```

Three files are modified together as a coordinated set — they must all be
deployed and rebuilt together.

| File | Change |
|---|---|
| `VeinsInetMobility.cc` | Writes SUMO↔Veins mapping file on first position update; emits `carNumSUMO` signal in `initialize()` |
| `VeinsInetMobility.h` | Adds required headers and `carNumSUMOSignalId` private member |
| `VeinsInetMobility.ned` | Declares `@signal[carNumSUMO]` and `@statistic[carNumSUMO]` |

## Rebuild after deployment

```bash
cd <omnet_install_dir>/veins-5.3.1/subprojects/veins_inet
make -j$(nproc)
```
