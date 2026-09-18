# patches/simu5g-1.4.4/src/simu5g/nodes/

Patched Simu5G NED node definition aligning the NR UE MAC Node ID counter
with the expanded range defined in `LteCommon.msg`.

## File: `NrUe.ned`

**Parameter affected:** `nrMacNodeId` default value

The counter start is hardcoded in the NED file independently of `LteCommon.msg`
and must always match `NR_UE_MIN_ID`. After expanding the range:

| | Before | After |
|---|---|---|
| Counter start | `2049` | `5121` |
| Matches | `NR_UE_MIN_ID = 2049` | `NR_UE_MIN_ID = 5121` |

If these two values are out of sync, the first vehicle to register receives
an ID below the NR threshold and the Binder rejects it with a mismatch error.

## Deploy to

```
<omnet_install_dir>/simu5g-1.4.4/src/simu5g/nodes/
```
