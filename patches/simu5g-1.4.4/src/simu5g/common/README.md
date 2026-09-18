# patches/simu5g-1.4.4/src/simu5g/common/

Patched Simu5G common files expanding the NR UE MAC Node ID range to support
more than 1024 simultaneous NR UEs (vehicles).

## Files

### `LteCommon.msg`
Defines MAC Node ID range constants for all node types. The NR UE range has
been expanded from 1024 to 4096 maximum UEs:

| Constant | Before | After |
|---|---|---|
| `NR_UE_MIN_ID` | 2049 | 5121 |
| `BGUE_MIN_ID` | 4097 | 9217 |

**Requires a full clean rebuild** after deployment (`make clean && make -j$(nproc)`).

### `LteCommon_m.h`
Auto-generated C++ header derived from `LteCommon.msg`. Included here so the
EOSC node does not need to regenerate it during the build. Must always be
kept in sync with `LteCommon.msg`.

## Deploy to

```
<omnet_install_dir>/simu5g-1.4.4/src/simu5g/common/
```

See also: `binder/` (supporting Binder.cc fix) and `../../nodes/` (NrUe.ned counter update).
