# patches/simu5g-1.4.4/src/simu5g/common/binder/

Patched Simu5G Binder source fixing a runtime error during NR UE registration.

## File: `Binder.cc`

**Function affected:** `isNrInDualConnectivitySetup()` (~line 985)

**Problem:** Calling `getRrcByNodeId()` during the first UE registration
triggered a runtime error because the RRC module was not yet initialised
at that point in the startup sequence.

**Fix:** The dual-technology RRC check is disabled. `ueIsDualTech` remains
`false`, which disables dual-connectivity detection for multicast scenarios
but does not affect the primary downlink VoIP simulation use case.

## Deploy to

```
<omnet_install_dir>/simu5g-1.4.4/src/simu5g/common/binder/
```
