# patches/simu5g-1.4.4/src/simu5g/stack/rlc/tm/

Patched Simu5G RLC Transparent Mode layer fixing an INET 3.x to 4.x migration
bug that caused a crash when downlink packets arrived at vehicle UEs.

## File: `LteRlcTm.cc`

**Function affected:** `LteRlcTm::handleLowerMessage()` (~line 106)

**Problem:** The function used INET 3.x APIs (`removeControlInfo()` and double
`decapsulate()`) to unwrap incoming packets. In INET 4.x both APIs always return
`nullptr`, causing an immediate `check_and_cast` failure. The upper-layer function
`handleUpperMessage()` had already been migrated to INET 4.x (storing control
information as packet tags with no encapsulation), but `handleLowerMessage()` was
not updated to match.

**Fix:** All unwrapping code is removed. The incoming `inet::Packet` is cast and
forwarded directly to the upper gate, consistent with the INET 4.x packet model.
A `return` statement after `send()` is critical to prevent the `drop(pkt); delete pkt;`
at the end of the function from executing after ownership has been transferred.

## Deploy to

```
<omnet_install_dir>/simu5g-1.4.4/src/simu5g/stack/rlc/tm/
```
