# patches/simu5g-1.4.4/src/simu5g/stack/pdcp/

Patched Simu5G PDCP layer fixing a segfault caused by post-handover orphan
packets arriving at a connection whose RX entity has already been torn down.

## File: `LtePdcp.cc`

**Function affected:** `LtePdcpBase::fromLowerLayer()` (~line 245)

**Problem:** During handover, in-flight downlink packets from the previous
serving gNodeB carry a `FlowControlInfo` tag referencing the old source cell.
After handover completes, `lookupRxEntity(cid)` finds no entity for that
connection and returns `nullptr`. The existing `ASSERT(entity != nullptr)` is
compiled out in release builds, so execution reaches
`entity->handlePacketFromLowerLayer(pkt)` with a null pointer, causing a null
virtual dispatch segfault.

**Fix:** The `ASSERT` is replaced with an explicit null check that logs and
drops the orphan packet gracefully. This matches the expected behaviour defined
by 3GPP for in-flight packets during handover.

**Note:** The `ASSERT` in the TX path (`fromDataPort`, line ~171) is NOT
changed — there, a null entity correctly triggers dynamic connection creation.

## Deploy to

```
<omnet_install_dir>/simu5g-1.4.4/src/simu5g/stack/pdcp/
```
